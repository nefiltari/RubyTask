class Taskstep
  include Spira::Resource

  base_uri Ruta::Instance["taskstep/"]
  type Ruta::Class.taskstep

  property :name, predicate: Ruta::Property.has_name, type: RDF::XSD.string
  property :status, predicate: Ruta::Property.has_status, type: RDF::XSD.boolean
  property :task, predicate: Ruta::Property.belongs_to, type: :Task

  # Prüft, ob ein Taskstep bereits existiert
  # taskstep_name: der zu prüfenden Taskstepname im Kontext eines Tasks
  def self.exist? params
    params[:name] ||= ""
    self.for(self.get_id(params[:name], params[:task])).exist?
  end

  # Erzeugt eine ID aus einem Taskstep und einem Task
  # taskstep: Name oder Modelinstanz
  # task: Task-Modelinstanz
  def self.get_id taskstep, task=nil
    return nil unless taskstep
    if taskstep.class == Taskstep
      taskstep.get_id
    else
      return nil unless (task_id = Task.get_id(task))
      taskstep_id = taskstep.downcase.gsub(/\s+/,"_")
      "#{task_id}/#{taskstep_id}"
    end
  end

  # Kurzform zum Wiederherstellen einer Modelinstanz mittels einees Parameterhashs
  # Keys: name, task
  def self.as params
    params[:name] ||= ""
    self.for self.get_id(params[:name], params[:task])
  end

  # Ermittelt die ID der Modelinstanz.
  def get_id
    uri.to_s.scan(/\/taskstep\/(.*)$/)[0][0]
  end

  # Extraktion eines enthaltenen Models.
  def get model=nil
    case model
      when :task
        RDF::URI.new(Ruta::Instance["task/"]+get_id.scan(/^(.+)\//)[0][0]).as(Task)
      when :organisation, :project, :owner, :creator, :target, :worker, :member
        get(:task).get(model)
      else
        self
    end
  end

  # Erzeugt ein neues Taskstep-Model mit angegebenen Namen.
  # taskstep_name: Ein gültiger Taskstepname zb.: "Aufräumen"
  # task: Der zum Taskstep gehörenden Task als Modelinstanz
  def self.create params
    params[:name] ||= ""
    return nil unless id = self.get_id(params[:name], params[:task])
    ts = self.for id
    ts.name = params[:name]
    ts.task = params[:task]
    ts.save!    
    ts
  end
end