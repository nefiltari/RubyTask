class Milestone
  include Spira::Resource
  extend Ruta::ClassHelpers
  include Ruta::InstanceHelpers

  base_uri Ruta::Instance["milestone/"]
  type Ruta::Class.milestone

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :description, predicate: Ruta::Property.has_description, type: RDF::XSD.string
  property :created_at, predicate: Ruta::Property.created_at, type: RDF::XSD.dateTime
  property :completed_at, predicate: Ruta::Property.completed_at, type: RDF::XSD.dateTime
  property :project, predicate: Ruta::Property.belongs_to, type: :Project

  # Erzeugt eine ID aus einem Milestone sowie dem dazugehörenden Projekt
  # milestone: Name oder Modelinstanz
  # project: das dazugehörige Projekt als Projekt-Modelinstanz
  def self.get_id params
    if params[:name].class == Milestone
      params[:name].get_id
    else
      return nil unless (project_id = Project.get_id({name: params[:project]}))
      milestone_id = params[:name].downcase.gsub(/\s+/,"_")  
      "#{project_id}/#{milestone_id}"
    end
  end

  # Erzeugt ein neues Milestone-Model mit angegebenen Namen.
  # Keys: name, project
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params)
    ms = self.for id
    ms.name = params[:name]
    ms.created_at = DateTime.now
    ms.project = params[:project]
    ms.save!
    ms
  end
end