class MemberInRole
  include Spira::Resource

  base_uri Ruta::Instance["memberinrole"]
  type Ruta::Class.memberinrole

  property :member, predicate: Ruta::Property.member, type: :Member
  property :role, predicate: Ruta::Property.role, type: :Role

  # Prüft, ob das Recht bereits existiert
  # Keys: name
  def self.exist? params
    params[:name] ||= ""
    self.for(self.get_id(params[:name])).exist?
  end

  # Erzeugt eine ID aus einem Recht
  # right: Name oder Modelinstanz
  def self.get_id member, role
    return nil unless (member_id = Member.get_id(member)) && (role_id = Role.get_id(role))
    "#{role_id}/#{member_id}"
  end

  # Kurzform zum Wiederherstellen einer Modelinstanz mittels einees Parameterhashs
  # Keys: name
  def self.as params
    self.for self.get_id(params[:member], params[:role])
  end

  # Ermittelt die ID der Modelinstanz.
  def get_id
    uri.to_s.scan(/\/memberinrole\/(.*)$/)[0][0]
  end

  # Erzeugt ein neues Role-Model mit angegebenen Namen.
  # Keys: name
  def self.create params
    return nil unless id = self.get_id(params[:member], params[:role])
    mir = self.for id
    mir.member = params[:member]
    mir.role = params[:role]
    mir.save!  
    mir
  end
end