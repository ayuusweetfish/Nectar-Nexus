local draw = require 'draw_utils'
local Board = require 'board'
local puzzles = require 'puzzles'
local particles = require 'particles'

local ease_quad_in_out = function (x)
  if x < 0.5 then return x * x * 2
  else return 1 - (1 - x) * (1 - x) * 2 end
end
local ease_exp_out = function (x)
  return 1 - (1 - x) * math.exp(-3 * x)
end
local clamp_01 = function (x)
  if x < 0 then return 0
  elseif x > 1 then return 1
  else return x end
end

return function (puzzle_index)
  local s = {}
  local W, H = W, H
  local font = _G['font_Imprima']

  puzzle_index = puzzle_index or 23 -- #puzzles
  local board = Board.create(puzzles[puzzle_index])

  local text_puzzle_name = love.graphics.newText(font(60), tostring(puzzle_index))

  local button = require 'button'
  local buttons = {}

  local btn_undo, btn_undo_fn
  btn_undo = button(
    draw.enclose(love.graphics.newText(font(36), 'Undo'), 120, 60),
    function () btn_undo_fn() end
  )
  btn_undo.x = W * 0.15
  btn_undo.y = H * 0.18
  btn_undo.enabled = false
  btn_undo.response_when_disabled = true
  buttons[#buttons + 1] = btn_undo

  local btn_back = button(
    draw.enclose(love.graphics.newText(font(36), 'Return'), 120, 60),
    function ()
      local other_scene = _G['intro_scene_instance']
      if other_scene then
        replaceScene(other_scene)
      end
    end
  )
  btn_back.x = W * 0.15
  btn_back.y = H * 0.08
  buttons[#buttons + 1] = btn_back

  local btn_next = button(
    draw.enclose(love.graphics.newText(font(36), 'Next'), 120, 60),
    function ()
      local index = puzzle_index % #puzzles + 1
      replaceScene(sceneGameplay(index), transitions['fade'](0.1, 0.1, 0.1))
    end
  )
  btn_next.x = W * 0.8
  btn_next.y = H * 0.9
  btn_next.enabled = false
  buttons[#buttons + 1] = btn_next

  local cell_w = math.min(100, H * 0.92 / board.nrows, W * 0.9 / board.ncols)
  local board_offs_x = (W - cell_w * board.ncols) / 2
  local board_offs_y = (H - cell_w * board.nrows) / 2
  local cell_scale = cell_w / 100

  local pt_to_cell = function (x, y)
    local c = math.floor((x - board_offs_x) / cell_w)
    local r = math.floor((y - board_offs_y) / cell_w)
    if r < 0 or r >= board.nrows or c < 0 or c >= board.ncols then
      return nil
    end
    return r, c
  end

  local pt_r, pt_c
  local pt_bloom

  local board_anims
  local since_anim = 0

  local trigger_wait = 0  -- Animation length
  local trigger_buffer = {}

  local anim_dur = {
    -- Butterfly
    ['move'] = 60,
    ['turn'] = 90,
    ['spawn_from_weeds'] = 120,
    ['eaten'] = 120,

    -- Chameleon
    ['eat'] = 110,
    ['provoke'] = 110,

    -- Blossom
    ['use'] = 50,

    -- Pollen
    ['pollen_visit'] =  90, -- 110
    ['pollen_match'] = 240, -- 300
  }

  local trigger_imm = function (r, c)
    if r ~= nil and c == nil then
      board_anims = board.trigger_bloom(r)
    else
      board_anims = board.trigger(r, c)
    end

    -- Update animation durations
    trigger_wait = 0
    if board_anims ~= nil then
      for _, anims in pairs(board_anims) do
        for name, _ in pairs(anims) do
          trigger_wait = math.max(trigger_wait, anim_dur[name] or 0)
        end
      end
    end

    btn_undo.enabled = board.can_undo()
    since_anim = 0
  end
  local flush_trigger_buffer = function ()
    if since_anim >= trigger_wait and #trigger_buffer > 0 then
      trigger_imm(unpack(trigger_buffer[1]))
      table.remove(trigger_buffer, 1)
    end
  end
  local trigger = function (r, c)
    trigger_buffer[#trigger_buffer + 1] = {r, c}
    flush_trigger_buffer()
  end

  btn_undo_fn = function ()
    board.undo()
    btn_undo.enabled = board.can_undo()
    board_anims = nil
    trigger_wait = 0
    trigger_buffer = {}
  end

  local group_colours = {
    {0.8, 0.5, 1},
    {0.5, 0.9, 0.5},
    {0.4, 0.8, 1},
    {1, 0.8, 0.5},
  }

  local psys = {}
  local psys_by_obj = {}
  local obj_by_psys = {}
  board.each('pollen', function (o)
    local p = particles({ scale = cell_scale })
    p.x = board_offs_x + cell_w * (o.c + 0.5)
    p.y = board_offs_y + cell_w * (o.r + 0.5)
    local r, g, b = unpack(group_colours[o.group])
    p.tint = {1 - (1 - r) * 0.5, 1 - (1 - g) * 0.5, 1 - (1 - b) * 0.5}
    psys[#psys + 1] = p
    psys_by_obj[o] = p
    obj_by_psys[p] = o
  end)
  board.each('bloom', function (o)
    local p = particles({ y_max = 40, x_spread = 40, scale = cell_scale })
    p.x = board_offs_x + cell_w * (o.c + 0.5)
    p.y = board_offs_y + cell_w * (o.r + 0.5)
    p.tint = {1, 0.6, 0.5}
    psys[#psys + 1] = p
    psys_by_obj[o] = p
    obj_by_psys[p] = o
  end)

  local since_clear = -1

  s.press = function (x, y)
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end
    pt_r, pt_c = pt_to_cell(x, y)
    pt_bloom = false
    if pt_r ~= nil then
      local o = board.find_one(pt_r, pt_c, 'bloom')
      if o ~= nil and not o.used then
        pt_bloom = true
      end
    end
    return true
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    for i = 1, #buttons do if buttons[i].move(x, y) then return true end end
    return true
  end

  s.release = function (x, y)
    for i = 1, #buttons do if buttons[i].release(x, y) then return true end end
    local r1, c1 = pt_to_cell(x, y)
    if r1 == pt_r and c1 == pt_c then
      trigger(r1, c1)
    end
    pt_r, pt_c, pt_bloom = nil, nil, false
    return true
  end

  -- 1 ~ 9: trigger blossom
  -- 0/Enter/Tab/Space/N: move on without triggering blossom
  -- Backspace/Z/P/U/R: undo
  s.key = function (key)
    if key == 'backspace' or key == 'z' or key == 'p' or key == 'u' or key == 'r' then
      btn_undo_fn()
    elseif key == 'return' or key == 'tab' or key == 'space' or key == 'n' then
      trigger(nil, nil)
    elseif #key == 1 and key >= '0' and key <= '9' then
      local index = string.byte(key, 1) - 48
      if index == 0 then
        trigger(nil, nil)
      else
        trigger(index)
      end
    end

    if key == 'left' or key == 'right' then
      local index = (puzzle_index + (key == 'left' and #puzzles - 2 or 0)) % #puzzles + 1
      replaceScene(sceneGameplay(index), transitions['fade'](0.1, 0.1, 0.1))
    end
  end

  local T = 0

  s.update = function ()
    T = T + 1

    for i = 1, #buttons do buttons[i].update() end
    since_anim = since_anim + 1 + #trigger_buffer
    flush_trigger_buffer()
    for i = 1, #psys do psys[i].update() end

    if since_clear == -1 and board.cleared then
      since_clear = 0
    elseif not board.cleared then
      since_clear = -1
      btn_next.enabled = false
    end
    if since_clear >= 0 then
      since_clear = since_clear + 1
      btn_next.enabled = (since_clear >= 240)
    end
  end

  local find_anim = function (o, name)
    if board_anims == nil then return nil end
    if board_anims[o] == nil then return nil end
    return board_anims[o][name]
  end

  local aseq = {}
  aseq.butterfly_idle_side = {}
  aseq.butterfly_idle_front = {}
  aseq.butterfly_idle_back = {}
  for i = 1, 16 do
    aseq.butterfly_idle_side[i] = string.format('butterflies/idle-side/%02d', i)
    aseq.butterfly_idle_front[i] = string.format('butterflies/idle-front/%02d', i)
    aseq.butterfly_idle_back[i] = string.format('butterflies/idle-back/%02d', i)
  end

  local aseq_get = function (seq_name, frame_rate)
    local n = math.floor(T / 240 * frame_rate)
    local list = aseq[seq_name]
    return list[n % #list + 1]
  end

  s.draw = function ()
--[[
    love.graphics.clear(0, 0.01, 0.03)
]]
    love.graphics.clear(0.16, 0.17, 0.32)

    -- Grid lines
    love.graphics.setColor(0.95, 0.95, 0.95, 0.3)
    love.graphics.setLineWidth(2.0)
    for r = 0, board.nrows do
      local y = board_offs_y + cell_w * r
      local x0 = board_offs_x
      local x1 = board_offs_x + cell_w * board.ncols
      love.graphics.line(x0, y, x1, y)
    end
    for c = 0, board.ncols do
      local x = board_offs_x + cell_w * c
      local y0 = board_offs_y
      local y1 = board_offs_y + cell_w * board.nrows
      love.graphics.line(x, y0, x, y1)
    end

    -- Objects
    board.each('obstacle', function (o)
      love.graphics.setColor(0.7, 0.7, 0.7, 0.3)
      love.graphics.rectangle('fill',
        board_offs_x + cell_w * o.c,
        board_offs_y + cell_w * o.r,
        cell_w, cell_w)
    end)
    board.each('reflect_obstacle', function (o)
      love.graphics.setColor(1, 0.8, 0.7, 0.5)
      love.graphics.rectangle('fill',
        board_offs_x + cell_w * o.c,
        board_offs_y + cell_w * o.r,
        cell_w, cell_w)
    end)
    board.each('weeds', function (o)
      love.graphics.setColor(0.7, 1, 0.8, 0.5)
      love.graphics.rectangle('fill',
        board_offs_x + cell_w * o.c,
        board_offs_y + cell_w * o.r,
        cell_w, cell_w)
    end)
    board.each('chameleon', function (o)
      local anim_progress = clamp_01((since_anim - 50) / 60)
      -- When `eat` is active, `provoke` does not matter (progress set to -1)
      -- (provoke, eat) = (0, 0) and (1, 1) are the same thing
      local provoke_progress = (o.provoked and 1 or 0)
      local eat_progress = 0
      if anim_progress < 1 then
        local a_provoke = find_anim(o, 'provoke')
        local a_eat = find_anim(o, 'eat')
        local a_idle = find_anim(o, 'return_idle')
        if a_provoke then
          provoke_progress = ease_quad_in_out(anim_progress)
        elseif a_eat then
          provoke_progress = -1
          eat_progress = ease_quad_in_out(anim_progress)
        elseif a_idle then
          provoke_progress = 1 - ease_quad_in_out(anim_progress)
        end
      end
      local alpha = 0.3
      if provoke_progress == -1 then alpha = alpha + 0.5 * (1 - eat_progress)
      else alpha = alpha + 0.5 * provoke_progress end
      love.graphics.setColor(1, 0.8, 0.8, alpha)
      love.graphics.rectangle('fill',
        board_offs_x + cell_w * o.c,
        board_offs_y + cell_w * o.r,
        cell_w * ((o.range_x or 0) + 1),
        cell_w * ((o.range_y or 0) + 1))
    end)
    board.each('bloom', function (o)
      local used_rate = (o.used and 1 or 0)
      local anim_progress = clamp_01(since_anim / 50)
      if anim_progress < 1 and find_anim(o, 'use') then
        used_rate = ease_exp_out(anim_progress)
      end
      love.graphics.setColor(1, 0.4, 0.5, 1 - 0.8 * used_rate)
      love.graphics.circle('fill',
        board_offs_x + cell_w * (o.c + 0.5),
        board_offs_y + cell_w * (o.r + 0.5),
        cell_w * (0.15 + 0.25 * used_rate))

      local used_rate = (o.used and 1 or 0)
      local anim_progress = clamp_01(since_anim / 90)
      if anim_progress < 1 and find_anim(o, 'use') then
        used_rate = ease_exp_out(anim_progress)
      end
      psys_by_obj[o].ordinary_fade = used_rate
    end)

    -- Animated positions
    local butterfly_animated_pos = {}
    board.each('butterfly', function (o)
      local r0, c0 = o.r, o.c
      local anim_progress = clamp_01((since_anim -
        (find_anim(o, 'turn') and 30 or (find_anim(o, 'spawn_from_weeds') and 60 or 0))) / 60)
      if anim_progress < 1 then
        local a = find_anim(o, 'move')
        if a ~= nil then
          anim_progress = ease_exp_out(anim_progress)
          r0 = a.from_r + (r0 - a.from_r) * anim_progress
          c0 = a.from_c + (c0 - a.from_c) * anim_progress
        end
      end
      local x0 = board_offs_x + cell_w * (c0 + 0.5)
      local y0 = board_offs_y + cell_w * (r0 + 0.5)
      butterfly_animated_pos[o] = {x0, y0}
    end)

    board.each('pollen', function (o)
      local tint = group_colours[o.group]

      local shadow_radius = (o.matched and 0 or 1)
      local anim_progress = clamp_01((since_anim - 120) / 60)
      if anim_progress < 1 and find_anim(o, 'pollen_match') then
        shadow_radius = 1 - ease_quad_in_out(anim_progress)
      end
      love.graphics.setColor(tint[1], tint[2], tint[3], 0.2)
      love.graphics.circle('fill',
        board_offs_x + cell_w * (o.c + 0.5),
        board_offs_y + cell_w * (o.r + 0.5),
        cell_w * shadow_radius * 0.4)
      love.graphics.setColor(tint[1], tint[2], tint[3], 0.2 * (1 - shadow_radius))
      love.graphics.setLineWidth(2.0)
      love.graphics.circle('line',
        board_offs_x + cell_w * (o.c + 0.5),
        board_offs_y + cell_w * (o.r + 0.5),
        cell_w * 0.4)

      local highlight_radius = (o.visited and 0 or 1)
      local anim_progress = clamp_01((since_anim - 50) / 60)
      if anim_progress < 1 and find_anim(o, 'pollen_visit') ~= nil then
        highlight_radius = 1 - ease_quad_in_out(anim_progress)
      end
      if highlight_radius > 0 then
        love.graphics.setColor(tint[1], tint[2], tint[3], 1)
        love.graphics.circle('fill',
          board_offs_x + cell_w * (o.c + 0.5),
          board_offs_y + cell_w * (o.r + 0.5),
          cell_w * highlight_radius * 0.4)
      end

      -- Particles following a butterfly?
      local follow, follow_rate = nil, 0
      if o.carrier then
        follow = butterfly_animated_pos[o.carrier]
        follow_rate = 1
        if find_anim(o, 'pollen_visit') ~= nil then
          follow = {
            board_offs_x + cell_w * (o.carrier.c + 0.5),
            board_offs_y + cell_w * (o.carrier.r + 0.5),
          }
          follow_rate = ease_exp_out(anim_progress)
        end
      end
      psys_by_obj[o].follow = follow
      psys_by_obj[o].follow_rate = follow_rate

      -- Particles waving and fading out due to matching?
      local wave_out = (o.matched and 1 or 0)
      local anim_progress = clamp_01((since_anim - 60) / 240)
      if anim_progress < 1 and find_anim(o, 'pollen_match') then
        wave_out = ease_quad_in_out(anim_progress)
      end
      psys_by_obj[o].wave_out = wave_out
    end)

    -- Particle systems (under butterflies)
    for i = 1, #psys do
      local p = psys[i]
      local o = obj_by_psys[p]
      if o.name == 'bloom' or (o.name == 'pollen' and not o.visited) then
        p.draw()
      end
    end

--[[
    board.each('butterfly', function (o)
      local x0, y0 = unpack(butterfly_animated_pos[o])

      local alpha = find_anim(o, 'spawn_from_weeds') and clamp_01((since_anim - 60) / 60) or 1

      local eaten_progress = find_anim(o, 'eaten') and clamp_01((since_anim - 60) / 60) or
        (o.eaten and 1 or 0)
      alpha = alpha * (1 - eaten_progress)

      love.graphics.setColor(1, 1, 0.3, alpha)
      love.graphics.circle('fill', x0, y0, cell_w * 0.2)

      local dir_angle = (o.dir - 1)
      local anim_progress = clamp_01(since_anim / 60)
      if anim_progress < 1 then
        local a = find_anim(o, 'turn')
        if a ~= nil then
          local from_angle = (a.from_dir - 1)
          local diff = (dir_angle - from_angle + 4) % 4
          if diff == 3 then diff = -1 end
          dir_angle = from_angle + diff * ease_exp_out(anim_progress)
        end
      end
      love.graphics.setLineWidth(4.0)
      love.graphics.line(x0, y0,
        x0 + cell_w * 0.4 * math.cos(dir_angle * (math.pi / 2)),
        y0 + cell_w * 0.4 * math.sin(dir_angle * (math.pi / 2)))
    end)
]]

    board.each('butterfly', function (o)
      local x0, y0 = unpack(butterfly_animated_pos[o])
      love.graphics.setColor(1, 1, 1)

      local idle_aseq
      local idle_flip = false
      if o.dir == 2 then
        idle_aseq = 'butterfly_idle_front'
      elseif o.dir == 4 then
        idle_aseq = 'butterfly_idle_back'
      else
        idle_aseq = 'butterfly_idle_side'
        idle_flip = (o.dir == 3)
      end

      draw.img(
        aseq_get(idle_aseq, 24),
        x0, y0, cell_w * (idle_flip and -2 or 2), cell_w * 2)
    end)

    -- Particle systems (above butterflies)
    for i = 1, #psys do
      local p = psys[i]
      local o = obj_by_psys[p]
      if o.name == 'pollen' and o.visited then
        p.draw()
      end
    end

    -- Pointer
    if pt_bloom then
      love.graphics.setColor(1, 1, 0.3, 0.2)
      love.graphics.rectangle('fill',
        board_offs_x + cell_w * pt_c,
        board_offs_y + cell_w * pt_r,
        cell_w, cell_w)
    end

    -- Text
    love.graphics.setColor(1, 1, 1)
    draw.shadow(0.95, 0.95, 0.95, 1, text_puzzle_name, W * 0.1, H * 0.9)

    -- Buttons
    for i = 1, #buttons do
      local alpha = buttons[i].enabled and 1 or 0.3
      if buttons[i] == btn_next then
        if since_clear == -1 then
          alpha = 0
        else
          alpha = ease_quad_in_out(math.max(0, math.min(1, (since_clear - 240) / 60)))
        end
      end
      love.graphics.setColor(1, 1, 1, alpha)
      buttons[i].draw()
    end
  end

  s.destroy = function ()
  end

  return s
end
