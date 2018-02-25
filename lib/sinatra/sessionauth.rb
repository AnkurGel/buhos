module Sinatra
  module SessionAuth
    module Helpers
      def rol_usuario
        if(!session['user'].nil?)
          "invitado"
        else
          session['rol_id']
        end
      end
      def presentar_usuario
        ##$log.info(session)
        if(!session['user'].nil?)
          partial(:user)
        else
          partial(:guest)
        end
      end

      # Verifica que la persona tenga un permiso específico
      def permiso(per)
        #log.info(session['permisos'])
        if session['user'].nil?
          false
        else
          if session['rol_id']=='administrator'
            Permiso.insert(:id=>per, :descripcion=>::I18n::t("sinatra_auth.permission_created_by_administrator")) if Permiso[per].nil?
            Rol['administrator'].add_permiso(Permiso[per]) unless PermisosRol[permiso_id:per, rol_id:'administrator']
            true
          elsif session['permisos'].include? per
            true
          else
            false
          end
        end
      end

      def revision_pertenece_a(revision_id,usuario_id)
        permiso("revision_editar_propia") and Revision_Sistematica[:id=>revision_id, :administrador_revision=>usuario_id]
      end
      def revision_analizada_por(revision_id,usuario_id)
        permiso("revision_analizar_propia") and !$db["SELECT * FROM grupos_usuarios gu INNER JOIN revisiones_sistematicas rs ON gu.grupo_id=rs.grupo_id WHERE rs.id=? AND gu.usuario_id=?", revision_id, usuario_id].empty?
      end

      def authorize(login, password)
        u=Usuario.filter(:login=>login,:password=>Digest::SHA1.hexdigest(password))
        ##$log.info(u.first)
        if u.first
          user=u.first
          session['user']=user[:login]
          session['user_id']=user[:id]
          session['nombre']=user[:nombre]
          session['rol_id']=user[:rol_id]
          session['permisos']=user.permisos.map {|v| v.id}
          session['language']=user.language
          true
        else
          false
        end
      end

      def desautorizar
        session.delete('user')
      end
    end
    def self.registered(app)
      app.helpers SessionAuth::Helpers

      app.before do
        if session['user'].nil?
          request.path_info='/login'
        end
      end


      app.get '/login' do
        haml :login
      end

      app.post '/login' do
        if(authorize(params['user'], params['password']))
          agregar_mensaje ::I18n.t(:Successful_authentification)
          #log.info( ::I18n::t("sinatra_auth.sucessful_auth_for_user", user:params['user']))
          redirect(url("/"))
        else
          agregar_mensaje ::I18n::t("sinatra_auth.error_on_auth"),:error
          redirect(url("/login"))
        end
      end


      app.get '/logout' do
        desautorizar
        redirect(url('/login'))
      end



    end
  end
  register SessionAuth
end