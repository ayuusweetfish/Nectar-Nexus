local draw = require 'draw_utils'
local button = require 'button'
local scroll = require 'scroll'

local ease_quad_in_out = function (x)
  if x < 0.5 then return x * x * 2
  else return 1 - (1 - x) * (1 - x) * 2 end
end
local ease_tetra_in_out = function (x)
  if x < 0.5 then return x * x * x * x * 8
  else return 1 - (1 - x) * (1 - x) * (1 - x) * (1 - x) * 8 end
end
local ease_exp_out = function (x)
  return 1 - (1 - x) * math.exp(-3 * x)
end
local clamp_01 = function (x)
  if x < 0 then return 0
  elseif x > 1 then return 1
  else return x end
end

local create_overlay

local scene_intro = function ()
  local s = {}
  local W, H = W, H

  s.max_vase = 1
  local max_puzzle = 1
  local overlay_vase = 0

  local overlay
  local since_enter_vase = -1
  local since_exit_vase = -1
  local vase_offs_x, vase_offs_y = 0, 0
  local vase_sel_img, vase_sel_x, vase_sel_y

  local key_l, key_r = false, false
  local key_v = 0

  local buttons = {}
  local shadows = {}  -- {img, x0, y, scale}

  local vase_start_puzzle = {1, 7, 11, 17, 21, 25, 31}

  for i = 1, 6 do
    local genus = (i - 1) % 3 + 1
    local img = draw.get('intro/large_vase_' .. genus)
    local w, h = img:getDimensions()
    local scale = H * 0.487 / h
    local btn
    btn = button(img, function ()
      overlay_vase = i
      since_enter_vase = 0
      vase_offs_x = W / 2 - btn.x
      vase_offs_y = H / 2 - btn.y + H * ({-0.08, 0.00, 0.00})[genus]
      vase_sel_img = 'intro/large_vase_' .. genus .. '_sel'
      local sel_offs_x, sel_offs_y =
        unpack(({{0.00054, 0.1157}, {0, 0.0084}, {0, -0.016}})[genus])
      vase_sel_x = btn.x0 + W * sel_offs_x
      vase_sel_y = btn.y + H * sel_offs_y
      local vase_s = vase_start_puzzle[i]
      local vase_e = vase_start_puzzle[i + 1] - 1
      -- For vase overlay image processing:
      -- Scaled vase width is (w * scale * 2.75). Should adjust due to blurry edges.
      overlay = create_overlay(function ()
        -- Back (from overlay to scene)
        since_enter_vase = -1
        since_exit_vase = 0
      end, function (carousel_index)
        -- Confirm
        _G['intro_scene_instance'] = s
        replaceScene(sceneGameplay(vase_s + carousel_index - 1))
      end,
        vase_start_puzzle[i], vase_e,
        H * ({0.09, -0.015, -0.072})[genus])
      local n = math.min(vase_e, max_puzzle) - vase_s + 1
      overlay.set_num_pages(n)
      overlay.move_to_page(max_puzzle < vase_e and n or 1)
      key_v, key_l, key_r = 0, false, false -- Interrupt key-based scrolling
    end, scale)
    btn.x0 = W * (1.33 + ({0.04, 0.3, 0.56, 1.04, 1.3, 1.56})[i])
    btn.y = H * ({0.5, 0.67, 0.45, 0.48, 0.64, 0.44})[i]
    buttons[i] = btn
    local img = 'intro/large_vase_' .. tostring((i - 1) % 3 + 1) .. '_shadow'
    shadows[i] = {img, btn.x0, btn.y, scale}
  end

  s.overlay_back = function ()
    overlay.back()
  end

  local next_puzzle = function (puzzle_index)
    local v = 1
    while v < #vase_start_puzzle and
      vase_start_puzzle[v + 1] <= puzzle_index do v = v + 1 end
    s.max_vase = math.max(s.max_vase, v)
    max_puzzle = math.max(max_puzzle, puzzle_index)
    if overlay then
      local vase_s = vase_start_puzzle[overlay_vase]
      local vase_e = vase_start_puzzle[overlay_vase + 1] - 1
      overlay.set_num_pages(math.min(vase_e, max_puzzle) - vase_s + 1)
      overlay.move_to_page(math.min(vase_e, puzzle_index) - vase_s + 1)
    end
    -- Returns whether the current puzzle (puzzle_index) ends a vase
    return vase_start_puzzle[v] == puzzle_index
  end
  s.next_puzzle = next_puzzle

  local scroll_main = scroll({
    x_min = -W * 2.3,
    x_max = 0,
  })

  local press_x, press_y  -- For the nudging hint
  local T = 0
  local nnnn = 0

  s.press = function (x, y, button)
    if button ~= 1 then return false end
    if since_exit_vase >= 0 then return true end
    if overlay ~= nil and overlay.press(x, y) then return true end
    scroll_main.press(x, y)
    key_v, key_l, key_r = 0, false, false -- Interrupt key-based scrolling
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end

    if scroll_main.dx >= -W * 0.3 and T >= 360 then
      press_x, press_y = x, y
    end
    return true
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if since_exit_vase >= 0 then return true end
    if overlay ~= nil and overlay.move(x, y) then return true end
    local r = scroll_main.move(x, y)
    if r == 2 then
      for i = 1, #buttons do if buttons[i].cancel_pt(x, y) then return true end end
    end
    if r then return true end
    for i = 1, #buttons do if buttons[i].move(x, y) then return true end end
  end

  s.release = function (x, y, button)
    if since_exit_vase >= 0 then return true end
    if overlay ~= nil and overlay.release(x, y) then return true end
    scroll_main.release(x, y)
    for i = 1, #buttons do if buttons[i].release(x, y) then return true end end

    if press_x ~= nil then
      local dist_sq = (x - press_x) ^ 2 + (y - press_y) ^ 2
      if dist_sq <= (W * 0.03) ^ 2 then
        scroll_main.impulse(-5)
      end
      press_x, press_y = nil
    end
  end

  local update_button_positions = function ()
    local sdx = scroll_main.dx
    for i = 1, #buttons do
      local b = buttons[i]
      b.x = b.x0 + sdx
      b.update()
      b.enabled = (i <= s.max_vase)
    end
  end

  s.key = function (key)
    if key == 'n' then
      nnnn = nnnn + 1
      if nnnn == 10 then
        require('puzzles').debug_navi = true
      end
    else
      nnnn = 0
    end

    if since_exit_vase >= 0 then return true end
    if overlay ~= nil then
      overlay.key(key)
      return true
    end

    if require('puzzles').debug_navi and key == 'tab' then
      if s.max_vase < 7 then
        next_puzzle(vase_start_puzzle[s.max_vase + 1])
      end
    end
    if key == 'left' then key_l = true
    elseif key == 'right' then key_r = true
    elseif key == 'return' and scroll_main.is_inside_range() then
      local best_dist, best_button = 1/0, nil
      for i = 1, s.max_vase do
        local d = math.abs(buttons[i].x - W / 2)
        if best_dist > d then
          best_dist, best_button = d, i
        end
      end
      buttons[best_button].fn()
    end
  end

  s.keyrel = function (key)
    if key == 'left' then key_l = false
    elseif key == 'right' then key_r = false end
  end

  s.update = function ()
    T = T + 1
    if overlay ~= nil then overlay.update() end
    if since_enter_vase >= 0 then since_enter_vase = since_enter_vase + 1 end
    if since_exit_vase >= 0 then
      since_exit_vase = since_exit_vase + 1
      if since_exit_vase == 1 then
        local dx =
          math.min(0, vase_offs_x + W * 0.375) +
          math.max(0, vase_offs_x - W * 0.375)
        scroll_main.dx = scroll_main.dx + dx
        vase_offs_x = vase_offs_x - dx
        update_button_positions()
      elseif since_exit_vase >= 240 then
        since_exit_vase = -1
        overlay = nil
      end
    end
    local key_vtarget = (key_l and 4 or 0) + (key_r and -4 or 0)
    key_v = key_v + (key_vtarget - key_v) * (key_vtarget == 0 and 0.05 or 0.1)
    scroll_main.dx = scroll_main.dx + key_v
    scroll_main.update()
    update_button_positions()
  end
  s.update()

  s.draw = function ()
    local sdx = scroll_main.dx

    local pushed_transform = false
    local overlay_rate = 0
    if since_enter_vase ~= -1 or since_exit_vase ~= -1 then
      local vase_offs_x, vase_offs_y = vase_offs_x, vase_offs_y
      local vase_scale
      local rate, offs_x_rate, offs_y_rate, scale_rate
      if since_exit_vase ~= -1 then
        rate = 1 - math.min(1, since_exit_vase / 240)
        offs_x_rate = ease_tetra_in_out(rate)
        offs_y_rate = offs_x_rate
      else
        rate = math.min(1, since_enter_vase / 240)
        offs_x_rate = ease_quad_in_out(ease_exp_out(rate))
        offs_y_rate = ease_tetra_in_out(rate)
      end
      scale_rate = ease_tetra_in_out(rate)
      vase_offs_x = vase_offs_x * offs_x_rate
      vase_offs_y = vase_offs_y * offs_y_rate
      vase_scale = 1 + scale_rate * 1.75
      love.graphics.push()
      love.graphics.translate(W / 2, H / 2)
      love.graphics.scale(vase_scale)
      love.graphics.translate(-W / 2, -H / 2)
      love.graphics.translate(vase_offs_x, vase_offs_y)
      pushed_transform = true
      overlay_rate = rate
    end

    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1)
    draw.img('cover', W / 2 + sdx, H / 2, W, H)

    love.graphics.setColor(1, 1, 1)
    for i = 1, 3 do
      draw.img('intro/background_vases', W * (0.5 + i) + sdx, H * 0.5, W, H)
    end
    for i = 1, 3 do
      draw.img('intro/line', W * (0.64 + i) + sdx, H * 0.55, W)
    end

    local scale = H * 0.487 / draw.get('intro/large_vase_1'):getHeight()
    local small_vases = {
      {'intro/small_vase_1', 0.112, 0.296},
      {'intro/small_vase_2', 0.376, 0.248},
      {'intro/small_vase_6', 0.112, 0.844},
      {'intro/small_vase_3', 0.600, 0.226},
      {'intro/small_vase_4', 0.940, 0.238},
      {'intro/small_vase_5', 0.946, 0.790},

      {'intro/small_vase_6', 1.107, 0.296},
      {'intro/small_vase_1', 1.070, 0.762},
      {'intro/small_vase_3', 1.395, 0.240},
      {'intro/small_vase_2', 1.600, 0.226},
      {'intro/small_vase_5', 1.940, 0.238},
      {'intro/small_vase_4', 1.970, 0.790},
      {'intro/small_vase_1', 2.1, 0.34},
    }
    local small_vase_limit = {
      0, 3, 6, 8, 10, 13, 13
    }
    for i = 1, small_vase_limit[s.max_vase] do
      local n, x, y = unpack(small_vases[i])
      draw.img(n, W * (1.13 + x) + sdx, H * y,
        draw.get(n):getWidth() * scale)
    end

    if s.max_vase == 7 then
      love.graphics.setColor(1, 1, 1)
      local x = 1.65
      draw.img('intro/graffiti_1', W * x + sdx, H * 0.5, W, H)
      draw.img('intro/graffiti_2', W * (x + 1.134) + sdx, H * 0.5, W, H)
    end

    love.graphics.setColor(1, 1, 1)
    for i = 1, math.min(6, s.max_vase) do
      local img, x0, y, scale = unpack(shadows[i])
      draw.img(img, x0 + sdx + W * 0.06, y + H * 0.04, draw.get(img):getWidth() * scale)
      buttons[i].draw()
    end

    if vase_sel_img then
      love.graphics.setColor(1, 1, 1, ease_tetra_in_out(overlay_rate))
      draw.img(vase_sel_img,
        vase_sel_x + sdx, vase_sel_y,
        draw.get(vase_sel_img):getWidth() / 2.75)
    end

    -- Butterfly (Bee!)
    local butterfly_x, butterfly_y = unpack(({
      {0.1, 0.5},
      {0.39, 0.68},
      {0.64, 0.46},
      {1.12, 0.51},
      {1.38, 0.71},
      {1.65, 0.45},
      {2.12, 0.63},
    })[s.max_vase])
    local frame = math.floor(T / 240 * 24) % 16 + 1
    love.graphics.setColor(1, 1, 1, 1)
    draw.img(string.format('butterflies/idle-side/%02d', frame),
      W * (1.13 + butterfly_x) + sdx, H * butterfly_y, 200 / 1.5)

    if pushed_transform then
      love.graphics.pop()
    end

    if overlay ~= nil then overlay.draw() end
  end

  s.destroy = function ()
  end

  return s
