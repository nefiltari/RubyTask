class Project
  include Spira::Resource
  extend Ruta::ClassHelpers
  include Ruta::InstanceHelpers

  base_uri Ruta::Instance["project/"]
  type Ruta::Class.project

  property :name, predicate: RDF::FOAF.name, type: RDF::XSD.string
  property :description, predicate: Ruta::Property.has_description, type: RDF::XSD.string
  property :created_at, predicate: Ruta::Property.created_at, type: RDF::XSD.dateTime
  has_many :members, predicate: RDF::FOAF.member, type: :MemberInRole
  property :organisation, predicate: Ruta::Property.belongs_to, type: :Organisation

  # Gibt das Role-Model des Benutzers im aktuellen Projekt aus
  # member: Die Member-Modelinstanz des Benutzers
  def my_role member
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [uri, RRDF::FOAF.member, :mir],
      [:mir, Ruta::Property.has_member, member.uri],
      [:mir, Ruta::Property.has_role, :role]
    )
    role = nil
    query.each_solution { |sol| role = sol.role.as(Role) }
    role
  end

  # Gibt alle Tasks aus, die innerhalb des aktuellen Projekts definiert sind.
  def tasks
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [:task, RDF.type, Ruta::Class.task],
      [:task, Ruta::Property.belongs_to, uri]
    )
    tasks = []
    query.each_solution { |sol| tasks.push(sol.milestone.as(Milestone)) }
    tasks
  end

  # Du zu einem Projekt gehörenden Milstones als Modelinstanz-Array
  def milestones
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [:milestone, RDF.type, Ruta::Class.milestone],
      [:milestone, Ruta::Property.belongs_to, uri]
    )
    mss = []
    query.each_solution { |sol| mss.push(sol.milestone.as(Milestone)) }
    mss
  end

  # Prüft ob ein Benutzer im aktuellen Kontext (Projekt) im Besitz eines Rechtes ist
  # member: Die Member-Modelinstanz des Benutzers
  # right: Das zu prüfende Recht als RDF::URI oder Modelinstanz
  def member_in_right? member, right
    uri = self.uri
    right = right.uri if right.class == Right
    query = Ruta::Sparql.select.where(
      [uri, RDF::FOAF.member, :mir],
      [:mir, Ruta::Property.has_member, member.uri],
      [:mir, Ruta::Property.has_role, :role],
      [:role, Ruta::Property.has_right, right]
    )
    query.each_solution.count >= 1
  end

  # Fügt ein neues Mitglied mit einer entsprechenden Rolle zum Projekt hinzu.
  # member: Die Member-Modelinstanz des neuen Mitglieds
  # role: Die Rolle, die der Nutzer einnehmen soll als RDF::URI oder Modelinstanz
  def add_member member, role
    return if exist_member? member
    role = role.as(Role) unless role.class == Role
    mir = MemberInRole.create member: member, role: role
    members.add mir
    save!
  end

  # Löscht ein Mitglied inklusive der Rolle aus dem Projekt
  # member: Die Member-Modelinstanz des Mitglieds
  def delete_member member
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [uri, RDF::FOAF.member, :mir],
      [:mir, Ruta::Property.has_member, member.uri]
    )
    proj = self
    query.each_solution do |s|
      proj.members.each do |o|
        proj.members = proj.members.delete(o) if o.uri == s.mir
      end
      proj.save!
      #s.mir.as(MemberInRole).destroy!
    end
  end

  # Prüft, ob ein Benutzer ein Mitglied des Projektes ist.
  # member: Die Member-Modelinstanz des Benutzers
  def exist_member? member
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [uri, RDF::FOAF.member, :mir],
      [:mir, Ruta::Property.has_member, member.uri]
    )
    query.each_solution.count >= 1
  end

  # Erzeugt eine ID aus einem Projekt und der dazugehörenden Organisation.
  # project: Name oder Modelinstanz
  # organisation: die dazugehörige Organisation als Organisation-Modelinstanz
  def self.get_id params
    return nil unless params[:name]
    if params[:name].class == Project
      params[:name].get_id
    else
      return nil unless (org_id = Organisation.get_id({name: params[:organisation]}))
      proj_id = params[:name].downcase.gsub(/\s+/,"_")
      "#{org_id}/#{proj_id}"
    end
  end

  # Erzeugt ein neues Project-Model mit angegebenen Namen.
  # Keys: name, organisation
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params)
    proj = self.for id
    proj.name = params[:name]
    proj.created_at = DateTime.now
    proj.organisation = params[:organisation]
    proj.save!
    proj
  end
end