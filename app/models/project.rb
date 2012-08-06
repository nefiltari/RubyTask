class Project
  include Spira::Resource
  extend Ruta::Helpers

  base_uri Ruta::Instance["project/"]
  type Ruta::Class.project

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :description, predicate: Ruta::Property.has_description, type: RDF::XSD.string
  property :created_at, predicate: Ruta::Property.created_at, type: RDF::XSD.dateTime
  has_many :members, predicate: Ruta::Property.has_member, type: :MemberInRole
  property :organisation, predicate: Ruta::Property.belongs_to, type: :Organisation

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

  # Gibt alle Tasks aus, die innerhalb des aktuellen Projekts definiert sind.
  def tasks
    uri = self.uri
    query = RDF::Query.new do
      pattern [:task, RDF.type, Ruta::Class.task]
      pattern [:task, Ruta::Property.belongs_to, uri]
    end
    tasks = []
    query.execute(Ruta::Repo).each { |sol| tasks.push(sol.milestone.as(Milestone)) }
    tasks
  end

  # Du zu einem Projekt gehörenden Milstones als Modelinstanz-Array
  def milestones
    uri = self.uri
    query = RDF::Query.new do
      pattern [:milestone, RDF.type, Ruta::Class.milestone]
      pattern [:milestone, Ruta::Property.belongs_to, uri]
    end
    mss = []
    query.execute(Ruta::Repo).each { |sol| mss.push(sol.milestone.as(Milestone)) }
    mss
  end

  # Prüft ob ein Benutzer im aktuellen Kontext (Projekt) im Besitz eines Rechtes ist
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
    query = RDF::Query.new do
      pattern [uri, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, member.uri]
    end
    proj = self
    query.execute(Ruta::Repo).each do |s|
      proj.members.each do |o|
        proj.members = proj.members.delete(o) if o.uri == s.mir
      end
      proj.save!
      s.mir.as(MemberInRole).destroy!
    end
  end

  # Prüft, ob ein Benutzer ein Mitglied des Projektes ist.
  # member: Die Member-Modelinstanz des Benutzers
  def exist_member? member
    uri = self.uri
    query = RDF::Query.new do
      pattern [uri, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, member.uri]
    end
    query.execute(Ruta::Repo).count >= 1
  end

  # Prüft, ob ein Projektname bereits existiert
  # Keys: name, organisation
  def self.exist? params
    params[:name] ||= ""
    self.for(self.get_id(params[:name], params[:organisation])).exist?
  end

  # Erzeugt eine ID aus einem Projekt und der dazugehörenden Organisation.
  # project: Name oder Modelinstanz
  # organisation: die dazugehörige Organisation als Organisation-Modelinstanz
  def self.get_id project, organisation=nil
    return nil unless project
    if project.class == Project
      project.get_id
    else
      return nil unless (org_id = Organisation.get_id(organisation))
      proj_id = project.downcase.gsub(/\s+/,"_")
      "#{org_id}/#{proj_id}"
    end
  end

  # Kurzform zum Wiederherstellen einer Modelinstanz mittels einees Parameterhashs
  # Keys: name, organisation
  def self.as params
    params[:name] ||= ""
    self.for self.get_id(params[:name], params[:organisation])
  end

  # Ermittelt die ID der Modelinstanz.
  def get_id
    uri.to_s.scan(/\/project\/(.*)$/)[0][0]
  end

  # Erzeugt ein neues Project-Model mit angegebenen Namen.
  # Keys: name, organisation
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params[:name], params[:organisation])
    proj = self.for id
    proj.name = params[:name]
    proj.created_at = DateTime.now
    proj.organisation = params[:organisation]
    proj.save!
    proj
  end
end