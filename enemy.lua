
enemies = {}

enemy_types = {}

function init_enemy_types()

  enemy_types = {
  
    {
      type = 1,
      life = 1,
      speed = 2,
      minspeed = 2,
      maxspeed = 2,
      pattern = follow_player,
      draw = draw_enemy,
      color = 12,
      points = 1
    },
    {
      type = 2,
      life = 3,
      speed = 4,
      minspeed = 3,
      maxspeed = 5,
      pattern = follow_player,
      draw = draw_enemy,
      color = 4,
      points = 1
    },
    {
      type = 3,
      life = 2,
      speed = 1,
      minspeed = 1,
      maxspeed = 1,
      pattern = thrower_pattern,
      draw = draw_enemy,
      color = _colors.dark_purple,
      points = 1,
      
      fire_mod = 2,
      fire_timer = 0,
      
      walking_timer = 2,
      walking_time = 4,
      
    },
    {
      type = 4,
      life = 2,
      speed = 10,
      minspeed = 9,
      maxspeed = 11,
      pattern = kamikaze_pattern,
      draw = draw_kamikaze,
      blast_radius = 100,
      explosion_time = 1,
      color = _colors.white,
      points = 1
    }
  }

end

function init_enemy(enemy_type)
  
  local enemy_type = enemy_type or 2
  local e_t = enemy_types[enemy_type]
  
  local e = {
    class = "enemy",
    pos = { x = 0, y = 0},
    v   = { x = 0, y = 0}, 
    o_f = { x = 0, y = 0}, -- outside forces
      
    w = 16 * 2,
    h = 16 * 2,
    scale_spr = 2,
    
    spawning = true,
    
    state = "",
    life = e_t.life,
    speed = e_t.speed,
    minspeed = e_t.minspeed,
    maxspeed = e_t.maxspeed,
    
    pattern = e_t.pattern,
    draw = e_t.draw,
    
    type = enemy_type,
    color = e_t.color,
    last_hit = nil,
    burning = false,
    electrified = false,
    electrify_mult = 1,
    
    blast_radius = e_t.blast_radius,
    explosion_time = e_t.explosion_time,
    
    fire_timer = e_t.fire_timer,
    fire_rate = e_t.fire_rate,
    fire_mod = e_t.fire_mod,
    walking_time = e_t.walking_time,
    
    points = e_t.points
  }  
  
  local b_pos
  local a_pos
  local way = way or irnd(4)
  
  if way == 0 then -- South
    b_pos = {x = border_w + irnd(ww - border_w*2 - e.w) , y = - e.h}
    a_pos = {x = 0, y = border_h*1.5 + e.h}
    e.spawning_angle = .25
  elseif way == 1 then  -- North
    b_pos = {x = border_w + irnd(ww - border_w*2 - e.w) , y = hh}
    a_pos = {x = 0, y = - border_h*1.5 - e.h}
    e.spawning_angle = -.25
  elseif way == 2 then  -- East
    b_pos = {x = - e.w , y = border_h + irnd(hh - border_h*2 - e.h)}
    a_pos = {x = border_w*1.5 + e.w, y = 0}
    e.spawning_angle = 0
  elseif way == 3 then   -- Ouest
    b_pos = {x = ww , y = border_h + irnd(hh - border_h*2 - e.h)}
    a_pos = {x = -border_w*1.5 - e.w, y = 0}
    e.spawning_angle = .5
  end
  
  e.b_pos = b_pos
  e.a_pos = a_pos
  
  e.pos.x = e.b_pos.x
  e.pos.y = e.b_pos.y
  e.v.x = cos(e.spawning_angle)
  e.v.y = sin(e.spawning_angle)
  
  e.spawn_time = time_since_launch
  
  add(enemies, e)
end

function update_enemies(dt)

  for i, e in pairs(enemies) do  
     
    if e.state == "hurt" then
      e.state = ""
    elseif e.state == "to_die" then 
      add_points(e.points)
      enemies[i] = nil 
      sugar.audio.sfx ("e_die") 
      
      -- target(back_surf)
      -- pal(5, e.color)
      -- aspr (15, e.pos.x + e.w/2, e.pos.y + e.h/2, 1/4 * irnd(4), 1, 1, .5, .5, 1 , 1 )
      -- local v = 10
      -- local o = 6
      -- for i = 0, v do
        -- for j = 0, v do
          -- if (i + j) % 2 == 1 or chance(30) then  
            -- rectfill(e.pos.x + i*2 + o, e.pos.y + j*2 + o,e.pos.x + i*2 + 1 + o, e.pos.y + j*2 + 1 + o , _colors.sea_blue)
          -- end
        -- end
      -- end
      -- pal()
      -- target()
      
    end
    update_enemy(e)    
  end
  
