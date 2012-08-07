class MemberInRole
  include Spira::Resource
  include Ruta::InstanceHelpers
  extend Ruta::ClassHelpers

  base_uri Ruta::Instance["memberinrole"]
  type Ruta::Class.memberinrole

  property :member, predicate: Ruta::Property.member, type: :Member
  property :role, predicate: Ruta::Property.role, type: :Role

  # Erzeugt eine ID aus einem Recht
  # right: Name oder Modelinstanz
  def self.get_id params
    return nil unless (member_id = Member.get_id({name: params[:member]})) && (role_id = Role.get_id({name: params[:role]}))
    "#{role_id}/#{member_id}"
  end

  # Erzeugt ein neues Role-Model mit angegebenen Namen.
  # Keys: name
  def self.create params
    return nil unless id = self.get_id(params)
    mir = self.for id
    mir.member = params[:member]
    mir.role = params[:role]
    mir.save!  
    mir
  end
end