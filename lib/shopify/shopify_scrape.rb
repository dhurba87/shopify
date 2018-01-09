require 'net/http'
require 'csv'

class ShopifyScrape
  def initialize(domain, username, password)
    @domain = domain
    @username = username
    @password = password

    @cookie = login
  end

  def shopify_url
    "https://#{@domain}.myshopify.com"
  end

  def payout_report(date_min=Time.zone.now.beginning_of_month, date_max=Time.zone.now.end_of_month)
    url = URI("#{shopify_url}/admin/payments/payouts.json?date_min=#{date_min}&date_max=#{date_max}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request1 = Net::HTTP::Get.new(url)
    request1["content-type"] = 'application/x-www-form-urlencoded'
    request1["cache-control"] = 'no-cache'
    request1["cookie"] = @cookie

    response = http.request(request1)

    raise Exception, parse_error(response.body) if response.code.to_i >= 400
    JSON.parse(response.body)
  end

  def sales_report(date_min=Time.zone.now.beginning_of_month, date_max=Time.zone.now.end_of_month)
    url = URI("https://analytics.shopify.com/query?q=SHOW%20orders%20AS%20%22orders%22%2C%20gross_sales%20AS%20%22gross_sales%22%2C%20discounts%20AS%20%22discounts%22%2C%20returns%20AS%20%22returns%22%2C%20net_sales%20AS%20%22net_sales%22%2C%20shipping%20AS%20%22shipping%22%2C%20taxes%20AS%20%22taxes%22%2C%20total_sales%20AS%20%22total_sales%22%20OVER%20month%20AS%20%22month%22%20FROM%20sales%20SINCE%20-11m%20UNTIL%20today%20ORDER%20BY%20%22month%22%20ASC&format=csv&source=shopify-summary&token=#{get_token}&beta=true&handle=sales_#{date_min}_#{date_max}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["cookie"] = @cookie
    request["cache-control"] = 'no-cache'

    response = http.request(request)

    raise Exception, parse_error(response.body) if response.code.to_i >= 400

    csv_arr = CSV.parse(response.read_body)
    keys = csv_arr.shift
    arr_of_object = csv_arr.map {|a| Hash[keys.zip(a)]}

    total_shipping = 0
    total_taxes = 0
    arr_of_object.each do |obj|
      total_shipping = total_shipping + obj['shipping'].to_f
      total_taxes = total_taxes + obj['taxes'].to_f
    end

    {shipping: total_shipping, taxes: total_taxes}
  end

  private

  def login
    login_url = "#{shopify_url}/admin/auth/login"

    url = URI(login_url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["cache-control"] = 'no-cache'
    request.body = "login=#{@username}&password=#{@password}"

    response = http.request(request)

    # Check for invalid username/password
    validation_error_message = Nokogiri::HTML(response.body).css('span.validation-error__message')

    raise validation_error_message.text if validation_error_message.length > 0
    raise 'Domain not found' if response.code.to_i == 404
    raise CaptchaException, 'Captcha displayed while logging in' unless response.code.to_i == 302

    # Return cookie
    response['set-cookie']
  end

  def get_token
    url = URI("#{shopify_url}/admin/reportify/token.json")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["cookie"] = @cookie
    request["cache-control"] = 'no-cache'

    response = http.request(request)
    JSON.parse(response.body)['token']
  end

  def parse_error(response_body)
    begin
      JSON.parse(response_body)['message']
    rescue JSON::ParserError
      # todo::Use nokogiri to parse error from html page
      'Error occurred.'
    end
  end

end
