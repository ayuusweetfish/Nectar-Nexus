local draw = require 'draw_utils'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_Imprima']

  s.press = function (x, y)
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
  end

  s.release = function (x, y)
  end

  s.update = function ()
  end

  s.draw = function ()
    love.graphics.clear(0, 0.01, 0.03)
  end

  s.destroy = function ()
  end

  return s
end
