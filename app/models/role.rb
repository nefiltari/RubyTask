class Role
  include Spira::Resource
  extend Ruta::ClassHelpers
  include Ruta::InstanceHelpers

  base_uri Ruta::Instance["role/"]
  type Ruta::Class.role

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  has_many :rights, predicate: Ruta::Property.has_right, type: :Right

  # Erzeugt eine ID aus einer Rolle
  # role: Name oder Modelinstanz
  def self.get_id params
    return nil unless params[:name]
    return params[:name].get_id if params[:name].class == Role
    params[:name].downcase.gsub(/\s+/,"_")
  end

  # Erzeugt ein neues Role-Model mit angegebenen Namen.
  # Keys: name
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params)
    role = self.for id
    role.name = params[:name]
    role.save!    
    role
  end
end