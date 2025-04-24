require_relative "boot"

require "rails"

# Seleciona apenas os frameworks necessários
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Bolaosca
  class Application < Rails::Application
    ESPACO = 1048576 / 2 - 100
    MANUT_AT = nil

    # Configuração de diretório de assets com Propshaft
    config.assets.paths << Rails.root.join("app/assets/builds")

    # Configurações de localização e timezone
    config.time_zone = "Brasilia"
    config.i18n.default_locale = :'pt-BR'
    config.i18n.available_locales = [ :en, :'pt-BR' ]
    config.encoding = "utf-8"
    config.active_record.default_timezone = :local

    # Segurança
    config.filter_parameters += [ :password, :password_confirmation, :credit_card ]
    config.active_support.escape_html_entities_in_json = true

    # Versão do Rails
    config.load_defaults 8.0

    # Configurações adicionais recomendadas
    config.generators do |g|
      g.assets false
      g.helper false
      g.test_framework :test_unit, fixture: false
    end

    # Middleware recomendado
    config.middleware.use Rack::Deflater
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*" # Ajusta para domínios específicos em produção
        resource "*", headers: :any, methods: [ :get, :post, :options ]
      end
    end
  end
end
