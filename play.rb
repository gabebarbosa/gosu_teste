require 'gosu'



class Player
  attr_reader :score
  def initialize(nave, boom)
    @image = Gosu::Image.new("arquivos/#{nave}")
    @boom = Gosu::Sample.new("arquivos/#{boom}")
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def pra_esquerda
    @angle -= 4.5
  end

  def pra_direita
    @angle += 4.5
  end

  def acelerador
    @vel_x += Gosu.offset_x(@angle, 0.5)
    @vel_y += Gosu.offset_y(@angle, 0.5)
  end

  def mover
    @x += @vel_x
    @y += @vel_y
    @x %= 800
    @y %= 600

    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
  def score
    @score
  end

  def collect_stars(stars)
    stars.reject! do |star|
      if Gosu.distance(@x, @y, star.x, star.y) < 35
        @score += 1
        @boom.play
        true
      else
        false
      end
    end
  end
end

class Tutorial < Gosu::Window
  def initialize
    super 800, 600
    self.caption = "Invasores da Terra"

    @background_image = Gosu::Image.new("arquivos/space.jpg", :tileable => true)
    #@music = Gosu::Sample.new("arquivos/boom.wav")
    #@music.play


    @player = Player.new("nave3.png", "boom.wav")
    @player.warp(300, 300)


    @player2 = Player.new("nave2.png", "boom2.wav")
    @player2.warp(500, 300)


    @star_anim = Gosu::Image.load_tiles("arquivos/star.png", 32, 32)
    @stars = Array.new
    @font = Gosu::Font.new(20)
    @font2 = Gosu::Font.new(20)
  end

  def update
    if Gosu.button_down? Gosu::KB_A or Gosu::button_down? Gosu::GP_LEFT
      @player2.pra_esquerda
    end
    if Gosu.button_down? Gosu::KB_D or Gosu::button_down? Gosu::GP_LEFT
      @player2.pra_direita
    end
    if Gosu.button_down? Gosu::KB_W or Gosu::button_down? Gosu::GP_LEFT
      @player2.acelerador
    end
    @player2.mover
    @player2.collect_stars(@stars)




    if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
      @player.pra_esquerda
    end
    if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
      @player.pra_direita
    end
    if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_BUTTON_0
      @player.acelerador
    end
    @player.mover
    @player.collect_stars(@stars)

    if rand(100) < 4 and @stars.size < 25
      @stars.push(Star.new(@star_anim))
    end
  end

  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    @player.draw
    @player2.draw
    @stars.each { |star| star.draw }
    @font.draw("Inimigos derrotados: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::GREEN)
    @font2.draw("Inimigos derrotados: #{@player2.score}", 800-250, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end
end

class Star
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color::BLACK.dup
    @color.red = rand(256 - 40) + 40
    @color.green = rand(256 - 40) + 40
    @color.blue = rand(256 - 40) + 40
    @x = rand * 800
    @y = rand * 600
  end

  def draw  
    img = @animation[Gosu.milliseconds / 100 % @animation.size]
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZOrder::STARS, 1, 1, @color, :add)
  end
end

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

Tutorial.new.show