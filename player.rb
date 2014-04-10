class Player

    @socket
    @nickname
    @email
    @money
    
    def initialize(name, email, money = 50000)
      @nickname = name
      @email = email
      @money = money
    end
    
    def getNickname
      return @nickname
    end
  end
  