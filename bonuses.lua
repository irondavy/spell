
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

sk_tree_list = {}

function init_sk_tree()

  reset_bonuses()

  sk_tree_list = {
    { "Pierce", pierce },
    { "Sustain", range_p },
    { "Sustain", range_p },
    { "Bisect", more_bullets },
    { "Bisect", more_bullets },
    { "Force", dmg_p },
    { "Force", dmg_p },
    { "Tempo", firer_p },
    { "Tempo", firer_p },
    { "Volume", size_p },
    { "Volume", size_p },
    { "Velocity", speed_p },
    { "Velocity", speed_p },
    { "Viscosity", wall },
    { "Precision", accuracy },
    { "Restitution", rebounds },
    { "Valence", electricity }
  }
  sk_tree_list = shuffle(sk_tree_list)

end

function speed_p()
  bonuses.b_speed_mult = (bonuses.b_speed_mult or 1) * 3
  show_message("Faster shots")
end

function wall()
  bonuses.b_speed_mult  = 0.1
  bonuses.fire_rate_mult = (bonuses.fire_rate_mult or 1) * 3
  show_message("Slower shots, increased rate")
end

function size_p()
  bonuses.b_size_mult = (bonuses.b_size_mult or 1) * 2
  show_message("Larger shots")
end

function range_p()
  bonuses.b_range_mult = (bonuses.b_range_mult   or 1) * 2
  show_message("Shots last longer")
end
function firer_p()
  bonuses.fire_rate_mult = (bonuses.fire_rate_mult or 1) * 3
  show_message("Increased shot rate")
end

function dmg_p()
  bonuses.damage = bonuses.damage + 2
  show_message("More damage per shot")
end

function more_bullets() 
  p.shoot_times = p.shoot_times * 2
  show_message("Double number of shots")
end

function rebounds()
  add_skill(5)
  show_message("Shots bounce off walls")
end

function electricity()
  add_skill(2)
  show_message("Shots stun enemies")
end 

function pierce()
  add_skill(7)
  show_message("Shots pierce enemies")
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