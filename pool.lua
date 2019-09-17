
-- GW = 304
-- GH = 380



local x_pool = 0
local y_pool = 0
w_pool = 0
h_pool = 0
b_pool = 0
local pool_s        = nil

back_surf = nil

message = ""
message_timer = 0
wave_timer = 0
wave_display_time = 3
message_time = 3

was_on_skill = false
is_on_skill = false

function show_message(msg)
  if not msg then return end  
  message =   msg
  message_timer = message_time  
end

function show_wave()
  wave_timer = wave_display_time  
end

local player = {}

show_lvl_up = false

local t_respawn = 0

function init_pool()
  
  -- GW = 700
  -- GH = 900
  
  x_pool = 14
  y_pool = GH * 1/4 + 2
  ww = GW - x_pool*2
  hh = GH * 3/4 - 3
  
  border_w = 32
  border_h = 32
  
  w_pool = ww
  h_pool = hh
  b_pool = 32
    
  pool_s = new_surface(ww, hh) 
  
  back_surf = new_surface(ww, hh) 
  local w,h = surface_size(back_surf)
  
  target(back_surf)
    rectfill(0, 0, ww, hh, _colors.black)
    rectfill(border_w, border_h, ww - border_w, hh - border_h, _colors.black)
    
    -- for i = 0 , 10 do
    --   circfill( w / 2, h/2, ww*2/3 - (ww*2/3 / 10 * i), (i%2 == 0 and _colors.dark_purple or _colors.sea_blue))
    -- end
    -- for i = 0 , 20 do
    --   circfill( irnd(w), irnd(h), irnd(ww/5), (i%2 == 0 and _colors.dark_purple or _colors.sea_blue))
    -- end
    
    
    
    for i = 0, w/32 do
      for j = 0, h/32 do
        if i == 0 or i == 20 or 
           j == 0 or j == 20 then        
          aspr (8, i * 32 , j * 32, 0, 1, 1, 0, 0, 1 , 1 )          
        else
          if chance(1) then
            pal(5, irnd(15))
            aspr (10 + irnd(4), i * 32 + 16, j * 32 + 16, 1/4 * irnd(4), 1, 1, .5, .5, 1 , 1 )
            pal()
          end
        end
      
      end
    end
    
    
    
  target()
  
  init_skills()
  init_player(ww, hh) 
  init_fire_mods()
  init_enemy_types()
  init_waves()
  show_lvl_up = false

  
end

function update_pool(dt)
  if screen_shake_timer > 0 then 
    screen_shake_timer = screen_shake_timer - dt 
  else
    screen_shake_timer = 0
  end
  
  update_waves(dt)  
  if show_lvl_up then update_lvl_up() end
  update_player(dt)
  update_enemies(dt)
  update_bullets(dt) 
  
  message_timer = message_timer - dt
  wave_timer = wave_timer - dt
  
end

function add_skill(id)
  if id == 1 and not p.skills[id] then
    p.skills[id] = true
  end
end


function draw_pool()

  target(pool_s)
  
  cls(background_clr)
  
  spr_sheet(back_surf, 0,0 )
  
  if show_lvl_up then draw_lvl_up() end
  
  draw_player()
  draw_enemies()
  draw_bullets()
  
  
  -- message_timer = message_timer - dt()
  -- wave_timer = wave_timer - dt()
  if message_timer > 0 then
    use_font("big")
    cool_print(message, w_pool/2 - str_px_width(message)/2, h_pool * 3/4 - str_px_height(message) + sin_b * 5)  
  end
  
  if wave_timer > 0 then
    use_font("big")
    local str = (current_wave == (#waves + 1)) and "Endless" or "Wave " .. current_wave
    very_cool_print(str, w_pool/2- str_px_width(str) / 2, h_pool * 1/4  - str_px_height(str) + sin_b * 5, 0, 7) 
  
  
  end
  
  target()
  spr_sheet(pool_s, x_pool + (irnd(30) - 15)  * screen_shake_timer, y_pool + (irnd(10) - 5) * screen_shake_timer)
  

  
end

screen_shake_timer = 0

function screen_shake()

  screen_shake_timer = min(screen_shake_timer + 1, 3)

end

function rnd_pos_inside_pool(wsize, hsize)

  local x = ww - border_w * 2 - (wsize or 0)
  local y = hh - border_h * 2 - (hsize or 0)

  x = irnd(x) + border_w
  y = irnd(y) + border_h

  return x, y
end

lvl_up = {}

function init_lvl_up()
  lvl_up = { 1, 2, 3 }
end

function pick_distinct_number( count, from, to) -- from and to are included
  -- if (to - from + 1) < count then log("oops") return end
  local numbers = {}
  
  for i = from, to do
    add(numbers, i)
  end
  
  return pick_distinct(count, numbers)

end
  
function update_lvl_up()
  local ct = count(lvl_up)    
  local ci = 0 
  is_on_skill = false
  for i, level in pairs(lvl_up) do
    ci = ci + 1
    local x = ww/2 - cos(ci/ct - 1/4) * ww/4 
    local y = hh/2 - sin(ci/ct - 1/4) * ww/4 - 30
    
    local xp = p.pos.x + p.w/2
    local yp = p.pos.y + p.h/2
    
    if dist(xp - x, yp - y) < p.w * 1.5 then     
      is_on_skill = true
      if btnp(9) then
        sugar.audio.sfx("lvl_up") 
        -- log("level ".. level .. " in tree " .. i .. " named " .. sk_tree_txt[i][level])
        time_leveled_up = time_leveled_up + 1
        local sk_choice = table.remove(sk_tree_list, i)
        sk_choice[2]()
        sk_tree_list = shuffle(sk_tree_list)
        condition_met = true
      end
      if is_on_skill ~= was_on_skill then 
        sugar.audio.sfx("hover") 
      end
    end
  end
  
  was_on_skill = is_on_skill
  
end

function draw_lvl_up()
  use_font("big")  
  local ct = count(lvl_up)  
  local ci = 0 
  for i, v in ipairs(lvl_up) do
    ci = ci + 1
    local txt = sk_tree_list[v][1] or ""
    
    local x = ww/2 - cos(ci/ct - 1/4) * ww/4 
    local y = hh/2 - sin(ci/ct - 1/4) * ww/4 - 30
    
    local xp = p.pos.x + p.w/2
    local yp = p.pos.y + p.h/2
    circfill(x, y, ww/20, _colors.black)
    if dist(xp - x, yp - y) < p.w * 1.5 then    
      circfill(x, y - 2 + sin_b, ww/20 - sin_b*6, _colors.light_red)
      local str = "Press 'F' to Choose"
      use_font("log")
      shaded_cool_print(str, xp - str_px_width(str)/2 , yp + str_px_height(str) + 4 + sin_b * 3, _colors.black)
        use_font("big")
      
    else
      circfill(x, y - 2 + sin_b, ww/20 - sin_b*6, _colors.white )
    end
    color(_colors.black)
    shaded_cool_print(txt, x - str_px_width(txt)/2, y - str_px_height(txt)/2 - 60 + sin_b*2 )
    
    local I = ""
    for it = 1, i do I = I .. "I" end
    
    shaded_cool_print(I, x - str_px_width(I)/2, y - str_px_height(I)/2 + 60 + sin_b*2, _colors.yellow, _colors.black )
  
  end
end

function fact(x)
  if x == 0 then return 1 end
  return fact(x-1) * x
end
