local draw = require 'draw_utils'

local ease_tetra_in_out = function (x)
  if x < 0.5 then return x * x * x * x * 8
  else return 1 - (1 - x) * (1 - x) * (1 - x) * (1 - x) * 8 end
end

return function ()
  local s = {}
  local W, H = W, H

  local T = 0

  local bloom_x = W * 0.5
  local bloom_y = H * 0.3
  local bloom_held = false
  local since_bloom = -1

  s.press = function (x, y)
    if since_bloom == -1 and
        (bloom_x - x) ^ 2 + (bloom_y - y) ^ 2 <= (W * 0.04) ^ 2 then
      bloom_held = true
    end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
  end

  s.release = function (x, y)
    if since_bloom == -1 and bloom_held and
        (bloom_x - x) ^ 2 + (bloom_y - y) ^ 2 <= (W * 0.04) ^ 2 then
      since_bloom = 0
    end
  end

  s.update = function ()
    T = T + 1
    if since_bloom >= 0 then since_bloom = since_bloom + 1 end
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
    local bloom_frame = function (since)
      local progress = math.max(0, math.min(1, since / 60))
      local n = 1 + math.floor(progress * (8 - 1))
      return string.format('bloom/visited/%02d', n)
    end

    love.graphics.setColor(1, 1, 1, 0.8)
    for i = 1, #flowers do
      local x, y = unpack(flowers[i])
      local aname
      if since_bloom == -1 then
        aname = 'bloom/idle/01'
      else
        aname = bloom_frame(since_bloom - 120 - math.sqrt(#flowers - i) * 100)
      end
      draw.img(aname, W * x, H * y, 100 / 1.5)
    end

    -- The special one
    love.graphics.setColor(1, 1, 1)
    local frame = math.floor(T / 240 * 24) % 6 + 1
    local aname
    if since_bloom == -1 then
      aname = string.format('bloom/idle/%02d', frame)
    else
      aname = bloom_frame(since_bloom)
    end
    draw.img(aname, bloom_x, bloom_y, 100 / 1.5)

    -- Chameleons
    love.graphics.setColor(1, 1, 1)
    draw.img('ending/branches', W * 0.5, H * 0.5, W, H)

    local frame = 1
    if since_bloom >= 0 then
      local progress = math.max(0, math.min(1, (since_bloom - 1200) / 80))
      frame = 1 + math.floor(progress * (8 - 1))
    end
    draw.img('ending/' .. tostring(frame), W * 0.5, H * 0.5, W, H)

    -- Butterfly (Bee!)
    local frame = math.floor(T / 240 * 24) % 16 + 1
    local progress = 0
    if since_bloom >= 0 then
      progress = math.max(0, math.min(1, (since_bloom - 240) / 960))
      progress = ease_tetra_in_out(progress)
    end
    local y = H * (0.8 - progress * 0.45)
    draw.img(string.format('butterflies/idle-back/%02d', frame), W * 0.5, y, 200 / 1.5)
  end

  s.destroy = function ()
  end

  return s
end
