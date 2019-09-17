
-- evry skill has a name and a function
-- function ids are stored in table consulted at strategic points in the code

---------
---------
-- tables

skills = {}

on_b_v_update_skills = {
  3,
  4,
  5
}
on_b_col_enemy_skills = {
  1,
  2,
  6
}

function init_skills()
  skills = {
    fire_aspect,        
    electricity_aspect,  
    auto_aim,     
    dash,   
    rebound,      
    _recoil,
    pierce_aspect
  }

  burning_time = 1  
  electrifying_time = 3
  electrify_spd_mult = .5
end

function add_skill(id)
  if not p.skills[id] then
    p.skills[id] = true
  end
end

---------

---------

--------- skills

function auto_aim(parameters)  
  local b = parameters.bullet  
  
  local x, y = find_closest_enemy(b) 
  -- log(x .. " .. " .. y)
  if not x then return end  
  local angle_enemy = ((atan2(b.pos.x - x, b.pos.y - y ) + .5 % 1) + 1) % 1   
  if (b.angle - angle_enemy == 0) then return end  
  local step = 0.03
  if abs(b.angle - angle_enemy)% 1 < .5 then
    if (b.angle < angle_enemy) then b.angle = b.angle + step else b.angle = b.angle - step end
  else
    if (b.angle < angle_enemy) then b.angle = b.angle - step else b.angle = b.angle + step end
  end
  b.angle = ((b.angle % 1) + 1) % 1  
  -- vanilla_update_vector(b)    
end

function step_movement(parameters)
  local b = parameters.bullet
  b.speed_mult = abs(sin( b.life / b.m_life))
end

function fire_aspect(parameters)
  local b = parameters.bullet
  local e = parameters.enemy
  
  if b.burning then 
    burn_enemy(e)
  end
  
end

function burn_enemy(e)
  if e.burning then
    e.time_burned = e.time_burned - burning_time * 3 / 4
  else
    e.burning = true
    e.time_burned = time_since_launch
  end
end

function electricity_aspect(parameters)
  local e = parameters.enemy
  electrify_enemy(e)
end

function electrify_enemy(e)      
  e.time_electrified = time_since_launch  
  e.electrify_mult = (e.electrify_mult or 1) * electrify_spd_mult  
  e.electrified = true  
end
  
function dash(p)



end
 
function rebound(parameters)
  local b = parameters.bullet 
  local x = b.pos.x
  local y = b.pos.y
  
  if b.pos.x < b_pool then 
    b.v.x   = b.v.x * -1
    b.pos.x = b_pool
    b.angle = atan2(b.v.x, b.v.y)
  elseif x > w_pool - b.r - b_pool then 
    b.v.x   = b.v.x * -1 
    b.pos.x = w_pool - b.r - b_pool  
    b.angle = atan2(b.v.x, b.v.y)
  end
  
  if b.pos.y < b_pool then 
    b.v.y = b.v.y * -1 
    b.pos.y = b_pool
    b.angle = atan2(b.v.x, b.v.y)
  elseif b.pos.y > h_pool - b.r - border_h then
    b.v.y = b.v.y * -1 
    b.pos.y = h_pool - b.r - border_h
    b.angle = atan2(b.v.x, b.v.y)
  end
  
  
end

function _recoil(parameters)
  local e = parameters.enemy        
  local b = parameters.bullet 
  
  for ind, e in pairs(enemies) do
    if dist(e.pos.x + e.w/2, e.pos.y+ e.h/2, b.pos.x, b.pos.y) <= b.r*4 then
      hit_enemy(e)
      e.o_f.x = cos(b.angle) * 10
      e.o_f.y = sin(b.angle) * 10   
    end
  end
  hit_bullet(b)
  damage_done = false 
end


-- function lasers(parameters)

  -- local b = parameters.bullet   
  -- local e = parameters.enemy   
  
  -- local size = b.laser_length
  -- local pix_d = 30
  
  -- local ex = ceil((cos(b.angle) * size) / pix_d)
  -- local ey = ceil((cos(b.angle) * size) / pix_d)
  
  -- local stepx = sign(ex)
  -- local stepy = sign(ey)
  -- for i = 0, 4 do
    -- for j = 0, 4 do
      -- for xp = 0, abs(ex) do 
        -- xp = xp * stepx
        -- for yp = 0, abs(ey) do  
          -- yp = yp * stepy    
          -- if point_in_rect(b.pos.x + xp + i - 2, b.pos.y + yp + j - 2, e.pos.x, e.pos.y, e.pos.x + e.w, e.pos.y + e.h) then
            -- hit_enemy(e)
          -- end 
        -- end
      -- end  
    -- end  
  -- end  
  
-- end

