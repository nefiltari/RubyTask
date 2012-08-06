class Task
  include Spira::Resource
  extend Ruta::Helpers

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

  # Prüft, ob ein Task bereits existiert
  # Keys: name, project, owner, target
  def self.exist? params
    params[:name] ||= ""
    self.for(self.get_id(params[:name], params[:project], params[:owner], params[:target])).exist?
  end

  # Erzeugt eine ID aus einem Task sowie dem dazugehörenden Projekt, Eigentümer und einem optionalen Ziel
  # task: Name oder Modelinstanz
  # project: Project-Modelinstanz des Tasks
  # owner: Eingentümer des Tasks als Member-Modelinstanz
  # target (optional): Bearbeiter des Tasks als Member-Modelinstanz (nil für Shared-Tasks)
  def self.get_id task, project=nil, owner=nil, target=nil
    return nil unless task
    if task.class == Task
      task.get_id
    else
      return nil unless (project_id = Project.get_id(project)) && (owner_id = Member.get_id(owner))
      task_id = task.downcase.gsub(/\s+/,"_")
      target_id = (target.class == Member) ? "/#{target.get_id}" : ""
      "#{project_id}/#{owner_id}/#{task_id}#{target_id}"
    end
  end

  # Kurzform zum Wiederherstellen einer Modelinstanz mittels einees Parameterhashs
  # Keys: name, project, owner, target
  def self.as params
    params[:name] ||= ""
    self.for self.get_id(params[:name], params[:project], params[:owner], params[:target])
  end

  # Ermittelt die ID der Modelinstanz.
  def get_id
    uri.to_s.scan(/\/task\/(.*)$/)[0][0]
  end

  # Erzeugt ein neues Task-Model mit angegebenen Namen.
  # Keys: name, project, owner, target
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params[:name], params[:project], params[:owner], params[:target])
    task = self.for id
    task.name = params[:name]
    task.created_at = DateTime.now
    task.creator = params[:owner] if params[:owner].class == Member
    task.workers = [params[:target]] if params[:target].class == Member
    task.project = params[:project]
    task.save!
    task
  end
end