class Taskstep
  include Spira::Resource
  extend Ruta::ClassHelpers
  include Ruta::InstanceHelpers

  base_uri Ruta::Instance["taskstep/"]
  type Ruta::Class.taskstep

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :status, predicate: Ruta::Property.has_status, type: RDF::XSD.boolean
  property :task, predicate: Ruta::Property.belongs_to, type: :Task

  # Erzeugt eine ID aus einem Taskstep und einem Task
  # taskstep: Name oder Modelinstanz
  # task: Task-Modelinstanz
  def self.get_id params
    return nil unless params[:name]
    if params[:name].class == Taskstep
      params[:name].get_id
    else
      return nil unless (task_id = Task.get_id(params[:task]))
      taskstep_id = params[:name].downcase.gsub(/\s+/,"_")
      "#{task_id}/#{taskstep_id}"
    end
  end

  # Erzeugt ein neues Taskstep-Model mit angegebenen Namen.
  # taskstep_name: Ein gültiger Taskstepname zb.: "Aufräumen"
  # task: Der zum Taskstep gehörenden Task als Modelinstanz
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params)
    ts = self.for id
    ts.name = params[:name]
    ts.task = params[:task]
    ts.save!    
    ts
  end
end