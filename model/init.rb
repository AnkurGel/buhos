# encoding:utf-8
require 'sequel'
require 'logger'
Sequel::Model.plugin :force_encoding, 'UTF-8' if RUBY_VERSION>="1.9"
# Chanta, ¿no?

if(ENV['USER']=="cdx")
$db=Sequel.mysql2(:host=>"localhost",:user=>'root',:password=>'psr-400', :database=>'revsist', :encoding => 'utf8')

else
#$db=Sequel.mysql(:host=>"mysql.apsique.cl",:user=>'biobio',:password=>'biobio018025', :database=>'biobio2012', :encoding => 'UTF8')
raise("No sé donde conectarme")
end

$db.run("SET NAMES UTF8")
$log_sql = Logger.new(File.dirname(__FILE__)+'/../log/app_sql.log')

$db.loggers << $log_sql



#before do
#  content_type :html, 'charset' => 'utf-8'
#end





Sequel.inflections do |inflect|
  inflect.irregular 'rol','roles'
  inflect.irregular 'configuracion','configuraciones'  
  inflect.irregular 'permisos_rol','permisos_roles'
  inflect.irregular 'grupo_usuario','grupos_usuarios'
  inflect.irregular 'revision_sistematica','revisiones_sistematicas'  
  inflect.irregular 'trs_organizacion','trs_organizaciones'
  inflect.irregular 'base_bibliografica','bases_bibliograficas'
  inflect.irregular 'canonico_documento','canonicos_documentos'

end

