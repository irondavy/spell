waves = {}

spawning_enemies = false
current_wave = 0

time_until_spawn = 0
condition_met = false
timer_lvl_up = 2
time_leveled_up = 0
endless_mode = false

function init_waves()
  
  -- waves = {
    -- [enemy_type] = remaining
    -- { -- 1
      -- [1] = 1,
      -- [2] = 3,
      -- [3] = 3,
      -- [4] = 1
    -- }
  -- }

  -- Rats

  waves = {
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0}
  }

  waves[1][1] =  2 + irnd(2)
  waves[2][1] =  2 + irnd(4)
  waves[3][1] =  4 + irnd(4)
  waves[4][1] =  8 + irnd(4)
  waves[5][1] = 12 + irnd(4)

  -- Bosses

  slots = { 2, 3, 4 }
  slots = shuffle(slots)

  waves[1][slots[1]] = 1 + irnd(1)

  waves[2][slots[2]] = 2 + irnd(2)

  waves[3][slots[3]] = 3 + irnd(3)

  slots = shuffle(slots)

  waves[4][slots[1]] = 2 + irnd(2)
  waves[4][slots[2]] = 3 + irnd(3)

  slots = shuffle(slots)

  waves[5][slots[1]] = 4 + irnd(1)
  waves[5][slots[2]] = 5 + irnd(2)
  waves[5][slots[3]] = 6 + irnd(3)
  
  spawning_enemies = false
  condition_met = false
  current_wave = 0
  time_until_spawn = 0  
  time_before_lvl_up = .6
  time_leveled_up = 0
  endless_mode = false
  timer_lvl_up = time_before_lvl_up
  endless_enemy_spawn_time = 1
end

function begin_next_wave()
  
  if current_wave >= #waves + 1 then return end
  
  current_wave = current_wave + 1
  spawning_enemies = true
end

function update_waves(dt)
  if current_wave == #waves + 1 then endless_mode = true end
  
  if current_wave > #waves + 1 then return end
  
  if spawning_enemies then -- in wave
    
    time_until_spawn = time_until_spawn - dt 
 
    if time_until_spawn < 0 then   
      
      if endless_mode then
      
        init_enemy( random_enemy_type(nil)) 
        
        endless_enemy_spawn_time = max(endless_enemy_spawn_time * .983, .35)
        time_until_spawn = endless_enemy_spawn_time
      
      elseif not is_wave_ended() then
        time_until_spawn = max(1 - current_wave*.06, .5)
        init_enemy( random_enemy_type(current_wave))
      else
        spawning_enemies = false
        timer_lvl_up = time_before_lvl_up
      end
    end
    
  else
    timer_lvl_up = timer_lvl_up - dt
    
    if current_wave == 0 and time_since_launch > .8 then condition_met = true end
    
    if not show_lvl_up and count(enemies) < 1 and current_wave > 0 and timer_lvl_up < 0 and time_leveled_up < current_wave then 
      init_lvl_up() 
      show_lvl_up = true 
      screen_shake()
    end
    
    if condition_met then 
      begin_next_wave()
      show_wave()
      condition_met = false
      show_lvl_up = false
      timer_lvl_up = time_before_lvl_up
    end    
  end

end

function random_enemy_type(current_wave)
  if not current_wave then
    local choosen_id = 1 + irnd(100)
    
    if choosen_id < 50 then return 1 end
    
    if choosen_id < 75 then return 2 end
    
    if choosen_id < 90 then return 3 end
    
    return 4  
    
  end

  local indexes  = {}

  indexes = get_indexes(waves[current_wave])
  
  local choosen_id = indexes[1 + irnd(#indexes)]
  -- log(choosen_id)
  -- log(current_wave)
  while waves[current_wave][choosen_id] < 1  do 
    choosen_id = 1 + irnd(#indexes)   
  end
  
  waves[current_wave][choosen_id] = waves[current_wave][choosen_id] - 1
  
  return choosen_id

end

function get_indexes(tab)
  local tabl = {}
  for ind, _ in pairs(tab)do
    add(tabl, ind)
  end
  return tabl
end

function is_wave_ended()  
  if current_wave == 0 then return true end
  for ind, remaining in pairs(waves[current_wave])do
    if remaining > 0 then return false end
  end
  return true
end