end

create_overlay = function (fn_back, fn_confirm, range_start, range_end, offs_y)
  local s = {}
  local W, H = W, H

  local since_enter = 0
  local empty_held = false
  local since_exit = -1

  local n = range_end - range_start + 1

  local range_w, range_x_cen = W * 0.6, W * 0.5
  local range_h, range_y_cen = H * 0.7, H * 0.6
  local screen_x_min = range_x_cen - range_w / 2
  local screen_x_max = range_x_cen + range_w / 2
  local screen_y_min = range_y_cen - range_h / 2
  local screen_y_max = range_y_cen + range_h / 2
  local scroll_carousel = scroll({
    x_min = 0,
    x_max = 0,
    screen_x_min = screen_x_min,
    screen_x_max = screen_x_max,
    screen_y_min = screen_y_min,
    screen_y_max = screen_y_max,
    carousel = true,
  })
  local scroll_pressed = false

  s.set_num_pages = function (new_n)
    scroll_carousel.set_x_min(-(screen_x_max - screen_x_min) * (new_n - 1))
  end
  s.set_num_pages(n)

  s.move_to_page = function (i)
    scroll_carousel.dx = (i - 1) * -(screen_x_max - screen_x_min)
  end

  s.press = function (x, y)
    if since_enter <= 240 then return true end
    if scroll_carousel.press(x, y) then
      scroll_pressed = true
      return true
    end
    empty_held = true
    return true
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    local r = scroll_carousel.move(x, y)
    if r == 2 then scroll_pressed = false end   -- Cancel press
    if r then return true end
    return true
  end

  s.release = function (x, y)
    if scroll_carousel.release(x, y) then
      if scroll_pressed then
        -- Pressed on scroll area and not cancelled, confirm
        fn_confirm(scroll_carousel.carousel_page_index())
      end
      return true
    end
    if empty_held then
      fn_back()
      since_exit = 0
    end
    scroll_pressed = false
    return true
  end

  s.back = function ()
    if since_exit == -1 then
      fn_back()
      since_exit = 0
    end
  end

  s.key = function (key)
    if since_enter <= 240 then return true end
    if key == 'escape' then
      s.back()
      return true
    elseif key == 'left' then
      scroll_carousel.carousel_flip_page(1)
    elseif key == 'right' then
      scroll_carousel.carousel_flip_page(-1)
    elseif key == 'return' then
      fn_confirm(scroll_carousel.carousel_page_index())
    end
  end

  s.update = function ()
    since_enter = since_enter + 1
    if since_exit >= 0 then since_exit = since_exit + 1 end
    scroll_carousel.update()
  end

  s.draw = function ()
    local rate = clamp_01((since_enter - 240) / 60)
    if since_exit >= 0 then
      rate = 1 - clamp_01(since_exit / 40)
    end

    local sdx = scroll_carousel.dx
    local base_alpha = ease_quad_in_out(rate)
    love.graphics.setScissor(
      screen_x_min, screen_y_min,
      screen_x_max - screen_x_min,
      screen_y_max - screen_y_min
    )
    for i = 1, n do
      local x = sdx + (screen_x_max - screen_x_min) * (i - 1)
      local r = math.min(1, x / ((screen_x_max - screen_x_min) / 2))
      local alpha = 1 - ease_quad_in_out(r)
      love.graphics.setColor(1, 1, 1, alpha * base_alpha)
      draw.img(string.format('icons/number_%02d', i + range_start - 1),
        W / 2 + x, H / 2 + offs_y)
    end
    love.graphics.setScissor()
  end

  s.destroy = function ()
  end

  return s
end

return scene_intro
