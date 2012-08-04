require 'rdf'
require 'rdf/ntriples'
require 'rdf/sesame'
include RDF

Spira.add_repository! :ruta, Sesame::Repository.new("http://localhost:8080/openrdf-sesame/repositories/ruta")

class Organisation

  include Spira::Resource

  base_uri URI.new("http://rubytask.org/")
  default_vocabulary URI.new("http://rubytask.org/")

  property :has_name, type: XSD.String
  property :has_description, type: XSD.String

end