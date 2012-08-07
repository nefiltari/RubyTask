class Task
  include Spira::Resource
  extend Ruta::ClassHelpers
  include Ruta::InstanceHelpers

  base_uri Ruta::Instance["task/"]
  type Ruta::Class.task

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :description, predicate: Ruta::Property.has_description, type: RDF::XSD.string
  property :priority, predicate: Ruta::Property.has_priority, type: RDF::XSD.integer
  property :creator, predicate: Ruta::Property.has_creator, type: :Member
  property :status, predicate: Ruta::Property.has_status, type: RDF::XSD.string
  property :created_at, predicate: Ruta::Property.created_at, type: RDF::XSD.dateTime
  property :completed_at, predicate: Ruta::Property.completed_at, type: RDF::XSD.dateTime
  property :project, predicate: Ruta::Property.belongs_to, type: :Project
  has_many :workers, predicate: Ruta::Property.has_worker, type: :Member

  def is_worker? member
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [uri, Ruta::Property.has_worker, member.uri]
    )
    query.each_statement.count >= 1
  end

  def tasksteps
    uri = self.uri
    query = Ruta::Sparql.select.where(
      [:taskstep, RDF.type, Ruta::Class.taskstep],
      [:taskstep, Ruta::Property.belongs_to, uri]
    )
    tasksteps = []
    query.each_solution { |sol| tasksteps.push(sol.taskstep.as(Milestone)) }
    tasksteps
  end

  # Erzeugt eine ID aus einem Task sowie dem dazugehörenden Projekt, Eigentümer und einem optionalen Ziel
  # task: Name oder Modelinstanz
  # project: Project-Modelinstanz des Tasks
  # owner: Eingentümer des Tasks als Member-Modelinstanz
  # target (optional): Bearbeiter des Tasks als Member-Modelinstanz (nil für Shared-Tasks)
  def self.get_id params
    return nil unless params[:name]
    if params[:name].class == Task
      params[:name].get_id
    else
      return nil unless (project_id = Project.get_id({name: params[:project]})) && (owner_id = Member.get_id({name: params[:owner]}))
      task_id = params[:name].downcase.gsub(/\s+/,"_")
      target_id = (params[:target].class == Member) ? "/#{params[:target].get_id}" : ""
      "#{project_id}/#{owner_id}/#{task_id}#{target_id}"
    end
  end

  # Erzeugt ein neues Task-Model mit angegebenen Namen.
  # Keys: name, project, owner, target
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params)
    task = self.for id
    task.name = params[:name]
    task.created_at = DateTime.now
    task.creator = params[:owner] if params[:owner].class == Member
    task.workers = [params[:target]] if params[:target].class == Member
    task.project = params[:project]
    task.status = "new"
    task.save!
    task
  end
end