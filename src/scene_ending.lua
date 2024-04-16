local draw = require 'draw_utils'

return function ()
  local s = {}
  local W, H = W, H

  local T = 0

  s.press = function (x, y)
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
  end

  s.release = function (x, y)
  end

  s.update = function ()
    T = T + 1
  end

  local flowers = {}  -- {x, y}
  local seed = 202404161
  local rand = function ()
    seed = (seed * 1664525 + 1013904223) % 0x80000000
    return seed / 0x80000000
  end
  for i = 1, 100 do
    local x = rand()
    local y = rand() * 0.2
    flowers[i] = {x, y}
  end
  for i = 1, 10 do
    local x = 0.4 + 0.2 * rand()
    local y = rand() * 0.14
    flowers[i] = {x, y}
  end
  flowers[#flowers + 1] = {0.442, 0.25}
  flowers[#flowers + 1] = {0.457, 0.233}

  s.draw = function ()
    draw.img('intro/background_vases', W * 0.5, H * 0.5, W, H)

    -- Flowers
    love.graphics.setColor(1, 1, 1, 0.8)
    for i = 1, #flowers do
      local x, y = unpack(flowers[i])
      draw.img('bloom/idle/01', W * x, H * y, 100 / 1.5)
    end

    -- The special one
    love.graphics.setColor(1, 1, 1)
    local frame = math.floor(T / 240 * 24) % 6 + 1
    draw.img(string.format('bloom/idle/%02d', frame), W * 0.5, H * 0.3, 100 / 1.5)

    -- Chameleons
    love.graphics.setColor(1, 1, 1)
    draw.img('ending/branches', W * 0.5, H * 0.5, W, H)
    draw.img('ending/1', W * 0.5, H * 0.5, W, H)

    -- Butterfly (Bee!)
    local frame = math.floor(T / 240 * 24) % 16 + 1
    draw.img(string.format('butterflies/idle-back/%02d', frame), W * 0.5, H * 0.8, 200 / 1.5)
  end

  s.destroy = function ()
  end

  return s
end