end


function update_enemy(e)
  
  if e.spawning then
    local t_anim = 1
    if time_since_launch - e.spawn_time >= t_anim then 
      e.spawning = nil
    else
      e.pos.x = easeInOut(time_since_launch - e.spawn_time, e.b_pos.x, e.a_pos.x, t_anim)
      e.pos.y = easeInOut(time_since_launch - e.spawn_time, e.b_pos.y, e.a_pos.y, t_anim)
    end
  else
    e.pattern(e)    
  end
  
  for i, oe in pairs(enemies) do
    if oe ~= e and chance(5) then
      local d = dist(e.pos.x, e.pos.y, oe.pos.x, oe.pos.y)
      if d < e.w then
        e.o_f.x = e.o_f.x + sign(e.pos.x - oe.pos.x)
        e.o_f.y = e.o_f.y + sign(e.pos.y - oe.pos.y)
      end
    end
    
  end
  
  e.pos.x = e.pos.x + e.o_f.x
  e.pos.y = e.pos.y + e.o_f.y
  
  e.o_f.x = e.o_f.x - e.o_f.x * (dt()*3)
  e.o_f.y = e.o_f.y - e.o_f.y * (dt()*3)
  
  if not e.spawning then
    local p = e
    if p.pos.x < border_w then 
      p.pos.x = border_w 
      e.touched_wall = true
    elseif p.pos.x > ww - p.w - border_w then 
      p.pos.x = ww - p.w - border_w 
      e.touched_wall = true 
    end
    
    if p.pos.y < border_h then 
      p.pos.y = border_h 
      e.touched_wall = true
    elseif p.pos.y > hh - p.h - border_h then 
      p.pos.y = hh - p.h - border_h 
      e.touched_wall = true 
    end  
  end          
  
  if e.burning then
    if time_since_launch - e.time_burned > burning_time then
      e.burning = false
      e.life = e.life - 1   
    end
  end
  
  if e.electrify_mult < 1 then  
    if time_since_launch - e.time_electrified > electrifying_time then    
      e.electrify_mult = e.electrify_mult + dt()      
      if e.electrify_mult >= 1 then
        e.electrify_mult = 1
        e.electrified = false
      end
    end    
  end
  
  collision_bullets(e) 
  
  if e.life < 1 then
    e.state = "to_die"
  end
end

function hit_enemy(e, life)
  e.life = e.life - (life or 1)
  e.state = "hurt"
end

function follow_player(e, step)

  local angle = atan2(e.pos.x - p.pos.x, e.pos.y - p.pos.y) + .5  
  
  e.angle = e.angle or angle
  
  e.speed = min(e.speed + e.maxspeed * dt() * 2, e.maxspeed) * ( e.electrify_mult or 1)
  local step = step or 0.02

  if abs(e.angle - angle)% 1 < .5 then
    if (e.angle < angle) then e.angle = e.angle + step
    else e.angle = e.angle - step
    end
  else
    if (e.angle < angle) then e.angle = e.angle - step
    else e.angle = e.angle + step
    end
  end
  
  e.angle = ((e.angle % 1) + 1) % 1    
  
  e.v.x = cos(e.angle) * e.speed 
  e.v.y = sin(e.angle) * e.speed   
  
  e.pos.x = e.pos.x + e.v.x
  e.pos.y = e.pos.y + e.v.y
  -- log(e.electrify_mult)
  if e.electrify_mult > .1 and dist(e.pos.x + e.w/2, e.pos.y + e.h/2, p.pos.x + e.w/2, p.pos.y + e.h/2) < e.w * 0.5 then
    hit_player()
  end
  
end

function kamikaze_pattern(e)
  if e.exploding then
    e.angle = atan2(e.v.x, e.v.y) - .04 + irnd(.07)
    e.v.x   = cos(e.angle)
    e.v.y   = sin(e.angle)
    
    if e.explosion_timer + e.explosion_time < time_since_launch then
    
     e.exploding = false
     e.exploded = true
     
     if dist(e.pos.x + e.w/2, e.pos.y+ e.h/2, p.pos.x+p.w/2, p.pos.y+ p.h/2) < e.blast_radius then hit_player() end
     hit_enemy(e)
     sugar.audio.sfx ("bullet_explosion") 
    end
  else
    follow_player(e, 0.02 / 5)
    
    if dist(e.pos.x + e.w/2, e.pos.y + e.h/2, p.pos.x + p.w/2, p.pos.y + p.h/2) < 100 or e.touched_wall then
      e.exploding = true
      e.explosion_timer = time_since_launch
    end
    
  end
end

