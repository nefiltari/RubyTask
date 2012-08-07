class Organisation
  include Spira::Resource
  extend Ruta::ClassHelpers
  include Ruta::InstanceHelpers

  base_uri Ruta::Instance["organisation/"]
  type Ruta::Class.organisation

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :description, predicate: Ruta::Property.has_description, type: RDF::XSD.string
  property :created_at, predicate: Ruta::Property.created_at, type: RDF::XSD.dateTime
  has_many :members, predicate: Ruta::Property.has_member, type: :MemberInRole

  # Gibt das Role-Model des Benutzers in der aktuellen Organisation aus
  # member: Die Member-Modelinstanz des Benutzers
  def my_role member
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [uri, Ruta::Property.has_member, :mir],
      [:mir, Ruta::Property.member, member.uri],
      [:mir, Ruta::Property.role, :role]
    )
    role = nil
    query.each_solution { |sol| role = sol.role.as(Role) }
    role
  end

  # Prüft ob ein Benutzer im aktuellen Kontext (Organisation) im Besitz eines Rechtes ist
  # member: Die Member-Modelinstanz des Benutzers
  # right: Das zu prüfende Recht als RDF::URI oder Modelinstanz
  def member_in_right? member, right
    uri = self.uri
    right = right.uri if right.class == Right
    query = Ruta::Sparql.select.where(
      [uri, Ruta::Property.has_member, :mir],
      [:mir, Ruta::Property.member, member.uri],
      [:mir, Ruta::Property.role, :role],
      [:role, Ruta::Property.has_right, right]
    )
    query.each_solution.count >= 1
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
    query = Ruta::Sparql.select.where(
      [uri, Ruta::Property.has_member, :mir],
      [:mir, Ruta::Property.member, member.uri]
    )
    org = self
    query.each_solution do |s|
      org.members.each do |o|
        org.members = org.members.delete(o) if o.uri == s.mir
      end
      org.save!
      #s.mir.as(MemberInRole).destroy!
    end
  end

  # Prüft, ob ein Benutzer ein Mitglied der Organisation ist.
  # member: Die Member-Modelinstanz des Benutzers
  def exist_member? member
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [uri, Ruta::Property.has_member, :mir],
      [:mir, Ruta::Property.member, member.uri]
    )
    query.each_solution.count >= 1
  end

  # Erzeugt eine ID aus einer Organisation
  # organisation: Name oder Modelinstanz
  def self.get_id params
    return nil unless params[:name]
    return params[:name].get_id if params[:name].class == Organisation
    params[:name].downcase.gsub(/\s+/,"_")
  end

  # Erzeugt ein neues Organisation-Model mit angegebenen Namen.
  # name: Ein Name ohne unterstriche oder anderen Konvertierungen zb.: "Meine Organisation"
  # Keys: name
  def self.create params
    params[:name] ||= ""
    org = self.for self.get_id(params)
    org.name = params[:name]
    org.created_at = DateTime.now
    org.save!
    org
  end
end