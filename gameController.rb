require_relative 'player'
require_relative 'room'

class GameController# < ApplicationController
    #include Singleton
    
    
    @rooms = []
    @players = []
    @sockets = []

    
    def initialize
      @rooms = Array.new
      @players = Array.new
      @sockets = Array.new
    end
    
    def getSockets
      return @sockets
    end
    
    def addSocket(socket)
      @sockets << socket
    end
    
    def deleteSocket(socket)
      @sockets.delete socket
    end 
    
    def createPlayer(name, email, money = 50000)
      u = Player.new(name, email, money)
      @players << u
    end
    
    def newPlayer(socket, message, arr) 
      if arr.length > 1
        begin
          if !socket.nickName.eql?("")
            socket.send("you already registered. Your nickname - " + socket.nickName)
            return
          end 
        rescue
        end
        @sockets.each do |s|
          hasNick = false
          begin # same as try
            if s.nickName.eql?(arr[1]) 
              hasNick = true
              socket.send("this nickName already in use")
              return
            end
          rescue  # same as catch
            hasNick = false
          end
        end 
        createPlayer(arr[1], "vasyapupkin@gmail.com")
          
        class << socket # магия, что добавляет поле к объекту
          attr_accessor :nickName
        end
        socket.nickName = arr[1]        
        socket.send "Wellcome "+ arr[1] +"! Wellcome to hell!!!" # player created
      end
    end
    
    def getPlayerList(socket, message) 
      str = ""
      @players.each do |player|
         str += (player.getNickname + "\n")
      end
      socket.send(str)
    end
    
    def getRoomsList(socket, message) 
      str = ""
      count = 0
      @rooms.each do |room|
         str += (room.getName + "\n")
         count += 1
      end
      socket.send(count.to_s() + " " + str)
    end
    
    def broadcast(message, arr) 
      message.slice! "broadcast "
      if arr.length > 1
         @sockets.each {|s| s.send message}
      end
    end
  
    def userLoggedIn(socket)
      hasNick = false
      begin # same as try
        if !socket.nickName.eql?("") 
          hasNick = true
          return true
        end
      rescue  # same as catch
        hasNick = false
        socket.send("you are not logged in")
      end
      return hasNick
    end
  
    def createRoom(socket, message, arr)
      if arr.length > 1 and userLoggedIn(socket)
        @rooms.each do |room|
          if room.getName.eql?(arr[1])
            socket.send("room with the same name already exists")
            return false
          end
        end
        room = Room.new(arr[1], socket.nickName)
        @rooms << room
        socket.send("room "+ arr[1]+ " added successfully")
        return true
      end
      return false
    end
    
    def findPlayer(nickname)
      @players.each do |p|
        if p.getNickname.eql?(nickname)
          return p
        end
      end
      return false
    end
    
    def findRoomByNick(nickname)
      player = findPlayer(nickname)
      @rooms.each do |room|
        if room.hasPlayer(player)
          return room
        end
      end
      return nil
    end
    
    
    def joinRoom(socket, message, arr)
      if arr.size > 1 and userLoggedIn(socket)
        if (findRoomByNick(socket.nickName) != nil) and !((findRoomByNick(socket.nickName)).getName.eql?(arr[1]))
          socket.send("player joined another room")
          return
        end
        nameFound = false
        @rooms.each do |room|
          if room.getName.eql?(arr[1])
            nameFound = true
            player = findPlayer(socket.nickName)
            room.join(player, socket)
          end
        end
        if !nameFound
          socket.send("room does not esists")
        end
      else
        socket.send("cannot join room")
      end
    end
    
    
    
    def roomExists(name)
      @rooms.each do |room|
        if room.getName.eql?(name)
          return true
        end
      end
      return false
    end
    
    def findRoomByName(name)
      if (roomExists(name))
        @rooms.each do |room|
          if room.getName.eql?(name)
            return room
          end
        end
        return nil
      end
    end
    
    def playersInRoom(socket, message, arr) 
      if !(arr.size > 1 and userLoggedIn(socket))
        socket.send("something wrong")
        return
      end
      if roomExists(arr[1])
        room = findRoomByName(arr[1])
        room.givePlayerList(socket)
      else
        socket.send("room does not exists")
      end
    end
    
    def findSocketByNick(nickname)
      @sockets.each do |s|
        if s.nickName.eql?(nickname)
          return s
        end
      end
      return nil
    end
    
    def sayRoom(socket, message, arr) 
      if !(arr.size > 1 and userLoggedIn(socket))
        socket.send("something wrong")
        return
      end
      player = findPlayer(socket.nickName)
      room = findRoomByNick(socket.nickName)
      if (room == nil)
        socket.send("player not in room")
      else
        message.slice! "sayRoom "
        room.getPlayers.each do |p|
          s = findSocketByNick(p.getNickname)
          s.send(message)
        end
      end
      
    end
    
    def processMessage(socket, message)
      arr = message.split
      case arr[0]
        when "play"
          newPlayer(socket, message, arr)
        when "getPlayerList"
          getPlayerList(socket, message)
        when "broadcast"
          broadcast(message, arr) 
        when "addRoom"
          createRoom(socket, message, arr)
        when "getRoomsList"
          getRoomsList(socket, message)
        when "joinRoom"
          joinRoom(socket, message, arr)
        when "playersInRoom"
          playersInRoom(socket, message, arr) 
        when "sayRoom"
          sayRoom(socket, message, arr)
      end
    end
end