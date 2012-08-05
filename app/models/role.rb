class Role
  include Spira::Resource

  base_uri Ruta::Instance["role/"]
  type Ruta::Class.role

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  has_many :rights, predicate: Ruta::Property.has_right, type: :Right

  # Prüft, ob eine Rolle bereits existiert
  # role_name: der zu prüfenden Rollenname
  def self.exist? params
    params[:name] ||= ""
    self.for(self.get_id(params[:name])).exist?
  end

  # Erzeugt eine ID aus einer Rolle
  # role: Name oder Modelinstanz
  def self.get_id role
    return nil unless role
    return role.get_id if role.class == Role
    role.downcase.gsub(/\s+/,"_")
  end

  # Kurzform zum Wiederherstellen einer Modelinstanz mittels einees Parameterhashs
  # Keys: name
  def self.as params
    params[:name] ||= ""
    self.for self.get_id(params[:name])
  end

  # Ermittelt die ID der Modelinstanz.
  def get_id
    uri.to_s.scan(/\/role\/(.*)$/)[0][0]
  end

  # Extraktion eines enthaltenen Models.
  def get model=nil
    self
  end

  # Erzeugt ein neues Role-Model mit angegebenen Namen.
  # role_name: Ein gültiger Rollenname zb.: "Administrator"
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params[:name])
    role = self.for id
    role.name = params[:name]
    role.save!    
    role
  end
end