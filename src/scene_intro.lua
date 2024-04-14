local draw = require 'draw_utils'
local button = require 'button'
local scroll = require 'scroll'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_Imprima']

  local t1 = love.graphics.newText(font(80), 'B')

  local btnStart = button(
    draw.enclose(love.graphics.newText(font(36), 'Start'), 120, 60),
    function () replaceScene(sceneIntro(), transitions['fade'](0.1, 0.1, 0.1)) end
  )
  btnStart.x0 = W * 0.5
  btnStart.y0 = H * 0.65
  btnStart.x = btnStart.x0
  btnStart.y = btnStart.y0
  local buttons = { btnStart }

  local scroll_main = scroll({
    x_min = -W / 2,
    x_max = 0,
  })

  s.press = function (x, y)
    scroll_main.press(x, y)
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    local r = scroll_main.move(x, y)
    if r == 2 then
      for i = 1, #buttons do if buttons[i].cancel_pt(x, y) then return true end end
    end
    if r then return true end
    for i = 1, #buttons do if buttons[i].move(x, y) then return true end end
  end

  s.release = function (x, y)
    scroll_main.release(x, y)
    for i = 1, #buttons do if buttons[i].release(x, y) then return true end end
  end

  s.update = function ()
    scroll_main.update()
    local sdx = scroll_main.dx
    for i = 1, #buttons do
      local b = buttons[i]
      b.x = b.x0 + sdx
      b.update()
    end
  end

  s.draw = function ()
    local sdx = scroll_main.dx

    love.graphics.clear(1, 1, 0.99)
    love.graphics.setColor(1, 1, 1)
    draw.img('intro_bg', W / 2 + sdx, H / 2, W, H)
    draw.shadow(0.95, 0.95, 0.95, 1, t1, W / 2 + sdx, H * 0.35)

    love.graphics.setColor(1, 1, 1)
    for i = 1, #buttons do buttons[i].draw() end
  end

  s.destroy = function ()
  end

  return s
end
