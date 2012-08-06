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

require_relative "organisation"
require_relative "member"
require_relative "project"
require_relative "milestone"
require_relative "task"
require_relative "taskstep"
require_relative "role"
require_relative "right"
require_relative "memberinrole"

Ruta.init