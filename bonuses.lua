
--- bonuses


b_text = {
  "Magic Spd+",
  "Magic Size+",
  "Magic Range+",
  "Fire Rate+"
}

bonus_points = { -- see b_text for more info
  0,
  0,
  0,
  0 
}

bonuses = {}

function reset_bonuses()
  bonuses = {
    b_speed_mult = 1,
    b_range_mult = 1,
    b_size_mult = 1,
    fire_rate_mult = 1,
    damage = 0
  }
end

reset_bonuses()

level_txt = {
  "M-SPD",
  "M-RNG",
  "M-RAD",
  "F-RTE" 
}

sk_tree = {
  -- { [branch][level] : is_activated 
  -- {0, 0, 0, 0, 0, 0},
  -- {0, 0, 0, 0, 0, 0},
  -- {0, 0, 0, 0, 0, 0},
  -- {1, 1, 1, 1, 1, 0},
  -- {1, 1, 1, 1, 1, 0}
  -- {1, 1, 0, 0, 0, 0},
  -- {1, 1, 0, 0, 0, 0},
  -- {1, 1, 0, 0, 0, 0},
}
sk_tree_list = {}
sk_tree_txt = {
  -- { [branch][level] : is_activated 
  -- {"Fire Aspect",        "Speed T-1",     "Damage T-1", "Fire Rate T-2", "Speed T-2", "Rebound"},
  -- {"Electro Aspect",     "Size T-1",      "Auto-Aim",   "Double",        "Size T-2",  "Shotgun"},
  -- {"Range T-1",          "Fire Rate T-1", "Dash"      , "Fire Rate T-2", "Range T-2", "Recoil"}
}
sk_tree_func = {
  -- {fire,         speed_p, damage,   firer_p,      speed_p, rebounds},
  -- {electricity , size_p,  auto_a,   more_bullets, size_p,  shotgun},
  -- {range_p,      firer_p, dash_,    firer_p,      range_p, recoil}
}

function init_sk_tree()

  reset_bonuses()

  sk_tree = {
    -- { [branch][level] : is_activated 
    -- {1, 1, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0}
    -- {1, 1, 1, 1, 1, 0},
    -- {1, 1, 1, 1, 1, 1},
    -- {1, 1, 1, 1, 1, 1}
    -- {1, 1, 1, 0, 0, 0},
    -- {0, 0, 0, 0, 0, 0}
  }

  sk_tree_list = {
    { "Range", range_p },
    { "Range", range_p },
    { "Bullets", more_bullets },
    { "Bullets", more_bullets },
    { "Damage", dmg_p },
    { "Damage", dmg_p },
    { "Rate", firer_p },
    { "Rate", firer_p },
    { "Bigger", size_p },
    { "Bigger", size_p },
    { "Speed", speed_p },
    { "Speed", speed_p },
    { "Wall", wall },
    { "Accuracy", accuracy },
    { "Ricochet", rebounds },
    { "Shock", electricity }
  }
  sk_tree_list = shuffle(sk_tree_list)

  -- sk_tree_txt = {{}, {}, {}}
  -- sk_tree_func = {{}, {}, {}}

  -- for i = 1, 3 do
  --   for j = 1, 6 do
  --     local skill = table.remove(sk_tree_list)
  --     table.insert(sk_tree_txt[i], skill[1])
  --     table.insert(sk_tree_func[i], skill[2])
  --   end
  -- end

  for branch_id, branch in pairs(sk_tree) do
    for id, func in pairs(branch) do
      if sk_tree[branch_id][id] == 1 then sk_tree_func[branch_id][id]() end
    end
  end  
end

function speed_p()
  bonuses.b_speed_mult = (bonuses.b_speed_mult or 1) * 3
  show_message("Speed up")
end

function wall()
  bonuses.b_speed_mult   = 0.1
  bonuses.fire_rate_mult = (bonuses.fire_rate_mult or 1) * 3.5
  show_message("Speed down, rate up")
end

function size_p()
  bonuses.b_size_mult = (bonuses.b_size_mult or 1) * 1.75
  show_message("Larger bullets")
end

function range_p()
  bonuses.b_range_mult   = (bonuses.b_range_mult   or 1) * 2
  show_message("Bullets last longer")
end
function firer_p()
  bonuses.fire_rate_mult = (bonuses.fire_rate_mult or 1) * 3
  show_message("Increased fire rate")
end

function dmg_p()
  bonuses.damage = bonuses.damage + 1
  show_message("More damage per bullet")
end

function more_bullets() 
  p.shoot_times = p.shoot_times + 1
  show_message("Extra bullet per shot")
end

function rebounds()
  add_skill(5)
  show_message("Bullets bounce off walls")
end

function electricity()
  add_skill(2)
  show_message("Bullets stun enemies")
end 

function fire()         add_skill(1)   show_message("It's getting hot in here.")  end
function auto_a()       add_skill(3)   speed_d()   show_message("I'm not strong at aiming.")  end  -- auto aim 
function dash_()        add_skill(4)   show_message("Press Spacebar to dash.")  end 
function shotgun()      p.shoot_times = p.shoot_times + 3 
                        p.dispersion = p.dispersion * 3  
                        p.b_speed_diff = .5
                        fire_mods[p.fire_mod].b_speed = fire_mods[p.fire_mod].b_speed * 2 
                        fire_mods[p.fire_mod].b_life = fire_mods[p.fire_mod].b_life * 3/4
                        fire_mods[p.fire_mod].fire_rate = fire_mods[p.fire_mod].fire_rate * 2.5
                        fire_mods[p.fire_mod].speed_loss = .85
                        show_message("Have you met my friend here ?")
end
function recoil()    add_skill(6) show_message("No, YOU're breathtaking.") end

function accuracy()
  p.dispersion = 0
end

function add_bonus(id)
  unlock_next_skill(tree_id)
end

function unlock_next_skill(tree_id)

  local i = 0  
  repeat
    sk_tree[tree_id][i] = true 
    i = i + 1
  until not sk_tree[tree_id][i+1]   
end

function update_skills(tree_id)
  -- bonus_points[id] = bonus_points[id] + 1
  -- update_bonuses()  
  -- next_skill(sk_tree[tree_id])
end