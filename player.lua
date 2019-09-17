
p = {} -- player
-- local ww = 0
-- local hh = 0


local fire_cooldown = 0

fire_mods = {}

function init_fire_mods()
  fire_mods = 
  {
    { name = "basic",
      id = 1,
      start_d = 16,
      fire_rate = 1,
      b_size = 10,
      b_speed = 3,
      b_life = 2,
      b_rnd = .04,
      speed_loss = 1 },
      
    { name = "thrower",
      id = 1,
      start_d = 16,
      fire_rate = 2,
      b_size = 10,
      b_speed = 50,
      b_life = 2,
      b_rnd = .04,
      blast_radius = 50,
      speed_loss = .85 }
  }
end

function init_player()
 
  p = {  
    class = "player",
    pos = {
      x = ww / 2 - 16,
      y = hh / 2 - 16},
    v = {
      x = 0,
      y = 0},  
      
    score = 0,
        
    w = 16 * 2,
    h = 16 * 2,
    scale_spr = 2,
    
    hp = 5,
    max_hp = 5,
    
    skills = {},
    shoot = single_bullet,
    shoot_times = 1,
    dispersion = 0.1,
    b_speed_diff = 0,
    fire_mod = 1,
    fire_cooldown = 0,
    dash_cooldown = 0 , 
    invicible_cooldown = 0,
    invicible_time = 1.3   
  }  
  
  submitted_score = false
  
end

function update_player(dt)
  -- if btnp(1) then show_message("ouch") end
  
  local mx = 7 * dt * 10
  p.fire_cooldown = p.fire_cooldown - dt

  if p.skills[4] then
    p.dash_cooldown = p.dash_cooldown - dt
  end
  
  p.invicible_cooldown = p.invicible_cooldown - dt
  
  if p.dead then return end
  -- 4 5 6 7
  -- z q s d
  if btn(4) then
    -- here()
    p.v.y = p.v.y - mx
  elseif btn(6) then
    p.v.y = p.v.y + mx
  end
  
  if btn(5) then
    p.v.x = p.v.x - mx 
  elseif btn(7) then
    p.v.x = p.v.x + mx
  end
  
  if btnp(10) and p.dash_cooldown < 0 then 
    p.dash_cooldown = .8
    local max_speed = 10 
    local angle = atan2(p.v.x, p.v.y)-- + .5
    p.v.x = p.v.x + 50 * cos(angle)
    p.v.y = p.v.y + 50 * sin(angle)
  end
  
  p.v.x = p.v.x * (1 - dt * 6)
  p.v.y = p.v.y * (1 - dt * 6)
  
  cap_speed_player()
  
  update_pos_player()
  
  if btn(0) and p.fire_cooldown < 0 then
    shoot()
  end
  
end

function shoot()
  
  local angle = atan2(p.pos.x + p.w/2 - btnv(2), p.pos.y + p.h/2 - btnv(3) + hh*1/3) + .5
  local f = fire_mods[p.fire_mod]
  
  local param = {}
    param.burning = p.skills[1]
    param.electrified = p.skills[2]
  
  for i = 1, p.shoot_times do
    sugar.audio.sfx ("p_bullet") 
    p.shoot(angle - p.dispersion + rnd(p.dispersion * 2), f, param)
  end
  
  p.fire_cooldown = f.fire_rate / bonuses.fire_rate_mult      
  -- screen_shake()

end

function single_bullet(angle, fire_mod, param)
  local angle = angle
  local f = fire_mod
  init_bullet( "player", 
                p.pos.x + p.w/2 + cos(angle) * f.start_d,
                p.pos.y + p.h/2 + sin(angle) * f.start_d, 
                angle - f.b_rnd/2 + rnd(f.b_rnd), 
                f.b_speed * bonuses.b_speed_mult * ( 1 - p.b_speed_diff + rnd(p.b_speed_diff * 2)) ,
                f.b_size  * bonuses.b_size_mult, 
                f.b_life  * bonuses.b_range_mult,
                f.speed_loss,
                param )
end

function cap_speed_player()
  speed = dist(p.v.x, p.v.y)  
  local max_speed = 10  
  if speed > max_speed then
    p.v.x = p.v.x / speed * (speed-3)
    p.v.y = p.v.y / speed * (speed-3)
  end
end

function update_pos_player()
  
  p.pos.x = p.pos.x + p.v.x
  p.pos.y = p.pos.y + p.v.y
  
  
  if p.pos.x < border_w then p.pos.x = border_w
  elseif p.pos.x > ww - p.w - border_w then p.pos.x = ww - p.w - border_w end
  
  if p.pos.y < border_h then p.pos.y = border_h
  elseif p.pos.y > hh - p.h - border_h then p.pos.y = hh - p.h - border_h end  

end

function hit_player()
  if p.dead then return end
  if p.invicible_cooldown < 0 then
    sugar.audio.sfx ("p_hit") 
    p.invicible_cooldown = p.invicible_time
    p.hp = p.hp - 1
    screen_shake()
    
    if p.hp < 1 then p.dead = true end
    
    if p.dead and not submitted_score then 
      sugar.audio.sfx ("p_die") 
      init_game_over()
    end
  end

end


function draw_player()

  local angle = p.dead and .25 or atan2(p.pos.x + p.w/2 - btnv(2), p.pos.y + p.h/2 - btnv(3) + hh*1/3) + .5
  
  local c = cos(angle)
  local s = sin(angle)
  
  if p.invicible_cooldown > 0 and ( flr(p.invicible_cooldown * 10) % 2 == 0 ) then
  else
    if p.dash_cooldown > 0 then      
      circfill(p.pos.x + p.w / 2, p.pos.y + p.h / 2, abs(p.dash_cooldown) * 28, _colors.white)
    end      
      circfill(p.pos.x + p.w / 2 + 3, p.pos.y + p.h / 2 + 3, 12, _colors.black)
      aspr (p.dead and 14 or 0, p.pos.x + p.w / 2, p.pos.y + p.h / 2, angle - .25, 1, 1, 0.5, 0.5, 1, 1  )
  end
  
  if not p.dead then
    line(p.pos.x + p.w/2 + c * 32,
         p.pos.y + p.h/2 + s * 32, 
         p.pos.x + p.w/2 + c * 64, 
         p.pos.y + p.h/2 + s * 64, 
         _colors.white)
  end
end

function submit_score()
  submitted_score = true
end

function add_points(points)
  if not p.dead then
    p.score = p.score + points
  end
end
