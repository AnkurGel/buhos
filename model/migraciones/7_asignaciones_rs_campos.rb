# Agrega asignaciones y campos de llenado para revisión sistemática

Sequel.migration do
  change do
    create_table(:asignaciones_cds) do
      foreign_key :revision_sistematica_id, :revisiones_sistematicas, :null=>false, :key=>[:id]
      foreign_key :canonico_documento_id, :canonicos_documentos, :null=>false, :key=>[:id]
      foreign_key :usuario_id, :usuarios, :null=>false, :key=>[:id]
      String :etapa, :size=>50, :null=>true
      String      :instruccion
      String      :estado
      primary_key [:revision_sistematica_id, :canonico_documento_id,:usuario_id]
    end
    create_table(:rs_campos) do
      primary_key :id
      foreign_key :revision_sistematica_id, :revisiones_sistematicas, :null=>false, :key=>[:id]
      Integer :orden
      String :nombre
      String :descripcion
      String :tipo
      String :opciones, :text=>true
      unique [:revision_sistematica_id, :nombre]
    end
  end
end