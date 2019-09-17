
game_over = false
g_o_surf = nil

was_on_ng = false
is_on_ng = false

function init_game_over()

  color1 = _colors.black
  color2 = _colors.black
  color3 = _colors.white
  color4 = _colors.light_red

  game_over = true
  
  window_w = ceil(GW * 3/4)
  window_h = ceil(GH * 2/3) + 5 + 15
  
  window_x = GW/2 - window_w / 2
  window_y = - window_h
  
  g_o_surf = new_surface(window_w, window_h)
  
  submit_score()
  refresh_leaderboard()
  
  info_on_pb = true
  
  animation_g_o = true
  beginning_animation = time_since_launch
  
  
  
  
  ox = 0

  ----------
  -----------------------------------
  leaderboard = {} -- {{place : player_id}, ...}
  highscores =  {}  -- { player_id : { player_name, score }, ...} 
  my_id = nil
  my_name = nil
  my_place = nil
  refreshing = false
  -----------------------------------

end


function update_game_over(dt)
  
  is_on_ng = false
  if info_on_pb then  
    
    if time_since_launch - beginning_animation > 2 then 
      info_on_pb = false 
      animation_g_o = true 
      beginning_animation = time_since_launch
    end
  
  elseif animation_g_o then   
    window_y = - window_h + easeInOut (time_since_launch - beginning_animation, 0, window_h + (GH - window_h) / 2  - 60, 2)   
    if time_since_launch - beginning_animation > 2 then animation_g_o = false end
  end
end


function draw_game_over()
  target(g_o_surf)
  cls(_colors.black)
    local border = 15
    
    use_font("leaderboard")
    
    local header = {"rank", "score", "player name"}
    local column_w = {}
    for i = 1, #header do 
      column_w[i] = str_px_width(header[i]) * 1.5 
    end
    
    
    if refreshing then 
      
      use_font("big")
      local str = "Refreshing Leaderboard"
      very_cool_print(str, window_w / 2 - 2 - str_px_width(str) / 2, window_h / 2 - 2 - str_px_height(str) / 2, nil, 10)
      
      
    else
      use_font("leaderboard")
      
      -- ox goes from 0 to - count(leaderboard + 19
      ox = min( max(ox - btnv(11), 0) ,max(count(leaderboard) - 19, 0))
      for index, player_id in pairs(leaderboard) do 
      
        index = index - ( ox or 0)
        if index > 0 and index < 20 then
          local color = ((player_id == my_id) and color4 or color1)
          local additionnal_h = 4
          rectfill( border + 2,
                    border + index *(str_px_height("9") + additionnal_h) + 10,
                    window_w - border - 4,
                    border + (index+1) * (str_px_height("9") + additionnal_h) + 5,
                    color) 
          
          
          local ww = 0
          local y = border + index * (str_px_height("9") + additionnal_h) + (color == color4 and sin_b * 3 or 0) + 5
          local str = ""
          
          -- rank
          x = border * 2
          str = index + (ox or 0) or ""
          printb(str, x , y, color3)
          
          -- score
          x = x + column_w[1]
          str = highscores[player_id] and highscores[player_id].p_score or ""
          printb(str, x , y, color3)
          -- player_name
          x = x + column_w[2]
          str = highscores[player_id] and highscores[player_id].p_name or ""
          printb(str, x , y, color3)
          x = x + column_w[3]
        
        end
      end
    end  
    
    use_font("leaderboard")
    rectfill( border + 2, 
              border ,  
              window_w - border - 2 - 2, 
              border + str_px_height("9") - 2 + 5,
              color1) 
              
    for index, str in pairs(header) do 
      local ww = 0
      for i = 1, index do 
        ww = ww + (column_w[i-1] or 0)
      end
      
      color(color2)
      
      if index > 1 then
        big_line_v(border * 2 + ww - 20, 0, border * 2 + ww - 20, window_h, 3)
      end
      printb(str, border * 2 + ww , border, color3)
    
    end
    
  
  target()
  
  spr_sheet(g_o_surf, window_x, window_y - sin_b * 3)

  if info_on_pb then  
  
      use_font("big")
      local str = (p.score > (PB or 0)) and "New record!" or "Your record remains untouched."
      very_cool_print(str, GW / 2 - 2 - str_px_width(str) / 2, GH / 2 - 2 - str_px_height(str) / 2, nil, 10)
      
  elseif not animation_g_o then
  
    local button_w = 180  
    local button_h = 60    
    local button_x = GW/2 - button_w/2  
    local button_y = window_y + window_h + 90 - button_h/2 
    local border = 5
    local m_in_rect = mouse_in_rect( button_x, button_y, button_x + button_w, button_y + button_h, btnv(2), btnv(3))
    
    is_on_ng = m_in_rect
    
    rectfill( button_x, button_y, button_x + button_w, button_y + button_h, color4) 
    rectfill( button_x + border, button_y + border, button_x + button_w - border, button_y + button_h - border, color1) 
    use_font("leaderboard")
    local str = "Play again"
    very_cool_print(str, button_x + 25, button_y + 30, 4, 4)
    
    if is_on_ng ~= was_on_ng then
      sugar.audio.sfx("hover") 
    end
    was_on_ng = is_on_ng
    
    if btnp(0) and m_in_rect then
      sugar.audio.sfx("new_game") 
      PB = max(highscores[my_id] and highscores[my_id].p_score or 0, p.score)  
      new_game() 
    end    
  end 
  
  
end

function refresh_leaderboard()
  refreshing = true
  network.async(
  
    function () 
      
      local user = castle.user.getMe()
      my_id   = user.userId
      my_name = user.name or user.username
    
      highscores = castle.storage.getGlobal("highscores") or {}     
      -- highscores = {}     
      -- castle.storage.setGlobal("highscores", highscores )     
      
      local old = highscores[my_id]
      if not old or old.p_score < p.score and p.score > 0 then
        highscores[my_id] = {p_name = my_name, p_score = p.score}
      end
      
      castle.storage.setGlobal("highscores", highscores )    
    
      -- for ind, v in pairs(highscores) do
        -- ilog("id" , ind)
        -- ilog("highscores[id].p_name" ,  v.p_name)
        -- ilog("highscores[id].p_score", v.p_score) 
      -- end
    
      leaderboard = {}
      local copy_h = copy_table(highscores)
      local cn  = 1
      
      for index_p, perf in pairs(highscores) do
        local maxi = 0
        local index = 0
        for i, p in pairs(copy_h) do
          if maxi < p.p_score then 
            maxi = p.p_score
            index = i
            
            if i == my_id then 
              my_place = cn 
              ox = max( 0 , min(cn - 6, count(highscores) - 19))
            end
          end          
        end
        if maxi ~= 0 then
          leaderboard[cn] = index
          copy_h[index] = nil       
          cn = cn + 1
        end
      end  
      
      -- for ind, v in pairs(leaderboard) do
        -- ilog("id" , ind)
        -- ilog("leaderboard[id].p_name" , v)
        -- ilog("leaderboard[id].p_score", v.p_score)
      -- end
            
      refreshing = false
    end) 
end    
       
function ilog (str, value)
  log(str .. " : " .. value)
end

