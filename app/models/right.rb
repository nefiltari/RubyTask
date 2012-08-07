class Right
  include Spira::Resource
  extend Ruta::ClassHelpers
  include Ruta::InstanceHelpers

  base_uri Ruta::Instance["right/"]
  type Ruta::Class.right

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :description, predicate: Ruta::Property.has_description, type: RDF::XSD.string

  # Erzeugt eine ID aus einem Recht
  # right: Name oder Modelinstanz
  def self.get_id params
    return nil unless params[:name]
    return params[:name].get_id if params[:name].class == Right
    params[:name].downcase.gsub(/\s+/,"_")
  end

  # Erzeugt ein neues Role-Model mit angegebenen Namen.
  # Keys: name
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params)
    right = self.for id
    right.name = params[:name]
    right.save!    
    right
  end
end