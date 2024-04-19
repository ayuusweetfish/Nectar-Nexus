local draw = require 'draw_utils'

return function ()
  local s = {}
  local W, H = W, H

  local button = require 'button'
  local btn_next_fn = function ()
    replaceScene(sceneGameplay(4), transitions['fade'](0.1, 0.1, 0.1))
  end
  local btn_next = button(
    draw.get('icons/next'),
    btn_next_fn,
    H * 0.09 / 100 * 1.5
  )
  btn_next.x = W * 0.87
  btn_next.y = H * 0.84

  s.press = function (x, y)
    if btn_next.press(x, y) then return true end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if btn_next.move(x, y) then return true end
  end

  s.release = function (x, y)
    if btn_next.release(x, y) then return true end
  end

  s.key = function (key)
    if key == 'return' then btn_next_fn() end
  end

  local T = 0

  s.update = function ()
    T = T + 1
    btn_next.update()
  end

  local global_scale = 1 / 1.5
  local glaze_tile_tex = draw.get('still/p1-tiles')
  local glaze_tile_quad = love.graphics.newQuad(200, 100, 1200, 700, 1600, 800)

  local board_offs_x = (W - 1200 * global_scale) / 2
  local board_offs_y = (H - 700 * global_scale) / 2

  s.draw = function ()
    love.graphics.clear(0.02, 0.41, 0.38)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
      glaze_tile_tex, glaze_tile_quad,
      board_offs_x, board_offs_y,
      0, global_scale)

    -- Overlay
    for r = 0, 6 do
      for c = 0, 11 do
        local tr, tg, tb, i
        tr, tg, tb = 0.96, 0.98, 1
        if r <= 2 and r + c <= 7 then
          -- tr, tg, tb = 1, 0.95, 0.5
          i = 1
        elseif r >= 4 and r - c >= -1 then
          -- tr, tg, tb = 0.8, 1, 0.6
          i = 3
        elseif c <= 4 then
          -- tr, tg, tb = 1, 0.6, 0.6
          i = 2
        else
          -- tr, tg, tb = 0.6, 0.7, 1
          i = 0
        end
        local phase = (i / 4 + T / 240 * 0.15) % 1
        local alpha = 0
        if phase <= 0.25 then
          phase = phase * 4
          alpha = alpha + 0.3 * 0.5 * (1 - math.cos(math.pi * 2 * phase))
        end
        love.graphics.setColor(tr, tg, tb, alpha)
        love.graphics.rectangle('fill',
          board_offs_x + 100 * global_scale * c,
          board_offs_y + 100 * global_scale * r,
          100 * global_scale, 100 * global_scale)
      end
    end

    -- Butterfly
    love.graphics.setColor(1, 1, 1)
    local frame = math.floor(T / 240 * 24) % 16 + 1
    draw.img(string.format('butterflies/idle-side/%02d', frame),
      board_offs_x + 100 * global_scale * 5.5,
      board_offs_y + 100 * global_scale * 3.5,
      200 * global_scale)

    btn_next.draw()
  end

  s.destroy = function ()
  end

  return s
end
