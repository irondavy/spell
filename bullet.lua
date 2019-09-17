
bullets = {}
count_bullets = 0

function init_bullet(from, x, y, angle, spd, size, life, speed_loss, param)
  local speed = spd or 10
  b = {  
    from = from,
    pos = {
      x = x,
      y = y},
    v = {
      x = cos(angle) * speed,
      y = sin(angle) * speed},  
      
    r = size or 8,
    angle = angle,
    scale_spr = 2,
    speed = speed,
    life = life or .6,
    m_life = life or .6,
    state = "spawned",
    moving = true,
    ricochet = 0,
    last_hit = nil,
    damage = 1 + (bonuses.damage or 0),
    speed_loss = speed_loss,
    blast_radius = param.blast_radius,
  }

  param = param or {}  
  b.burning = param.burning
  b.electrified = param.electrified
  b.explosive = param.explosive
  b.ricochet = param.ricochet
  b.is_laser = param.is_laser    
  b.is_boulder = param.is_boulder    
  b.is_nail = param.is_nail    
  
  count_bullets = count_bullets + 1
  bullets[count_bullets] = b
  -- sugar.audio.sfx ("bullet") 
  
  return bullets[count_bullets]
  
end


function update_bullets(dt)
  
  for i, b in pairs(bullets) do
    b.life = b.life - dt
    
    if b.state == "dying" then
      b.state = "to_die"
      b.speed = 0
      b.v = {x = 0, y = 0}
    elseif b.state == "to_die" then
      if b.is_exploding then         
        if dist(b.pos.x - p.pos.x - p.w/2, b.pos.y - p.pos.y - p.h/2) < b.blast_radius + p.w/4 then
          hit_player()
        end
        sugar.audio.sfx ("bullet_explosion") 
      end
      bullets[i] = nil
    elseif b.state == "hit" then
      b.state = ""
    end
    
    update_vec_bullet(b, dt)
  
    if b.moving then
      update_pos_bullet(b)
    end    
    if b.life < 0 or b.pos.x < border_w - 8 or b.pos.x > ww - b.r - border_w + 8 or b.pos.y < border_h - 8 or b.pos.y > hh - b.r - border_h + 8 then
      if b.life > 0 and b.explosive then
        b.life = min( b.life, .1 )
      else
        b.state = "to_die"
      end
    end
    
    if bullet_alive(b) and b.from == "enemy" then    
      if b.life < .1 and b.explosive then
        b.is_exploding = true
      end    
      for i, bb in pairs(bullets) do 
        if bullet_alive(bb) and bb.from == "player" and dist(b.pos.x - bb.pos.x, b.pos.y - bb.pos.y) < b.r + bb.r then 
          hit_bullet(b)
          hit_bullet(bb)
        end
      end
      
    end
    
  end
    
  
end

function update_vec_bullet(b, dt) 
  if not b then return end
  
  local parameters = { bullet = b}
  
  if b.from == "player" then  
    for ind, func_id in pairs(on_b_v_update_skills) do
      if p.skills[func_id] then 
        skills[func_id](parameters) 
      end 
    end
  end-----------------------
  vanilla_update_vector(b)
  
end

function vanilla_update_vector(b)
  b.speed = b.speed  * b.speed_loss
  b.v.x = cos(b.angle) * b.speed * (b.speed_mult or 1)
  b.v.y = sin(b.angle) * b.speed * (b.speed_mult or 1)
end

function find_closest_enemy(b)

  if count(enemies) < 1 then return end
  local m_dist = nil
  local x, y = 0, 0

  for i, e in pairs(enemies) do 
    local d = dist(e.pos.x - b.pos.x, e.pos.y - b.pos.y)
    if not m_dist or m_dist > d then 
      m_dist = d
      x = e.pos.x
      y = e.pos.y
    end  
  end
  return x, y
end

function update_pos_bullet(b)
  b.pos.x = b.pos.x + b.v.x
  b.pos.y = b.pos.y + b.v.y
end

