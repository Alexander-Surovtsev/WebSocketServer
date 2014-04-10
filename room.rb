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
      socket.send(player.getNickname)
    end
  end
  
  def join(player, socket)
    @players.each do |p|
      if p.getNickname.eql?(player.getNickname)
        socket.send("this player is already in room")
        return false
      end
    end
    @players << player
    socket.send("joined successfully")
    return true
  end
  
  def hasPlayer(player)
    @players.each do |p|
      if p.getNickname.eql?(player.getNickname)
        return true
      end
    end
    return false
  end
  
  def getName
    return @name
  end
  
  def getPlayers
    return @players
  end 
 
end
