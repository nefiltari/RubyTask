class Member
  include Spira::Resource
  extend Ruta::ClassHelpers
  include Ruta::InstanceHelpers

  base_uri Ruta::Instance["member/"]
  type Ruta::Class.member

  property :name, predicate: RDF::FOAF.nick, type: RDF::XSD.string
  property :created_at, predicate: Ruta::Property.created_at, type: RDF::XSD.dateTime
  property :realname, predicate: RDF::FOAF.name, type: RDF::XSD.string
  property :avatar, predicate: RDF::FOAF.img, type: Spira::Types::URI
  has_many :friends, predicate: RDF::FOAF.knows, type: :Member

  # Gibt alle Freunde als formatiertes Hash-Array aus
  def friends_formatted
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [uri, RDF::FOAF.knows, :friend],
      [:friend, RDF::FOAF.name, :realname]
    )
    nfriends = []
    query.each_solution { |sol| nfriends.push({id: sol.friend.as(Member).get_id, realname: sol.realname.to_s}) }
    nfriends
  end

  # Gibt alle vergebenen Task, der der Nutzer selbst erstellt hat aus.
  def own_tasks
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [:task, RDF.type, Ruta::Class.task],
      [:task, Ruta::Property.has_creator, uri]
    )
    tasks = []
    query.each_solution { |sol| tasks.push(sol.task.as(Task)) }
    tasks
  end

  # Gibt alle diesem Nutzer zugewiesenen Tasks aus.
  def work_tasks
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [:task, RDF.type, Ruta::Class.task],
      [:task, Ruta::Property.has_worker, uri]
    )
    tasks = []
    query.each_solution { |sol| tasks.push(sol.task.as(Task)) }
    tasks
  end

  # Gibt alle Organisationen aus, in denen der Nutzer ein Mitglied ist.
  def organisations
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [:org, RDF.type, Ruta::Class.organisation],
      [:org, RDF::FOAF.member, :mir],
      [:mir, Ruta::Property.has_member, uri]
    )
    orgs = []
    query.each_solution { |sol| orgs.push(sol.org.as(Organisation)) }
    orgs
  end

  # Gibt alle Projekte aus, in denen der Nutzer ein Mitglied ist.
  def projects
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [:proj, RDF.type, Ruta::Class.project],
      [:proj, RDF::FOAF.member, :mir],
      [:mir, Ruta::Property.has_member, uri]
    )
    projs = []
    query.each_solution { |sol| projs.push(sol.proj.as(Organisation)) }
    projs
  end

  # Erzeugt eine ID von einem Member
  def self.get_id params
    return nil unless params[:name]
    return params[:name].get_id if params[:name].class == Member
    params[:name].downcase
  end

  # Erzeugt ein neues Member-Model mit angegebenen name
  # Keys: name
  def self.create params
    params[:name] ||= ""
    member = self.for self.get_id(params)
    member.name = params[:name].capitalize
    member.created_at = DateTime.now
    member.save!
    member
  end
end