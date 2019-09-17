
require("pool")
require("player")
require("bullet")
require("enemy")
require("waves")
require("hud")
require("bonuses")
require("skills")
require("game_over")
-- GW = 304
-- GH = 380

-- color 11 and 12 look nice
-- color 7, 8, 9, 0 and 10 do not break your eyes

local background_clr = 0
time_since_launch = 0
sin_b = 0

my_id = nil
my_name = nil


function init_game()

  load_font("sugarcoat/TeapotPro.ttf", 64*3/4, "big", true)
  load_font("sugarcoat/TeapotPro.ttf", 64/2, "log", false)
  
  load_font("sugarcoat/TeapotPro.ttf", 64/2 , "leaderboard", false)
  
  register_btn(0, 0, input_id("mouse_button", "lb"))
  register_btn(1, 0, input_id("mouse_button", "rb"))
  register_btn(2, 0, input_id("mouse_position", "x"))
  register_btn(3, 0, input_id("mouse_position", "y"))
  
  
  register_btn(4,  0, {input_id("keyboard", "z"), 
                       input_id("keyboard", "w")})
                       
  register_btn(5,  0, {input_id("keyboard", "q"), 
                       input_id("keyboard", "a")})
                       
  register_btn(6,  0, input_id("keyboard", "s"))
  register_btn(7,  0, input_id("keyboard", "d"))
  
  register_btn(8,  0, input_id("keyboard", "p"))
  register_btn(9,  0, input_id("keyboard", "f"))
  register_btn(10, 0, input_id("keyboard", "space"))
  
  register_btn(11, 0, input_id("mouse_button", "scroll_y"))
  
  spritesheet("spr_s")
  spritesheet_grid(32, 32)
  
  load_user_info()
  new_game()

end


function load_user_info()

  network.async(  
    function () 
      user = castle.user.getMe()
      highscores = castle.storage.getGlobal("highscores") or {}  
      my_id   = user.userId
      my_name = user.name or user.username
      PB = highscores[my_id] and highscores[my_id].p_score or 0
      if PB then log(PB) end
    end)
end
  

function update_game(dt)
  time_since_launch = time_since_launch + dt
  sin_b = sin(t() / 2)
  
  update_hud(dt)
  update_pool(dt)
  
  if game_over then
    update_game_over()
  end
  
  
end

function draw_game()
  cls(background_clr)
  draw_hud()
  draw_pool()
  if p.invicible_cooldown == p.invicible_time then
    cls(_colors.dark_red)
  end
  
  if game_over then
    draw_game_over()
  end
  
end

function draw_palette()
  for i = 0, 15 do 
    local x  = i * (30 + 5)
    local co = i        
    rectfill(x, 0, x + 30, 0 + 30, co)       
  end
end


function new_game()
  -- game
  time_since_launch = 0
  sin_b = 0

  my_id = nil
  my_name = nil
    
  -- bullets
  bullets = {}
  count_bullets = 0
  
  -- enemy
  enemies = {}
  
  -- game over
  game_over = false
  g_o_surf = nil
  
  -- player
  p = {} 
  
  init_hud()
  init_pool()
  init_sk_tree()
  
end
