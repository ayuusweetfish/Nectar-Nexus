local draw = require 'draw_utils'

return function (complete_fn)
  local s = {}
  local W, H = W, H

  local T = 0
  local progress, total
  local prio_done = false

  local butterfly_x = W * 0.05
  local butterfly_y = H * 0.9

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
    if total == nil or progress < total then
      local name
      progress, total, name = draw.load_img_step()
      print(name)
      if name:sub(1, 22) ~= 'butterflies/idle-side/' and name ~= 'bloom/visited/08' then
        prio_done = true
      end
      if progress == total then
        complete_fn()
        print('*finish')  -- This removes the progress text in the web page
        replaceScene(sceneIntro())
      end
    end
    local target_x = W * (0.05 + 0.85 * (progress / total))
    local target_y = H * (0.9 + 0.01 * math.sin(T / 240 * math.pi))
    butterfly_x = butterfly_x + (target_x - butterfly_x) * 0.015
    butterfly_y = butterfly_y + (target_y - butterfly_y) * 0.015
  end

  s.draw = function ()
    love.graphics.clear(0, 0, 0)
    if prio_done then
      local frame = 1 + math.floor(T / 240 * 24) % 16
      draw.img('bloom/visited/08',
        W * 0.95, H * 0.9, 120 / 1.5, 120 / 1.5)
      draw.img(string.format('butterflies/idle-side/%02d', frame),
        butterfly_x, butterfly_y, 200 / 1.5, 200 / 1.5)
    end
  end

  s.destroy = function ()
  end

  return s
end

