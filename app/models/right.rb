class Right
  include Spira::Resource

  base_uri Ruta::Instance["right/"]
  type Ruta::Class.right

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :description, predicate: Ruta::Property.has_description, type: RDF::XSD.string

  # Prüft, ob das Recht bereits existiert
  # right_name: der zu prüfenden Rechtename
  def self.exist? params
    params[:name] ||= ""
    self.for(self.get_id(params[:name])).exist?
  end

  # Erzeugt eine ID aus einem Recht
  # right: Name oder Modelinstanz
  def self.get_id right
    return nil unless right
    return right.get_id if right.class == Right
    right.downcase.gsub(/\s+/,"_")
  end

  # Kurzform zum Wiederherstellen einer Modelinstanz mittels einees Parameterhashs
  # Keys: name
  def self.as params
    params[:name] ||= ""
    self.for self.get_id(params[:name])
  end

  # Ermittelt die ID der Modelinstanz.
  def get_id
    uri.to_s.scan(/\/right\/(.*)$/)[0][0]
  end

  # Erzeugt ein neues Role-Model mit angegebenen Namen.
  # Keys: name
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params[:name])
    right = self.for id
    right.name = params[:name]
    right.save!    
    right
  end
end