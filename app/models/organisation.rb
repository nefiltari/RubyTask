class Organisation
  include Spira::Resource
  extend Ruta::Helpers

  base_uri Ruta::Instance["organisation/"]
  type Ruta::Class.organisation

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :description, predicate: Ruta::Property.has_description, type: RDF::XSD.string
  property :created_at, predicate: Ruta::Property.created_at, type: RDF::XSD.dateTime
  has_many :members, predicate: Ruta::Property.has_member, type: :MemberInRole

  # Gibt das Role-Model des Benutzers im aktuellen Projekt aus
  # member: Die Member-Modelinstanz des Benutzers
  def my_role member
    uri = self.uri
    query = RDF::Query.new do
      pattern [uri, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, member.uri]
      pattern [:mir, Ruta::Property.role, :role]
    end
    role = nil
    query.execute(Ruta::Repo).each { |sol| role = sol.role.as(Role) }
    role
  end

  # Prüft ob ein Benutzer im aktuellen Kontext (Organisation) im Besitz eines Rechtes ist
  # member: Die Member-Modelinstanz des Benutzers
  # right: Das zu prüfende Recht als RDF::URI oder Modelinstanz
  def member_in_right? member, right
    uri = self.uri
    right = right.uri if right.class == Right
    query = RDF::Query.new do
      pattern [uri, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, member.uri]
      pattern [:mir, Ruta::Property.role, :role]
      pattern [:role, Ruta::Property.has_right, right]
    end
    query.execute(Ruta::Repo).count >= 1
  end

  # Fügt ein neues Mitglied mit einer entsprechenden Rolle zur Organisation hinzu.
  # member: Die Member-Modelinstanz des neuen Mitglieds
  # role: Die Rolle, die der Nutzer einnehmen soll als RDF::URI oder Modelinstanz
  def add_member member, role
    return if exist_member? member
    role = role.as(Role) unless role.class == Role
    mir = MemberInRole.create member: member, role: role
    members.add mir
    save!
  end

  # Löscht ein Mitglied inklusive der Rolle aus der Organisation
  # member: Die Member-Modelinstanz des Mitglieds
  def delete_member member
    uri = self.uri
    query = RDF::Query.new do
      pattern [uri, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, member.uri]
    end
    org = self
    query.execute(Ruta::Repo).each do |s|
      org.members.each do |o|
        org.members = org.members.delete(o) if o.uri == s.mir
      end
      org.save!
      s.mir.as(MemberInRole).destroy!
    end
  end

  # Prüft, ob ein Benutzer ein Mitglied der Organisation ist.
  # member: Die Member-Modelinstanz des Benutzers
  def exist_member? member
    uri = self.uri
    query = RDF::Query.new do
      pattern [uri, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, member.uri]
    end
    query.execute(Ruta::Repo).count >= 1
  end

  # Prüft ob der Organisationsname bereits vorhanden ist
  # Keys: name
  def self.exist? params
    params[:name] ||= ""
    self.for(self.get_id(params[:name])).exist?
  end

  # Erzeugt eine ID aus einer Organisation
  # organisation: Name oder Modelinstanz
  def self.get_id organisation
    return nil unless organisation
    return organisation.get_id if organisation.class == Organisation
    organisation.downcase.gsub(/\s+/,"_")
  end

  # Kurzform zum Wiederherstellen einer Modelinstanz mittels einees Parameterhashs
  # Keys: name
  def self.as params
    params[:name] ||= ""
    self.for self.get_id(params[:name])
  end

  # Ermittelt die ID der Modelinstanz.
  def get_id
    uri.to_s.scan(/\/organisation\/(.*)$/)[0][0]
  end

  # Erzeugt ein neues Organisation-Model mit angegebenen Namen.
  # name: Ein Name ohne unterstriche oder anderen Konvertierungen zb.: "Meine Organisation"
  # Keys: name
  def self.create params
    params[:name] ||= ""
    org = self.for self.get_id(params[:name])
    org.name = params[:name]
    org.created_at = DateTime.now
    org.save!
    org
  end
end