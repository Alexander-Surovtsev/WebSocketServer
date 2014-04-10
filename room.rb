class Room
  
  @name
  @creatorName
  @players
   
  def initialize(name, creatorName)
    @name = name
    @creatorName = creatorName
    @players = Array.new
  end
  
  def join(nickName, socket)
    @players.each do |player|
      if player.getNickName.eql?(nickName)
        socket.send("this player is already in room")
        return false
      end
    end
    @players << nickName
    return true
  end
  
  def getName
    return @name
  end
  
end
