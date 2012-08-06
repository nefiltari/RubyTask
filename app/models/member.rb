class Member
  include Spira::Resource

  base_uri Ruta::Instance["member/"]
  type Ruta::Class.member

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :created_at, predicate: Ruta::Property.created_at, type: RDF::XSD.dateTime
  property :realname, predicate: Ruta::Property.has_real_name, type: RDF::XSD.string

  # Gibt alle vergebenen Task, der der Nutzer selbst erstellt hat aus.
  def own_tasks
    uri = uri.self
    query = RDF::Query.new do
      pattern [:task, RDF.type, Ruta::Class.task]
      pattern [:task, Ruta::Property.has_creator, uri]
    end
    tasks = []
    query.execute(Ruta::Repo).each { |sol| tasks.push(sol.task.as(Task)) }
    tasks
  end

  # Gibt alle diesem Nutzer zugewiesenen Tasks aus.
  def work_tasks
    uri = uri.self
    query = RDF::Query.new do
      pattern [:task, RDF.type, Ruta::Class.task]
      pattern [:task, Ruta::Property.has_worker, uri]
    end
    tasks = []
    query.execute(Ruta::Repo).each { |sol| tasks.push(sol.task.as(Task)) }
    tasks
  end

  # Gibt alle Organisationen aus, in denen der Nutzer ein Mitglied ist.
  def organisations
    uri = uri.self
    query = RDF::Query.new do
      pattern [:org, RDF.type, Ruta::Class.organisation]
      pattern [:org, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, uri]
    end
    orgs = []
    query.execute(Ruta::Repo).each { |sol| orgs.push(sol.org.as(Organisation)) }
    orgs
  end

  # Gibt alle Projekte aus, in denen der Nutzer ein Mitglied ist.
  def projects
    uri = uri.self
    query = RDF::Query.new do
      pattern [:proj, RDF.type, Ruta::Class.project]
      pattern [:proj, Ruta::Property.has_member, :mir]
      pattern [:mir, Ruta::Property.member, uri]
    end
    projs = []
    query.execute(Ruta::Repo).each { |sol| projs.push(sol.proj.as(Organisation)) }
    projs
  end

  # Prüft, ob ein Loginname bereits existiert
  # Keys: name
  def self.exist? params
    params[:name] ||= ""
    self.for(self.get_id(params[:name])).exist?
  end

  # Erzeugt eine ID von einem Member
  # member: Name oder Modelinstanz
  def self.get_id member
    return nil unless member
    return member.get_id if member.class == Member
    member.downcase
  end

  # Kurzform zum Wiederherstellen einer Modelinstanz mittels einees Parameterhashs
  # Keys: name
  def self.as params
    params[:name] ||= ""
    self.for self.get_id(params[:name])
  end

  # Ermittelt die ID der Modelinstanz.
  def get_id
    uri.to_s.scan(/\/member\/(.*)$/)[0][0]
  end

  # Erzeugt ein neues Member-Model mit angegebenen name
  # Keys: name
  def self.create params
    params[:name] ||= ""
    member = self.for self.get_id(params[:name])
    member.name = params[:name].capitalize
    member.created_at = DateTime.now
    member.save!
    member
  end
end