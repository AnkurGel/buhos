# Copyright (c) 2016-2018, Claudio Bustos Navarrete
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class CanonicalDocument < Sequel::Model
  # Corresponde a las references que tienen como canónico a este objeto
  one_to_many :references
  one_to_many :records

  include ReferenceMethods
  # Cada documento genérico realiza references. ¿A quién las hace?

  def references_performed
    ids=$db["SELECT ref.id FROM records r INNER JOIN records_references rr ON r.id=rr.record_id INNER JOIN bib_references ref ON rr.reference_id=ref.id WHERE r.canonical_document_id=?", self[:id]].map(:id)
    Reference.where(:id => ids)
  end

  # Une los documentos canonicos, de acuerdo al id
  def self.unir(pks)
    pk_id=pks[0]
    pk_otros=pks[1...pks.length]
    resultado=true
    $db.transaction(:rollback => :reraise) do
      columnas=CanonicalDocument.columns
      columnas.delete(:id)

      cds=CanonicalDocument.where(:id => pks)
      fields=columnas.inject({}) {|ac, v| ac[v]=nil; ac}
      cds.each do |cd|
        columnas.find_all {|col| fields[col].nil? or fields[col]==""}.each {|col|
          fields[col]=cd[col]
        }
      end
      CanonicalDocument[pk_id].update(fields)
      Record.where(:canonical_document_id => pks).update(:canonical_document_id => pk_id)
      Reference.where(:canonical_document_id => pks).update(:canonical_document_id => pk_id)
      $db[:canonical_documents_autores].where(:canonical_document_id => pks).update(:canonical_document_id => pk_id)
      CanonicalDocument.where(:id => pk_otros).delete
      $db.after_rollback {
        resultado=false
      }
    end
    resultado
  end

  def crossref_integrator
    if self.doi
      CrossrefDoi.reference_integrator_json(self.doi)
    else
      false
    end
  end
  def buscar_references_similares(d=nil,sin_canonico=true)
     begin
      require 'levenshtein-ffi'
    rescue LoadError
      require 'levenshtein'
    end
    d_max=[ref_apa_6.length,self[:title].length].max

    d=d_max if d.nil? or d>d_max
    canonico_sql= sin_canonico ? " OR canonical_document_id IS NULL ": ""

    distancias=Reference.where(Sequel.lit("canonical_document_id!='#{self[:id]}' #{canonico_sql}")).map {|v|
      dis_apa_6=Levenshtein.distance(v[:text],ref_apa_6)
      dis_solo_titulo=Levenshtein.distance(v[:text],self[:title])
      distancia=[dis_apa_6,dis_solo_titulo].min
      {
          :id=>v[:id],
          :canonical_document_id=>v[:canonical_document_id],
          :text=>v[:text],
          :distancia=>distancia
      }

    }
    if !d.nil?
      distancias=distancias.find_all {|v| v[:distancia]<=d}
    end
    distancias.sort {|a,b| a[:distancia]<=>b[:distancia]}
  end

end