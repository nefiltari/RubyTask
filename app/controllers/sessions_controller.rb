class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
    session[:user] = auth_hash[:uid]

    member = nil
    if Member.exist? name: auth_hash[:uid]
      member = Member.as name: auth_hash[:uid]
    else
      member = Member.create name: auth_hash[:uid]
      member.friends = Set.new
    end

    member.realname = auth_hash[:info][:name]
    member.avatar = auth_hash[:info][:image]
    member.friends.clear    
    user = FbGraph::User.me(auth_hash[:credentials][:token])
    user.friends.each do |f|
      friend_id = f.raw_attributes["id"].to_s
      if Member.exist? name: friend_id
        member.friends.add Member.as({ name: friend_id })
      else
        fm = Member.create name: friend_id
        fm.realname = f.raw_attributes["name"].to_s
        fm.save!
        member.friends.add fm
      end
    end

    member.save!
    #pp auth_hash

    redirect_to root_path, notice: "Hello #{member.realname}!"
    #render text: auth_hash.inspect
  end

  def failure
    render text: "Error"
  end
end
