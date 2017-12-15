module Sinatra
  module I18n
    module Helpers
      def get_lang(http_lang)
        accepted=["en","es"]
        unless http_lang.nil?
          langs=http_lang.split(",").map {|v|
            v.split(";")[0].split("-")[0]
          }.each  {|l|
            return l if accepted.include? l
          }
        end
        "en"
      end

      # Just a wrapper for I18n::t method
      def t(*args)
        ::I18n::t(*args)
      end
      # Put the term on strong tag, double colon, and later the value
      # @param term Term to be i18n and marked with strong tag
      # @param value Value to be presented, without changes
      def t_desc_value(term, value)
        "<strong>#{::I18n::t(term)}:</strong>&nbsp;#{value}"
      end
      # Canonical title for systematic review pages
      def t_systematic_review_title(sr_name, secondary)
        "<h2>#{::I18n::t(:systematic_review_title, sr_name:sr_name)}</h2><h3>#{::I18n::t(secondary)}</h3>"
      end
      def available_locales
        [:es,:en]
      end
      def available_locales_hash
        available_locales.inject({}) {|ac,v|
          ac[v] = ::I18n.t("locale.#{v}");ac
        }

      end
    end

    def self.registered(app)
      app.helpers I18n::Helpers

      app.before do
        if session['language'].nil?
          language=get_lang(request.env['HTTP_ACCEPT_LANGUAGE'])
          #$log.info(language)
          language=='en' unless ['en','es'].include? language
          ::I18n.locale = language
        else
          ::I18n.locale = session['language'].to_sym
        end
      end



      #$log.info(app.root)
      unless defined?(app.locales)
        app.set :locales, File.join(app.root, 'config','locales', '*.yml')
      end
      ::I18n.load_path+=Dir[app.locales]
      ::I18n.config.available_locales = [:es,:en]
      ::I18n.default_locale=:en
      #::I18n.backend.load_translations(app.locales)
    end
  end
  register I18n
end