function go_to(e, target) -- {x : x, y : y}
  local tx = target and target.x or 0
  local ty = target and target.y or 0
  
  local angle = atan2(e.pos.x - tx, e.pos.y - ty) + .5  
  
  e.angle = e.angle or angle
  
  e.speed = min(e.speed + e.maxspeed * dt() * 2, e.maxspeed) * ( e.electrify_mult or 1)
  
  local step = step or 0.01

  if abs(e.angle - angle)% 1 < .5 then
    if (e.angle < angle) then e.angle = e.angle + step
    else e.angle = e.angle - step
    end
  else
    if (e.angle < angle) then e.angle = e.angle - step
    else e.angle = e.angle + step
    end
  end
  
  e.angle = ((e.angle % 1) + 1) % 1    
  
  e.v.x = cos(e.angle) * e.speed 
  e.v.y = sin(e.angle) * e.speed   
  
  e.pos.x = e.pos.x + e.v.x
  e.pos.y = e.pos.y + e.v.y
end


function thrower_pattern(e)

  e.fire_timer = e.fire_timer - dt()    
  
  if e.firing then
    e.fire_timer = e.fire_timer - dt()    
    if e.fire_timer < 0 then 
      local f = fire_mods[e.fire_mod]
      if not p.dead then
        e_shoot(e) 
      end
      e.fire_timer = f.fire_rate + rnd(.3)
      e.firing = false
      e.walking = true
      
    end
  
  elseif e.walking then  
  -- will choose a random vector at 360deg and walk before stoping
  -- when stops, fires a bullet
  
    if not e.target then
      e.target = {x = 15 + irnd(GW - 15 * 2), y = 15 + irnd(GW- 15 * 2)}
      e.walking_timer = time_since_launch
    end
    
    go_to(e, e.target) 
    
    if e.walking_timer + e.walking_time < time_since_launch then
      e.firing = true
      e.walking = false
      e.target = nil
    end
    
  else
    e.firing = true
  end
    
end

function e_shoot(e)

  sugar.audio.sfx ("e_bullet") 
  local angle = atan2(p.pos.x + p.w/2 - (e.pos.x + e.w/2), p.pos.y + p.h/2 - (e.pos.y + e.h/2) )  
  e.v.x = p.pos.x + p.w/2 - (e.pos.x + e.w/2)
  e.v.y = p.pos.y + p.h/2 - (e.pos.y + e.h/2) 
  e.angle = angle
  local f = fire_mods[e.fire_mod]  
  local param = {}  
  param.explosive = true  
  param.blast_radius = f.blast_radius  
  init_bullet( "enemy", 
                e.pos.x + e.w/2 + cos(angle) * f.start_d,
                e.pos.y + e.h/2 + sin(angle) * f.start_d, 
                angle, 
                f.b_speed ,
                f.b_size  , 
                f.b_life  ,
                f.speed_loss,
                param )
end
 
function shadow(enemy)
  local e = enemy
  circfill(e.pos.x + e.w / 2 + 3, e.pos.y + e.h / 2 + 3, 12, _colors.black)
end
 
function draw_enemies()
  color(0)
  
  for i, e in pairs(enemies) do
    shadow(e)
  end  
  for i, e in pairs(enemies) do
    e.draw(e)
        
    if e.burning then        
      p_color = _colors.light_red
      local r_w = e.w               
      local x = e.pos.x  
      local y = e.pos.y
      for i = 0, 5 do    
        circfill(x + irnd(r_w) ,y + irnd(r_w), irnd(3), p_color)
      end
    end
    if e.electrified then
      p_color = _colors.white

      local r_w = e.w               
      local x = e.pos.x  
      local y = e.pos.y
      for i = 0, 5 do    
        circfill(x + irnd(r_w) ,y + irnd(r_w), irnd(3), p_color)
      end      
    end    
  end
  
end

function draw_kamikaze(e)
  
  if e.exploding then
    
    local x_o = irnd(5)
    local y_o = irnd(5)
 
    if e.explosion_timer and e.explosion_timer + e.explosion_time - dt() * 5 < time_since_launch then
      circfill(e.pos.x + e.w/2, e.pos.y + e.h/2, e.blast_radius, flr(time_since_launch*10)%2 == 0 and _colors.black or _colors.light_red)
    end
    
  end
    draw_enemy(e)
end

function draw_enemy(e)

  local angle = e.spawning and e.spawning_angle or atan2(e.v.x, e.v.y)
  
  if (e.state == "to_die" or e.state == "hurt") then
    pal(0, 5)
  end
  aspr (e.type, e.pos.x + e.w / 2, e.pos.y + e.h / 2, angle - .25, 1, 1, 0.5, 0.5, 1, 1  )
  pal()

end

