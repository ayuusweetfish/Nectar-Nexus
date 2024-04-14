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
  local font = _G['font_Imprima']

  local overlay
  local since_enter_vase = -1
  local since_exit_vase = -1
  local vase_offs_x, vase_offs_y = 0, 0

  local t1 = love.graphics.newText(font(80), 'B')

  local btnStart = button(
    draw.enclose(love.graphics.newText(font(36), 'Start'), 120, 60),
    function () replaceScene(sceneIntro(), transitions['fade'](0.1, 0.1, 0.1)) end
  )
  btnStart.x0 = W * 0.5
  btnStart.y = H * 0.65
  local buttons = { btnStart }

  for i = 1, 6 do
    local img = draw.get('4f37d624f5c0d64a8bdbb799a67a1eef04403909')
    local w, h = img:getDimensions()
    local scale = H * 0.44 / h
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
    btn.x0 = W * (0.95 + i / 3)
    btn.y = H * 0.5
    buttons[#buttons + 1] = btn
  end

  local scroll_main = scroll({
    x_min = -W * 2.3,
    x_max = 0,
  })

  s.press = function (x, y)
    if since_exit_vase >= 0 then return true end
    if overlay ~= nil and overlay.press(x, y) then return true end
    scroll_main.press(x, y)
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end
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
    end
  end
  s.update()

  s.draw = function ()
    local sdx = scroll_main.dx

    local pushed_transform = false
    if since_enter_vase ~= -1 or since_exit_vase ~= -1 then
      local vase_offs_x, vase_offs_y = vase_offs_x, vase_offs_y
      local vase_scale
      local rate, offs_rate, scale_rate
      if since_exit_vase ~= -1 then
        rate = 1 - math.min(1, since_exit_vase / 240)
        offs_rate = ease_tetra_in_out(rate)
      else
        rate = math.min(1, since_enter_vase / 240)
        offs_rate = ease_exp_out(rate)
      end
      scale_rate = ease_tetra_in_out(rate)
      vase_offs_x = vase_offs_x * offs_rate
      vase_offs_y = vase_offs_y * offs_rate
      vase_scale = 1 + scale_rate * 1.75
      love.graphics.push()
      love.graphics.translate(W / 2, H / 2)
      love.graphics.scale(vase_scale)
      love.graphics.translate(-W / 2, -H / 2)
      love.graphics.translate(vase_offs_x, vase_offs_y)
      pushed_transform = true
    end

    love.graphics.clear(1, 1, 0.99)
    love.graphics.setColor(1, 1, 1)
    draw.img('intro_bg', W / 2 + sdx, H / 2, W, H)
    draw.shadow(0.95, 0.95, 0.95, 1, t1, W / 2 + sdx, H * 0.35)

    love.graphics.setColor(1, 1, 1)
    for i = 1, #buttons do buttons[i].draw() end

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
  local font = _G['font_Imprima']

  local since_enter = 0
  local empty_held = false
  local since_exit = -1

  local imgs = {
    draw.get('4aacb3873e809fbee671038f50392e1'),
    draw.get('4aacb3873e809fbee671038f50392e1'),
    draw.get('4aacb3873e809fbee671038f50392e1'),
    draw.get('4aacb3873e809fbee671038f50392e1'),
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
  end

  s.destroy = function ()
  end

  return s
end

return scene_intro
