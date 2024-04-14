local draw = require 'draw_utils'
local button = require 'button'
local scroll = require 'scroll'

local ease_quad_in_out = function (x)
  if x < 0.5 then return x * x * 2
  else return 1 - (1 - x) * (1 - x) * 2 end
end
local ease_exp_out = function (x)
  return 1 - (1 - x) * math.exp(-3 * x)
end

local create_overlay

local scene_intro = function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_Imprima']

  local overlay
  local since_enter_vase = -1
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
      overlay = create_overlay(i)
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
    if overlay ~= nil and overlay.press(x, y) then return true end
    scroll_main.press(x, y)
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if overlay ~= nil and overlay.move(x, y) then return true end
    local r = scroll_main.move(x, y)
    if r == 2 then
      for i = 1, #buttons do if buttons[i].cancel_pt(x, y) then return true end end
    end
    if r then return true end
    for i = 1, #buttons do if buttons[i].move(x, y) then return true end end
  end

  s.release = function (x, y)
    if overlay ~= nil and overlay.release(x, y) then return true end
    scroll_main.release(x, y)
    for i = 1, #buttons do if buttons[i].release(x, y) then return true end end
  end

  s.update = function ()
    if overlay ~= nil then overlay.update() end
    if since_enter_vase >= 0 then since_enter_vase = since_enter_vase + 1 end
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

    if since_enter_vase ~= -1 then
      local vase_offs_x, vase_offs_y = vase_offs_x, vase_offs_y
      local vase_scale
      local rate = math.min(1, since_enter_vase / 240)
      vase_offs_x = vase_offs_x * ease_exp_out(rate)
      vase_offs_y = vase_offs_y * ease_exp_out(rate)
      vase_scale = 1 + ease_quad_in_out(rate) * 1.75
      love.graphics.push()
      love.graphics.translate(W / 2, H / 2)
      love.graphics.scale(vase_scale)
      love.graphics.translate(-W / 2, -H / 2)
      love.graphics.translate(vase_offs_x, vase_offs_y)
    end

    love.graphics.clear(1, 1, 0.99)
    love.graphics.setColor(1, 1, 1)
    draw.img('intro_bg', W / 2 + sdx, H / 2, W, H)
    draw.shadow(0.95, 0.95, 0.95, 1, t1, W / 2 + sdx, H * 0.35)

    love.graphics.setColor(1, 1, 1)
    for i = 1, #buttons do buttons[i].draw() end

    if since_enter_vase ~= -1 then
      love.graphics.pop()
    end

    if overlay ~= nil then overlay.draw() end
  end

  s.destroy = function ()
  end

  return s
end

create_overlay = function (cen, img_small, img_large)
  local s = {}
  local W, H = W, H
  local font = _G['font_Imprima']

  local since_enter = 0

  s.press = function (x, y)
    return true
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    return true
  end

  s.release = function (x, y)
    return true
  end

  s.update = function ()
    since_enter = since_enter + 1
  end

  s.draw = function ()
  end

  s.destroy = function ()
  end

  return s
end

return scene_intro
