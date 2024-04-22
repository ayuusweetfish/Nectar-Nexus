local draw = require 'draw_utils'

local ease_quad_in_out = function (x)
  if x < 0.5 then return x * x * 2
  else return 1 - (1 - x) * (1 - x) * 2 end
end

return function (palette_num, activate_imm)
  local s = {}
  local W, H = W, H

  local bg_tint = {
    {0.02, 0.41, 0.38},
    {0.73, 0.61, 0.66},
    {0.10, 0.00, 0.00},
  }
  bg_tint = bg_tint[palette_num]

  local active = false
  local since_in = -1
  local since_out = -1
  local T = 0

  if activate_imm then
    active = true
    since_in = 240
  end

  local button = require 'button'
  local btn_next
  local btn_next_since_out = -1 -- Separate timer, as this does not recover
  local btn_next_fn = function ()
    if active and since_out == -1 then
      since_out = 0
      if btn_next_since_out == -1 then
        btn_next_since_out = 0
      end
    end
  end
  -- Only show the button if the overlay is automatically activated
  if activate_imm then
    btn_next = button(
      draw.get('icons/next'),
      btn_next_fn,
      H * 0.09 / 100 * 1.5
    )
    btn_next.x = W * 0.87
    btn_next.y = H * 0.84
  end

  local btn_icon = button(
    draw.get('icons/diagram'),
    function ()
      if not active or since_out >= 0 then
        active = true
        since_in = 0
        since_out = -1
      end
    end,
    H * 0.09 / 100 * 1.5
  )
  btn_icon.x = W * 0.87
  btn_icon.y = H * 0.16

  s.press = function (x, y)
    if (not active or since_out >= 0) and btn_icon.press(x, y) then return true end
    if not active then return false end
    if btn_next and btn_next_since_out == -1 and btn_next.press(x, y) then return true end
    return true   -- Capture pointer events when active
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if (not active or since_out >= 0) and btn_icon.move(x, y) then return true end
    if not active then return false end
    if btn_next and btn_next_since_out == -1 and btn_next.move(x, y) then return true end
    return true
  end

  s.release = function (x, y)
    if (not active or since_out >= 0) and btn_icon.release(x, y) then return true end
    if not active then return false end
    if btn_next and btn_next_since_out == -1 and btn_next.release(x, y) then return true end
    -- If not automatically activated (for the first time), press anywhere closes the overlay
    if not btn_next or btn_next_since_out >= 0 then btn_next_fn() end
    return true
  end

  s.key = function (key)
    if not active then return false end
    if key == 'return' or key == 'escape' or (key == 'right' and require('puzzles').debug_navi) then
      btn_next_fn()
      return true
    end
  end

  s.update = function ()
    if active then
      T = T + 1
      if since_in >= 0 then
        since_in = since_in + 1
      end
      if since_out >= 0 then
        since_out = since_out + 1
        if since_out == 240 then
          since_out = -1
          active = false
        end
      end
      if btn_next then
        btn_next.update()
        if btn_next_since_out >= 0 then
          btn_next_since_out = btn_next_since_out + 1
          if btn_next_since_out >= 240 then
            btn_next = nil
          end
        end
      end
    end
    btn_icon.update()
  end

  local global_scale = 1 / 1.5
  local glaze_tile_tex = draw.get(string.format('still/p%d-tiles', palette_num))
  local glaze_tile_quad = love.graphics.newQuad(200, 100, 1200, 700, 1600, 800)

  local board_offs_x = (W - 1200 * global_scale) / 2
  local board_offs_y = (H - 700 * global_scale) / 2

  local alpha = function ()
    local a = 0
    if active then
      a = ease_quad_in_out(math.min(1, since_in / 90))
      if since_out >= 0 then
        a = a * ease_quad_in_out(1 - math.min(1, since_out / 90))
      end
    end
    return a
  end
  s.alpha = alpha

  s.draw = function ()
    local global_alpha = alpha()

    local bg_r, bg_g, bg_b = unpack(bg_tint)
    love.graphics.setColor(bg_r, bg_g, bg_b, global_alpha * 0.5)
    love.graphics.rectangle('fill', 0, 0, W, H)

    love.graphics.setColor(
      1 - (1 - bg_r) * 0.1,
      1 - (1 - bg_g) * 0.1,
      1 - (1 - bg_b) * 0.1,
      global_alpha)
    love.graphics.draw(
      glaze_tile_tex, glaze_tile_quad,
      board_offs_x, board_offs_y,
      0, global_scale)
    draw.img('still/tutorial-overlay',
      W / 2, H / 2, 1280 * global_scale, 720 * global_scale)

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
          local phase = phase * 4
          alpha = alpha + 0.3 * 0.5 * (1 - math.cos(math.pi * 2 * phase))
        end
        love.graphics.setColor(tr, tg, tb, alpha * global_alpha)
        love.graphics.rectangle('fill',
          board_offs_x + 100 * global_scale * c,
          board_offs_y + 100 * global_scale * r,
          100 * global_scale, 100 * global_scale)
        -- Flower?
        local bloom_alpha = 0
        local bloom_frame
        local butterfly_alpha = 0
        local butterfly_frame, butterfly_flip_x
        local butterfly_x, butterfly_y
        if ((r == 1 and c == 4) or (r == 5 and c == 4) or
            (r == 3 and c == 2) or (r == 3 and c == 8))
           and phase <= 0.25 then
          local phase = phase * 4
          -- Blossom
          bloom_alpha = 0.5 * (1 - math.cos(math.pi * 2 * phase))
          if phase >= 0.5 then
            bloom_alpha = bloom_alpha * bloom_alpha
          end
          if phase < 6 / 28 then
            bloom_frame = string.format('bloom/idle/%02d',
              math.min(6, 1 + math.floor(phase * 28)))
          else
            bloom_frame = string.format('bloom/visited/%02d',
              math.min(8, 1 + math.floor(phase * 28 - 6)))
          end
          -- Butterfly
          if phase >= 5 / 28 then
            butterfly_x, butterfly_y = 5.5, 3.5
            butterfly_alpha = 0.7 * ease_quad_in_out(
              math.max(0, math.min(1, (phase - 5 / 24) * 4, (18 / 24 - phase) * 4)))
            local dx, dy
            local turn_aseq, idle_aseq
            if c == 4 then
              -- Up/down
              dx, dy = 0, (r == 1 and -1 or 1)
              local facing = (r == 1 and 'back' or 'front')
              local frame = 1 + math.floor(phase * 28 - 5)
              if frame <= 6 then
                butterfly_frame = string.format('butterflies/turn-side-%s/%02d', facing, frame)
              else
                frame = (frame - 6 - 1) % 16 + 1
                butterfly_frame = string.format('butterflies/idle-%s/%02d', facing, frame)
              end
            elseif r == 3 and c == 2 then
              -- Left
              dx, dy = -0.2, 0
              local frame = (phase * 28 - 5)
              if frame < 6 then
                if frame < 3 then
                  butterfly_frame = string.format('butterflies/turn-side-front/%02d', math.floor(frame) + 1)
                else
                  butterfly_frame = string.format('butterflies/turn-front-side/%02d', math.floor(frame - 3) + 1)
                  butterfly_flip_x = true
                end
              else
                frame = math.floor(frame - 6) % 16 + 1
                butterfly_frame = string.format('butterflies/idle-side/%02d', frame)
                butterfly_flip_x = true
              end
            elseif r == 3 and c == 8 then
              -- Right
              dx, dy = 1, 0
              local frame = 1 + math.floor(phase * 28 - 5) % 16
              butterfly_frame = string.format('butterflies/idle-side/%02d', frame)
            end
            local move_progress = ease_quad_in_out(math.min(1, (phase - 5 / 24) * 3))
            butterfly_x = butterfly_x + dx * move_progress
            butterfly_y = butterfly_y + dy * move_progress
          end
        end
        if bloom_alpha > 0 then
          love.graphics.setColor(1, 1, 1, bloom_alpha * global_alpha)
          draw.img(bloom_frame,
            board_offs_x + 100 * global_scale * (c + 0.59),
            board_offs_y + 100 * global_scale * (r + 0.5),
            120 * global_scale,
            120 * global_scale
          )
        end
        if butterfly_alpha > 0 then
          love.graphics.setColor(1, 1, 1, butterfly_alpha * global_alpha)
          draw.img(butterfly_frame,
            board_offs_x + 100 * global_scale * butterfly_x,
            board_offs_y + 100 * global_scale * butterfly_y,
            (butterfly_flip_x and -200 or 200) * global_scale,
            200 * global_scale
          )
        end
      end
    end

    -- Butterfly
    love.graphics.setColor(1, 1, 1, global_alpha)
    local frame = math.floor(T / 240 * 24) % 16 + 1
    draw.img(string.format('butterflies/idle-side/%02d', frame),
      board_offs_x + 100 * global_scale * 5.5,
      board_offs_y + 100 * global_scale * 3.5,
      200 * global_scale)

    if btn_next then
      local alpha = 1
      if btn_next_since_out >= 0 then
        alpha = ease_quad_in_out(1 - math.min(1, btn_next_since_out / 240))
      end
      love.graphics.setColor(1, 1, 1, alpha * global_alpha)
      btn_next.draw()
    end

    love.graphics.setColor(1, 1, 1, 1 - global_alpha)
    btn_icon.s = 1
    if since_out >= 0 then
      local x = math.min(1, since_out / 240)
      btn_icon.s = 1 + (1 - x) * math.exp(-4 * x) * 0.4
    end
    btn_icon.draw()
  end

  s.destroy = function ()
  end

  return s
end
