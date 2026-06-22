# Be sure to restart your server when you modify this file.
#
# Configuração de Cross-Origin Resource Sharing (CORS).
# Restrinja `origins` para o domínio do seu frontend em produção via a env var CORS_ORIGINS.
# Leia mais: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "*").split(",")

    resource "*",
             headers: :any,
             expose: [ "Authorization" ],
             methods: %i[get post put patch delete options head]
  end
end
