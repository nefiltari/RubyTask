module Spira
  def settings
    @settings ||= {}
  end
  module_function :settings
end

Spira.add_repository! :default, RDF::Sesame::Repository.new("http://localhost:8080/openrdf-sesame/repositories/ruta")

class Ruta < RDF::Vocabulary("http://rubytask.org/")
  Property = RDF::Vocabulary.new("#{Ruta}property/")
  Instance = RDF::Vocabulary.new("#{Ruta}instance/")
  Class = RDF::Vocabulary.new("#{Ruta}class/")
  Right = RDF::Vocabulary.new("#{Instance}right/")
  Role = RDF::Vocabulary.new("#{Instance}role/")
  Repo = Spira.repository :default
  
  module Global
    class << self
      attr_accessor :org, :proj
    end
  end

  module Helpers
    def search token
      cl = self
      query = RDF::Query.new do
        pattern [:model, RDF.type, Ruta::Class[cl.to_s.downcase]]          
      end
      results = []
      query.execute(Ruta::Repo).each do |s|
        if (s.model.as(self).name =~ /#{token}/i)
          results.push(s.model.as(self))
        end
      end
      results
    end
  end

  def self.init
    Global.org = if Organisation.exist? name: "<global>"
      Organisation.as name: "<global>"
    else
      Organisation.create name: "<global>"
    end
    Global.org.description = "This is the <global> Organisation for projectless Tasks"
    Global.proj = if Project.exist? name: "<global>", organisation: Global.org
      Project.as name: "<global>", organisation: Global.org
    else
      Project.create name: "<global>", organisation: Global.org
    end
    Global.proj.description = "This is the <global> Project for projectless Tasks"

    Global.org.save!
    Global.proj.save!
  end
end

class DateTime
  include Spira::Type

  def self.unserialize(value)
    value.object
  end

  def self.serialize(value)
    RDF::Literal::DateTime.new(value)
  end

  register_alias RDF::XSD.dateTime
end

#Ruta.init