function collision_bullets(entity)
  local e = entity
  
  for i, b in pairs(bullets) do 
    if bullet_alive(b) and entity.class ~= b.from then      
      local parameters = { bullet = b, enemy = e}
      damage_done = true      
      if dist(e.pos.x + e.w/2 - b.pos.x, e.pos.y + e.w/2 - b.pos.y) < e.w / 2 + b.r then 
        local no_skill = true
        -----------------------
        if b.from == "player" then  
          for ind, func_id in pairs(on_b_col_enemy_skills) do          
            if p.skills[func_id] then 
              skills[func_id](parameters) 
              no_skill = false
            end             
          end   
        end
        -----------------------
        if no_skill or damage_done == true then
          hit_bullet(b)
          if b.from == "player" then
            hit_enemy(e, b.damage)
          else
            hit_player()
          end 
        end 
        -----------------------
      end 
    end 
  end
end

function hit_bullet(bullet)
  bullet.state = "dying"
end

function bullet_alive(bullet)
  return bullet.state ~= "to_die" and bullet.state ~= "dying"
end

function draw_bullets()
  
  for i, b in pairs(bullets) do
  
    if b.is_laser then
      laser_drawing(b)
    else    
      vanilla_drawing(b)
    end
    
  end
end

-- function laser_drawing(b)

  -- if (b.angle > .5/4 and b.angle <.5 * 3/4) or (b.angle > .5 + .5/4 and b.angle <.5 + .5 * 3/4) then
    -- big_line_v(b.pos.x, b.pos.y, b.pos.x + cos(b.angle) * b.laser_length , b.pos.y + sin(b.angle) * b.laser_length, 3)
  -- else
    -- big_line_h(b.pos.x, b.pos.y, b.pos.x + cos(b.angle) * b.laser_length , b.pos.y + sin(b.angle) * b.laser_length, 3)
  -- end
-- end


function vanilla_drawing(b)
  if b.state == "to_die" or b.state == "dying" then
    circfill(b.pos.x, b.pos.y, b.r + 8, _colors.light_red)
  else
    if b.from == "player" then
        if b.electrified then
          p_color = _colors.white
          
          local r_w = b.r
          
          local s_x = b.pos.x
          local s_y = b.pos.y
          local s_a = b.angle
                   
          local x = s_x + cos(s_a + 1/4) * r_w
          local y = s_y + sin(s_a + 1/4) * r_w                 

          for i = 0, 5 do                
            local r_x = cos(s_a + 1/2) * r_w
            local r_y = sin(s_a + 1/2) * r_w
                     
            local xx = irnd(r_w)
            local yy = irnd(r_w)
            circfill(x + cos(s_a + 1/2) * xx * 3 + cos(s_a - 1/4) * yy * 2 ,
                     y + sin(s_a + 1/2) * xx * 3 + sin(s_a - 1/4) * yy * 2 , 
                     irnd(3),
                     p_color)
          end
        end
    
      
      if b.burning then
        pal(5, 2)
      end
      
      aspr (6, b.pos.x , b.pos.y , b.angle , 1, 1, 0.5, 0.5, 1 * (b.r / 8), 1 * (b.r / 8)  )
      
      pal()
    else
      aspr (5, b.pos.x , b.pos.y , b.angle , 1, 1, 0.5, 0.5, 2 , 2 )
      
    -- if b.burning then
      -- pal(5, 2)
      -- pal(2, 5, false)
    -- end
    -- local b_color = _colors.white

    -- if b.electrified or b.burning then

      -- if b.burning then
        -- b_color = _colors.light_red
      -- end
      
      -- if b.electrified then
        -- p_color = _colors.white

        -- local r_w = b.r
                 
        -- local x = b.pos.x + cos(b.angle + 1/4) * r_w
        -- local y = b.pos.y + sin(b.angle + 1/4) * r_w                 

        -- for i = 0, 5 do                
          -- local r_x = cos(b.angle + 1/2) * r_w
          -- local r_y = sin(b.angle + 1/2) * r_w
                   
          -- local xx = irnd(r_w)
          -- local yy = irnd(r_w)
          -- circfill(x + cos(b.angle + 1/2) * xx * 3 + cos(b.angle - 1/4) * yy * 2 ,
                   -- y + sin(b.angle + 1/2) * xx * 3 + sin(b.angle - 1/4) * yy * 2 , 
                   -- irnd(3),
                   -- p_color)
        -- end
      -- end
    -- end     
    -- circfill(b.pos.x, b.pos.y, b.r, b_color)    

      if b.is_exploding then
        circfill(b.pos.x , b.pos.y , b.blast_radius, flr(time_since_launch*10)%2 == 0 and _colors.black or _colors.light_red)
      end
    
    end
    
  end
end