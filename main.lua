require("game")  -- where all the fun happens
require("random_functions")
require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)

if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    -- "assets/explosion.wav",
    -- "assets/explosion2.wav",
    -- "assets/launch.wav",
    -- "assets/selected.wav",
    -- "assets/selection.wav",
    
    -- "assets/help.png",
    -- "assets/hors.png",
    -- "assets/sound.png",
    -- "assets/no_sound.png",
    
    -- "SB_games/_SB_games.lua",
    -- "SB_games/coin_toss.lua",
    -- "SB_games/janken.lua",
    -- "SB_games/horse_race.lua",
    
    -- "screens/_screen_controller.lua",
    -- "screens/background.lua",
    -- "screens/choose_bets.lua",
    -- "screens/choose_game.lua",
    -- "screens/display_results.lua",
    -- "screens/generic_screen.lua",
    -- "screens/main_menu.lua",
    -- "screens/sb_game.lua",
    -- "screens/shop.lua",
    -- "screens/title_screen.lua",
    -- "screens/winground.lua",
    
    "bonuses.lua",
    "bullet.lua",
    "enemy.lua",
    "game.lua",
    "game_over.lua",
    "hud.lua",
    "main.lua",
    "map.lua",
    "player.lua",
    "pool.lua",
    "random_functions.lua",
    "skills.lua",
    "waves.lua",
    
    "assets/background.mp3",
    "assets/bullet_explosion.wav",
    "assets/e_bullet.wav",
    "assets/e_die.wav",
    "assets/get_hit.ogg",
    "assets/get_hit_player.ogg",
    "assets/hover.wav",
    "assets/lvl_up.wav",
    "assets/new_game.wav",
    "assets/p_bullet.wav",
    
    "assets/hud.png",
    "assets/spr.png",
    
})
end

GW = 700
GH = 900
zoom = 3

function love.load()
  init_sugar("!Manaficator!", GW, GH, zoom )
  screen_render_integer_scale(false)
  use_palette(palettes.bubblegum16)
  
  _colors = {
    black = 0,
    dark_red = 1,
    light_red = 2,
    orange = 3,
    yellow = 4,
    white = 5,
    light_pink = 6,
    dark_pink = 7,
    light_purple = 8,
    dark_purple = 9,
    sea_blue = 10,
    sky_blue = 11,
    light_green = 12,
    green = 13,
    plastic_blue = 14,
    dark_blue = 15
  }
  
  
  palt(0, false)    
  palt(15, true)
  
  set_frame_waiting(30)
  
  love.math.setRandomSeed(os.time())
  love.mouse.setVisible(true)
  
  -- sugar.audio.sfx ("click") 
  load_sfx ("assets/hover.wav", "hover", .2)
  
  load_sfx ("assets/lvl_up.wav", "lvl_up", .2)
  
  load_sfx ("assets/new_game.wav", "new_game", .2)
  
  load_sfx ("assets/e_bullet.wav", "e_bullet", .1)
  load_sfx ("assets/p_bullet.wav", "p_bullet", .1)
  
  load_sfx ("assets/bullet_explosion.wav", "bullet_explosion", .2)
  
  load_sfx ("assets/e_die.wav", "e_die", .2)
  load_sfx ("assets/get_hit.ogg", "p_hit", .2)
  load_sfx ("assets/get_hit_player.ogg", "p_die", .2)
  
  
  load_music("assets/background.mp3", "bgm", .4)
  music("bgm", true)
  
  hud_png = load_png("hud_png", "assets/hud.png", nil, false)
  spr_s = load_png("spr_s", "assets/spr.png", nil, false)
  
  init_game()
end

function love.update(dt)
  update_game(dt)
end


function love.draw()
  draw_game()
end















