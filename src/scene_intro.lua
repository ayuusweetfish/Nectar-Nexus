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
  return 1 - (1 - x) * math.exp(-5 * x)
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

  local overlay
  local since_enter_vase = -1
  local since_exit_vase = -1
  local vase_offs_x, vase_offs_y = 0, 0

  local buttons = {}

  for i = 1, 6 do
    local img = draw.get('intro/large_vase_' .. tostring((i - 1) % 3 + 1))
    local w, h = img:getDimensions()
    local scale = H * 0.487 / h
    local btn
    btn = button(img, function ()
      since_enter_vase = 0
      vase_offs_x = W / 2 - btn.x
      vase_offs_y = H / 2 - btn.y
      overlay = create_overlay(function ()
        -- Back (from overlay to scene)
        since_enter_vase = -1
        since_exit_vase = 0
      end, function (i)
        -- Confirm
        _G['intro_scene_instance'] = s
        replaceScene(sceneGameplay(i))
      end)
    end, scale)
    btn.x0 = W * (1.33 + ({0.04, 0.3, 0.56, 1.04, 1.3, 1.56})[i])
    btn.y = H * ({0.5, 0.67, 0.45, 0.48, 0.64, 0.44})[i]
    buttons[#buttons + 1] = btn
  end

  local scroll_main = scroll({
    x_min = -W * 2.3,
    x_max = 0,
  })

  local press_x, press_y

  s.press = function (x, y)
    if since_exit_vase >= 0 then return true end
    if overlay ~= nil and overlay.press(x, y) then return true end
    scroll_main.press(x, y)
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end

    if scroll_main.dx >= -W * 0.3 then
      press_x, press_y = x, y
      return true
    end
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

  s.release = function (x, y)
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

  s.update = function ()
    if overlay ~= nil then overlay.update() end
    if since_enter_vase >= 0 then since_enter_vase = since_enter_vase + 1 end
    if since_exit_vase >= 0 then
      since_exit_vase = since_exit_vase + 1
      if since_exit_vase >= 240 then
        since_exit_vase = -1
        overlay = nil
      end
    end
    scroll_main.update()
    local sdx = scroll_main.dx
    for i = 1, #buttons do
      local b = buttons[i]
      b.x = b.x0 + sdx
      b.update()
      b.enabled = (i <= s.max_vase)
    end
  end
  s.update()

  s.draw = function ()
    local sdx = scroll_main.dx

    local pushed_transform = false
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
        offs_x_rate = ease_exp_out(rate)
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
      {'intro/small_vase_3', 0.600, 0.226},
      {'intro/small_vase_4', 0.940, 0.238},
      {'intro/small_vase_5', 0.946, 0.790},
      {'intro/small_vase_6', 0.112, 0.844},
    }
    local small_vase_limit = {
      0, 3, 6, 6, 6, 6
    }
    for i = 1, small_vase_limit[s.max_vase] do
      local n, x, y = unpack(small_vases[i])
      draw.img(n, W * (1.13 + x) + sdx, H * y,
        draw.get(n):getWidth() * scale)
    end

    love.graphics.setColor(1, 1, 1)
    for i = 1, #buttons do
      if i <= s.max_vase then buttons[i].draw() end
    end

    if pushed_transform then
      love.graphics.pop()
    end

    if overlay ~= nil then overlay.draw() end
  end

  s.destroy = function ()
  end

  return s
end

create_overlay = function (fn_back, fn_confirm)
  local s = {}
  local W, H = W, H

  local since_enter = 0
  local empty_held = false
  local since_exit = -1

  local imgs = {
    draw.get('weeds/p3-idle/06'),
    draw.get('weeds/p3-idle/06'),
    draw.get('weeds/p3-idle/06'),
    draw.get('weeds/p3-idle/06'),
  }

  local screen_x_min = W * 0.18
  local screen_x_max = W * 0.82
  local screen_y_min = H * 0.5 - W * 0.18
  local screen_y_max = H * 0.5 + W * 0.18
  local scroll_carousel = scroll({
    x_min = -(screen_x_max - screen_x_min) * 3,
    x_max = 0,
    screen_x_min = screen_x_min,
    screen_x_max = screen_x_max,
    screen_y_min = screen_y_min,
    screen_y_max = screen_y_max,
    carousel = true,
  })
  local scroll_pressed = false

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
        local i = scroll_carousel.carousel_page_index()
        fn_confirm(i)
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

--[[
    local sdx = scroll_carousel.dx
    love.graphics.setColor(1, 1, 1, ease_quad_in_out(rate))
    love.graphics.setScissor(
      screen_x_min, screen_y_min,
      screen_x_max - screen_x_min,
      screen_y_max - screen_y_min
    )
    for i = 1, 4 do
      local x = (screen_x_max - screen_x_min) * (i - 1)
      draw(imgs[i], W / 2 + sdx + x, H / 2,
        screen_x_max - screen_x_min, screen_y_max - screen_y_min)
    end
    love.graphics.setScissor()
]]
  end

  s.destroy = function ()
  end

  return s
end

return scene_intro
