require 'rdf'
require 'rdf/ntriples'
require 'rdf/sesame'
require 'spira'


Spira.add_repository! :default, RDF::Sesame::Repository.new("http://localhost:8080/openrdf-sesame/repositories/ruta")

class Organisation

  include Spira::Resource

  base_uri RDF::URI.new("http://rubytask.org/")
  default_vocabulary RDF::URI.new("http://rubytask.org/")

  property :has_name, type: RDF::XSD.string
  property :has_description, type: RDF::XSD.string

end