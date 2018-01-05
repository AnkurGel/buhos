module BibRevSys
  module SchemaCreation
    def self.create_schema(db)


        db.create_table? :roles do
          String :id, :size => 50, :primary_key => true
          String :descripcion
        end

        db.create_table? :usuarios do
          primary_key :id
          String :login, :size => 255, :null => false
          String :nombre, :size => 255
          String :password, :size => 255, :null => false
          foreign_key :rol_id, :roles, :type => String, :size => 50, :null => false, :key => [:id]
          TrueClass :activa, :default=>true, :null=>false
        end


        db.create_table? :grupos do
          primary_key :id
          foreign_key :administrador_grupo, :usuarios, :null => false, :key => [:id]
          String :description, :text => true
          String :name, :size => 255, :null => false
        end

        db.create_join_table?(:usuario_id => :usuarios, :grupo_id => :grupos)


        db.create_table? :revisiones_sistematicas do
          primary_key :id
          String :nombre, :size => 255
          Date :fecha_inicio
          String :descripcion, :text => true
          String :objetivos, :text => true
          Integer :agno_inicio
          Integer :agno_termino
          String :palabras_claves, :size => 255
          foreign_key :grupo_id, :grupos, :null => false, :key => [:id]
          foreign_key :administrador_revision, :usuarios, :key => [:id]
          TrueClass :activa, :default => true, :null => false
          String :etapa, :default => "busqueda", :size => 32, :null => false

          index [:administrador_revision], :name => :administrador_revision
          index [:grupo_id], :name => :grupo_id
        end

        # Systematic review taxonomies

        db.create_table? :sr_taxonomies do
          primary_key :id
          String :name # Should be included on locale later
          String :description, :text=>true # Should be included on locale later
        end

        db.create_table? :sr_taxonomy_categories do
          primary_key :id
          foreign_key :srt_id, :sr_taxonomies, :null => false, :key => [:id]
          String :name, :size=>50 # Should be included on locale later
          String :description # Should be included on locale later
          index [:name]
        end


        db.create_table? :systematic_review_srtcs do
          foreign_key :srtc_id, :sr_taxonomy_categories, :null => false, :key => [:id]
          foreign_key :sr_id, :revisiones_sistematicas, :null => false, :key => [:id]
          primary_key [:srtc_id, :sr_id]
        end



        db.create_table? :bases_bibliograficas do
          primary_key :id
          String :nombre, :size => 255
          String :description, :text => true
        end


        db.create_table? :canonicos_documentos do
          primary_key :id
          String :type, :size => 255
          String :title, :text => true
          String :author, :text => true
          String :date, :size => 255
          String :journal, :text => true
          String :volume, :size => 255
          String :number, :size => 255
          String :pages, :size => 255
          String :book_name, :text => true
          String :editors, :text => true
          String :proceedings, :text => true
          String :place, :size => 255
          String :editorial, :size => 255
          String :doi, :size => 255
          String :pubmed, :size => 255
          String :wos_id, :size => 32
          String :scopus_id, :size => 255
          String :ebscohost_id, :size => 255
          Integer :year, :null => false
          String :journal_abbr, :size => 100
          String :abstract, :text => true
          Integer :duplicated
          String :url, :text => true
          String :scielo_id, :size => 255
          String :refworks_id, :size => 255, :null => false
        end

        db.create_table? :canonicos_autores do
          primary_key :id
          String :primer_nombre, :size => 255
          String :segundo_nombre, :size => 255
          String :email, :size => 255
          String :scopus_id, :size => 255
          String :wos_id, :size => 255
        end

        db.create_table? :canonicos_documentos_autores do
          foreign_key :canonico_documento_id, :canonicos_documentos, :null => false, :key => [:id]
          foreign_key :canonico_autor_id, :canonicos_autores, :null => false, :key => [:id]
          String :filiacion, :size => 255
          String :email, :size => 255
          index [:canonico_autor_id], :name => :canonico_autor_id
          primary_key [:canonico_documento_id, :canonico_autor_id]
        end

        db.create_table? :busquedas do
          primary_key :id
          foreign_key :revision_sistematica_id, :revisiones_sistematicas, :null => false, :key => [:id]
          foreign_key :base_bibliografica_id, :bases_bibliograficas, :null => false, :key => [:id]
          Date :fecha
          String :criterio_busqueda, :text => true
          String :descripcion, :text => true
          File :archivo_cuerpo
          String :archivo_tipo, :size => 50
          String :archivo_nombre, :size => 128

          index [:base_bibliografica_id], :name => :base_bibliografica_id
          index [:fecha]
          index [:revision_sistematica_id]
        end

        db.create_table? :registros do
          primary_key :id
          foreign_key :base_bibliografica_id, :bases_bibliograficas, :null => false, :key => [:id]
          String :uid, :size => 255
          String :type, :size => 255
          String :title, :text => true
          String :author, :text => true
          String :date, :size => 255
          String :journal, :text => true
          String :volume, :size => 255
          String :number, :size => 255
          String :pages, :size => 255
          String :book_name, :text => true
          String :editors, :text => true
          String :proceedings, :text => true
          String :place, :size => 255
          String :publisher, :size => 255
          String :doi, :size => 255
          String :pmid, :size => 255
          String :arxiv_id, :size => 255
          foreign_key :canonico_documento_id, :canonicos_documentos, :key => [:id]
          String :journal_abbr, :size => 128
          Integer :year, :null => false
          String :abstract, :text => true
          String :url, :text => true

          index [:base_bibliografica_id]
          index [:canonico_documento_id]
        end

        db.create_table? :referencias do
          String :id, :primary_key => true
          String :texto, :text => true
          String :doi, :size => 255
          foreign_key :canonico_documento_id, :canonicos_documentos, :key => [:id]
          index [:canonico_documento_id], :name => :canonico_documento_id
        end

        db.create_join_table?(:busqueda_id => :busquedas, :registro_id => :registros)
        db.create_join_table?(:referencia_id => {:table => :referencias, :type => String}, :registro_id => :registros)

        db.create_table? :permisos do
          String :id, :size => 50, :primary_key => true
          String :descripcion, :size => 255
        end


        db.create_table? :configuraciones do
          String :id, :primary_key => true
          String :valor, :text => true
        end

        db.create_table? :permisos_roles do
          foreign_key :permiso_id, :permisos, :type => String, :size => 50, :null => false, :key => [:id]
          foreign_key :rol_id, :roles, :type => String, :size => 50, :null => false, :key => [:id]

          primary_key [:permiso_id, :rol_id]

          index [:permiso_id, :rol_id]
          index [:rol_id], :name => :rol_id
        end


        db.create_table? :crossref_queries do
          String :id, :size => 100, :primary_key => true
          String :query, :text => true
          String :json, :text => true
        end


        db.create_table? :crossref_dois do
          String :doi, :size => 100, :primary_key => true
          String :bibtex, :text => true
          String :json, :text => true
        end

        db.create_table? :scopus_abstracts do
          String :id, :primary_key => true
          String :xml, :text => true
          String :doi, :size => 255
        end

        db.create_table? :decisiones do
          foreign_key :revision_sistematica_id, :revisiones_sistematicas, :null => false, :key => [:id]
          foreign_key :usuario_id, :usuarios, :null => false, :key => [:id]
          foreign_key :canonico_documento_id, :canonicos_documentos, :null => false, :key => [:id]
          String :etapa, :size => 32, :null => false
          String :decision, :size => 255
          String :comentario, :text => true

          primary_key [:revision_sistematica_id, :usuario_id, :canonico_documento_id, :etapa]

          index [:canonico_documento_id]
          index [:revision_sistematica_id]
          index [:revision_sistematica_id, :usuario_id, :etapa]
          index [:usuario_id]
        end
        db.create_table? :resoluciones do
          foreign_key :revision_sistematica_id, :revisiones_sistematicas, :null => false, :key => [:id]
          foreign_key :canonico_documento_id, :canonicos_documentos, :null => false, :key => [:id]
          foreign_key :usuario_id, :usuarios, :null => false, :key => [:id]
          String :etapa, :size => 32, :null => false
          String :resolucion, :size => 255
          String :comentario, :text => true

          primary_key [:revision_sistematica_id, :canonico_documento_id, :etapa]

          index [:canonico_documento_id]
          index [:revision_sistematica_id]
          index [:revision_sistematica_id, :canonico_documento_id]
        end

    end
    def self.create_bootstrap_data(db,language='en')
      db.transaction do

        db[:roles].insert(:id=>'administrator',:descripcion=>'App administrator')
        db[:roles].insert(:id=>'analyst',:descripcion=>'App analyst')
        id_admin=db[:usuarios].insert(:login=>'admin',:nombre=>'Administrator', :password=>Digest::SHA1.hexdigest('admin'), :rol_id=>'administrator', :activa=>1, :language=>language)
        id_analyst=db[:usuarios].insert(:login=>'analyst',:nombre=>'Analyst', :password=>Digest::SHA1.hexdigest('analyst'), :rol_id=>'analyst', :activa=>1, :language=>language)
        permits=['acceder_crossref',
          'administracion',
          'archivos_ver',
          'busquedas_revision_ver',
          'busquedas_revision_crear',
          'crossref_acceder',
          'documentos_canonicos_editar',
          'documentos_canonicos_ver',
          'editar_documentos_canonicos',
          'editar_grupos',
          'editar_roles',
          'editar_usuarios',
          'grupos_editar',
          'ingreso',
          'mensajes_ver',
          'primera_revision_ver',
          'referencias_editar',
          'revisiones_administrar',
          'revisiones_editar',
          'revision_analizar_propia',
          'revision_editar',
          'revision_editar_propia',
          'revision_referencias_ver',
          'revision_texto_completo_ver',
          'revision_titulo_resumen_ver',
          'rs_campos_ver',
          'scopus_acceder',
          'tags_ver',
          'ver_revisiones',
          'ver_usuarios']
            permits.each do |permit|
              db[:permisos].insert(:id=>permit)
              db[:permisos_roles].insert(:permiso_id=>permit,:rol_id=>'administrator')
            end

        analyst_permits=["busquedas_revision_ver","documentos_canonicos_ver","revision_analizar_propia","revision_editar_propia", "ver_revisiones"]
        analyst_permits.each do |permit|

          db[:permisos_roles].insert(:permiso_id=>permit,:rol_id=>'analyst')
        end

        # Bibliographic databases

        ["scopus", "wos","scielo","ebscohost", "refworks","generic"].each do |bib_db|
          db[:bases_bibliograficas].insert(:nombre=>bib_db)
        end
        # Taxonomies
        #
        f_id=db[:sr_taxonomies].insert(:name=>"focus")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"practice_or_application")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"theory")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"research_methods")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"research_results")

        f_id=db[:sr_taxonomies].insert(:name=>"objectives")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"critical")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"main_themes")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"integration")
        f_id=db[:sr_taxonomies].insert(:name=>"perspective")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"neutral")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"adoption_of_posture")
        f_id=db[:sr_taxonomies].insert(:name=>"coverage")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"exhaustive")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"exhaustive_with_selection")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"representative")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"essential")
        f_id=db[:sr_taxonomies].insert(:name=>"organization")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"methodology")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"conceptual")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"historic")
        f_id=db[:sr_taxonomies].insert(:name=>"receiver")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"academics_specialist")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"academics_general")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"practicians_politics")
        db[:sr_taxonomy_categories].insert(:srt_id=>f_id, :name=>"general_public")

        grupo_id=db[:grupos].insert(:administrador_grupo=>id_admin, :description=>"First group, just for demostration", :name=>"demo group")
        db[:grupos_usuarios].insert(:grupo_id=>grupo_id, :usuario_id=>id_admin)
        db[:grupos_usuarios].insert(:grupo_id=>grupo_id, :usuario_id=>id_analyst)
      end
    end
  end
end