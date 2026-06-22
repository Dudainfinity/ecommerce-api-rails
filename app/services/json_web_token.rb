# Codifica e decodifica os JWTs usados na autenticação stateless.
class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base.to_s
  DEFAULT_EXP = 24.hours

  def self.encode(payload, exp = DEFAULT_EXP.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" }).first
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
