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
  Sparql = SPARQL::Client.new(Repo.url.to_s)
  
  module Global
    class << self
      attr_accessor :org, :proj
    end
  end

  module ClassHelpers
    def search token
      cl = self
      query = Ruta::Sparql.select.where(
        [:model, RDF.type, Ruta::Class[cl.to_s.downcase]],
        [:model, (cl == Member) ? Ruta::Property.has_real_name : Ruta::Property.has_name, :name]
      )
      pp query
      results = []
      query.each_solution do |s|
        mname = s.name.to_s
        puts mname
        if (mname =~ /#{token}/i)
          results.push(s.model.as(self))
        end
      end
      results
    end

    def exist? params
      uri = Ruta::Instance["#{self.to_s.downcase}/#{self.get_id(params)}"]
      cl = self
      query = Ruta::Sparql.select.where(
        [uri, RDF.type, Ruta::Class[cl.to_s.downcase]]
      )
      query.each_solution.count >= 1
    end

    # Kurzform zum Wiederherstellen einer Modelinstanz mittels einees Parameterhashs
    def as params
      params[:name] ||= ""
      self.for self.get_id(params)
    end
  end

  module InstanceHelpers
    # Ermittelt die ID der Modelinstanz.
    def get_id
      self.uri.to_s.scan(/\/#{self.class.to_s.downcase}\/(.*)$/)[0][0]
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

    # Roles
    admin = Role.create name: "Administrator"
    right = Right.create name: "All"
    admin.rights.add right
    admin.save!
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