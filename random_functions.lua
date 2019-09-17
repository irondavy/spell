function very_cool_print(str, x, y, hspd, vspd, inner_col, outer_col)
  if not str or not x or not y then return end
  
  local w = str_px_width(str)
  local h = str_px_height(str)
  local x = x
  local hspd = hspd or 15 
  local vspd = vspd or 15
  local inner_col = inner_col or 1
  local outer_col = outer_col or 5
  
  for i = 1, #str do
    local c = str:sub(i,i)
    cool_print(c, x + w *(i-1)/#str+ cos(i / #str + t() / 2) * hspd + 6 , y + sin(i / #str + t() / 2) * vspd - h/2 + 6, 0, 0)
    cool_print(c, x + w *(i-1)/#str+ cos(i / #str + t() / 2) * hspd     , y + sin(i / #str + t() / 2) * vspd - h/2, inner_col, outer_col)
  end

end

function lesser_cool_print(str, x, y, spd, c1, c2)
  if not str or not x or not y then return end
  
  local w = str_px_width(str)
  local h = str_px_height(str)
  local x = x - w / 2
  local spd = spd or 7
  
  for i = 1, #str do
    local c = str:sub(i,i)
    cool_print(c, x + w *(i-1)/#str + 5, y + sin(i / #str + t() / 2) * spd + 5 - h/2, 0, 0)
    cool_print(c, x + w *(i-1)/#str , y + sin(i / #str + t() / 2) * spd - h/2, c1, c2)
  end

end

function cool_print(str, x, y, inner_col, outer_col)
  if not str or not x or not y then return end
  
  local inner_col = inner_col or 1
  local outer_col = outer_col or 5
  local margin = 2
  color(inner_col)
  
  -- printb(str, x-margin, y-margin)
  -- printb(str, x-margin, y)
  -- printb(str, x-margin, y+margin)
  
  -- printb(str, x+margin, y-margin)
  -- printb(str, x+margin, y)
  -- printb(str, x+margin, y+margin)
  
  -- printb(str, x, y-margin)
  -- printb(str, x, y+margin)
  
  color(outer_col)
  printb(str, x, y)

end

function shaded_cool_print(str, x1, y1, inner_col, outer_col, d)
  local d = d or 5
  cool_print(str, x1 + d, y1 + d, 0, 0)
  cool_print(str, x1, y1, inner_col, outer_col)

end

function count(tab)
  if not tab then return 0 end
  local nb = 0
  for i, j in pairs(tab) do nb = nb + 1 end
  return nb
  
end

-- function str_px_height(str)
  -- if not str then return end
  -- return m_font:getHeight("str")
-- end

function draw_button(rect)
  if not rect.str then return end
  
  local c = cos(t() / 4) * 10
  local s = sin(t() / 2) * 10
  
  local xb1 = rect.x1 + c
  local yb1 = rect.y1 + s
  local xb2 = rect.x2 + c
  local yb2 = rect.y2 + s
  
  local border = rect.border
  
  local inner_col = rect.hovered and 12 or 2
  local outer_col = 11
  
  rectfill (xb1, yb1, xb2, yb2, outer_col)
  rectfill (xb1 + border, yb1 + border, xb2 - border, yb2 - border, inner_col)
  
  lesser_cool_print(rect.str, rect.xt , rect.yt + str_px_height(rect.str)/2)
end

function mouse_in_rect_screen(this, x1, y1, x2, y2)
  return mouse_in_rect(x1 + this.x, y1 + this.y, x2 + this.x, y2 + this.y)
end

function mouse_in_rect( x1, y1, x2, y2, mx, my)
  if not x1 or not y1 or not x2 or not y2 then return end
  local mx = mx or btnv(2)
  local my = my or btnv(3)
  return mx > x1 and mx < x2 and my > y1 and my < y2
end

function chance(x) -- x gotta be between between 1 and 100 (both in)
  if x > 100 or x < 0 then return end
  return (rnd(100) <= x)
end

function big_line_h(x1, y1, x2, y2, size)
  for i = 0, size do
    line( x1, y1 + i , x2, y2 + i)
  end
end

function big_line_v(x1, y1, x2, y2, size)
  for i = 0, size do
    line( x1 + i , y1, x2 + i, y2)
  end
end

function here() log("here") end
function there() log("there") end

function easeInOut (timer, value_a, value_b, duration)
  
  timer = timer/duration*2  
	if (timer < 1) then return value_b/2*timer*timer + value_a end  
	timer = timer - 1  
 	return -value_b/2 * (timer*(timer-2) - 1) + value_a
end 

-- function easeIn (timer, value_a, value_b, duration)
  
  -- timer = timer/duration  
	-- return value_b*timer*timer + value_a 
	-- timer = timer - 1  
 	-- return -value_b/2 * (timer*(timer-2) - 1) + value_a
-- end 

function point_in_rect(x, y, x1, y1, x2, y2)
  return x > x1 and x < x2 and y > y1 and y < y2
end





function pick_distinct( amount, from )
  if not from or not amount or from == {} then return {} end
  
  to_return = {}
  
  for i = 1, amount do
    local choosen = pick(from)
    
    while check_in(choosen, to_return) do 
      choosen = pick(from)
    end
    add(to_return, choosen)
    
  end
  
  return to_return
end


function check_in(value, tab)
  for index, val in pairs(tab) do
    if val == value then return true end
  end
  return false
end

function sign(x) return x >=0 and 1 or -1 end



math.randomseed(os.time()) -- so that the results are always different
function shuffle(tInput)
    local tReturn = {}
    for i = #tInput, 1, -1 do
        local j = math.random(i)
        tInput[i], tInput[j] = tInput[j], tInput[i]
        table.insert(tReturn, tInput[i])
    end
    return tReturn
end


