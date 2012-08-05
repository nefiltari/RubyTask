class Project
  include Spira::Resource

  base_uri Ruta::Instance["project/"]
  type Ruta::Class.project

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :description, predicate: Ruta::Property.has_description, type: RDF::XSD.string
  property :created_at, predicate: Ruta::Property.created_at, type: RDF::XSD.dateTime
  has_many :members, predicate: Ruta::Property.has_member, type: :MemberInRole
  property :organisation, predicate: Ruta::Property.belongs_to, type: :Organisation

  def my_role member
    uri = self.uri
    query = RDF::Query.new do
      pattern [uri, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, member.uri]
      pattern [:mir, Ruta::Property.role, :role]
    end
    role
    query.execute(Ruta::Repo).each do |sol|
      role = sol.role.as(Role)
    end
    role
  end

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

  def add_member member, role
    return if exist_member? member
    role = role.as(Role) unless role.class == Role
    mir = MemberInRole.create member: member, role: role
    members.add mir
    save!
  end

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

  def exist_member? member
    uri = self.uri
    query = RDF::Query.new do
      pattern [uri, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, member.uri]
    end
    query.execute(Ruta::Repo).count >= 1
  end

  # Prüft, ob ein Projektname bereits existiert
  # organisation: der zu prüfenden Projektname im Kontext von Organisation
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
  # project_name: Ein gültiger Projektname zb.: "Mein erstes Projekt"
  # organisation: die dazugehörige Organisation als Organisation-Modelinstanz
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