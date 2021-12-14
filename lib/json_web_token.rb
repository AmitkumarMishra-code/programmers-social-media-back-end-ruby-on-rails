class JsonWebToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def self.encode(payload, exp = 12.hours.from_now)
    if !payload[:exp]
      payload[:exp] = exp.to_i
    else
      payload[:exp] = payload[:exp].to_i
    end
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token[:token], SECRET_KEY, true, {algorith: "HS256"})[0]
    HashWithIndifferentAccess.new decoded
  end
end