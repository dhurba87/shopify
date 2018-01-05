class CaptchaException < StandardError
  def initialize(msg = 'Captcha mismatch')
    super
  end
end