
-- GW = 700
-- GH = 900

local hud = { surface          = nil,
              back             = nil,
              x                = 0,
              y                = 0,
              background_clr   = 2
            }
           
function init_hud()
  hud.surface = new_surface( GW - 20, GH/4 - 15)
  hud.back = "hud_png"
  hud.x = 10
  hud.y = 10
  hud.w, hud.h = surface_size(hud.surface)
  starpos = {
              { {523, 143},         {529, 122},         {517, 104},         {529, 80},         {517, 61},         {523, 39}         },

              { {523+ 51, 143},     {529+ 51, 122},     {517+ 51, 104},     {529+ 51, 80},     {517+ 51, 61},     {523+ 51, 39}     },

              { {523+ 51+ 51, 143}, {529+ 51+ 51, 122}, {517+ 51+ 51, 104}, {529+ 51+ 51, 80}, {517+ 51+ 51, 61}, {523+ 51+ 51, 39} }
  }  
  PB = 0
end

function update_hud()

end

function draw_hud()

  target(hud.surface)
  
    spr_sheet(hud.back, 0, 0)
    
    -- -- stars
    -- for ind_tree, tree in pairs(starpos) do
    --   for ind_sk, star in pairs(tree) do
      
    --     if sk_tree[ind_tree][ind_sk] == 1 then        
    --       if ind_sk ~= 1 then
    --         line(star[1], star[2], starpos[ind_tree][ind_sk - 1][1], starpos[ind_tree][ind_sk - 1][2], _colors.white)
    --       end
    --       circfill(star[1], star[2], 6, _colors.white)
    --       circfill(star[1], star[2], 4, _colors.white)
    --     end
        
    --   end
    -- end
    
    -- life
    local x = hud.w/2 - 37
    local y = 175
    for i = 1, p.max_hp do 
        circfill((i-1) * 35 + x, y + sin(time_since_launch / p.hp*3 + (i/p.max_hp)) * 3, 12,  _colors.light_red)        
        circfill((i-1) * 35 + x, y + sin(time_since_launch / p.hp*3 + (i/p.max_hp)) * 3, 10, i > p.hp and _colors.black or _colors.light_red)
    end
    
    -- wave
    local wv = current_wave == 0 and 1 or (current_wave == (#waves + 1) and "~" or current_wave)
    use_font("big")
    
    y = hud.h * 1/2

    local str = "Wave"
    cool_print(str, hud.w/4 - str_px_width(str) / 2, y - 35)
    shaded_cool_print(wv, hud.w/4 - str_px_width(wv) / 2, y) -- + sin_b * 2)
    
    -- score
    local str = p.score
    shaded_cool_print(str, (hud.w/4 * 2) - str_px_width(str) / 2, y)

    local str = "Score"
    cool_print(str, (hud.w/4 * 2) - str_px_width(str) / 2, y - 35)
    
    -- PB
    local str_PB = max(p.score, PB or 0)
    shaded_cool_print(str_PB, (hud.w/4 * 3) - str_px_width(str_PB) / 2, y) -- + sin_b * 2 )
    
    local str = "P.Best"
    cool_print(str, (hud.w/4 * 3) - str_px_width(str) / 2, y - 35)
    
    
  target()  
    
  spr_sheet(hud.surface, hud.x, hud.y)
  
end

  