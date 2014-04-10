class Room
  
  @name
  @creatorName
  @players
   
  def initialize(name, creatorName)
    @name = name
    @creatorName = creatorName
    @players = Array.new
  end
  
  def givePlayerList(socket)
    @players.each do |player|
      socket.send(player.getNickname +"\n")
    end
  end
  
  def join(player, socket)
    @players.each do |player|
      if player.getNickname.eql?(player.getNickname)
        socket.send("this player is already in room")
        return false
      end
    end
    
    @players << player

    socket.send("joined successfully")
    return true
  end
  
  def getName
    return @name
  end
  
end
