module TasksHelper
  def self.priority_names priority
    case priority
      when 1
        "unimportant"
      when 2
        "less important"
      when 3
        "normal"
      when 4
        "important"
      when 5
        "very important"
    end
  end
end
