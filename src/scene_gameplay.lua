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
local ease_exp_in = function (x)
  return x * math.exp(-3 * (1 - x))
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

  puzzle_index = puzzle_index or puzzles.test or #puzzles
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

  local global_scale = 1 / 1.5
  local cell_w_orig = 100 * global_scale
  local cell_w = math.min(cell_w_orig, H * 0.92 / board.nrows, W * 0.9 / board.ncols)
  local board_offs_x = (W - cell_w * board.ncols) / 2
  local board_offs_y = (H - cell_w * board.nrows) / 2
  local cell_scale = cell_w / cell_w_orig

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
--[[
  board.each('bloom', function (o)
    local p = particles({ y_max = 40, x_spread = 40, scale = cell_scale })
    p.x = board_offs_x + cell_w * (o.c + 0.5)
    p.y = board_offs_y + cell_w * (o.r + 0.5)
    p.tint = {1, 0.6, 0.5}
    psys[#psys + 1] = p
    psys_by_obj[o] = p
    obj_by_psys[p] = o
  end)
]]

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

  ------ Visuals!! ------

  local palette_num = 1
  if puzzle_index >= 1 and puzzle_index <= 6 then
    palette_num = 1
  elseif puzzle_index >= 7 and puzzle_index <= 10 then
    palette_num = 2
  elseif puzzle_index >= 11 and puzzle_index <= 16 then
    palette_num = 3
  elseif puzzle_index >= 17 and puzzle_index <= 20 then
    palette_num = 1
  elseif puzzle_index >= 21 and puzzle_index <= 24 then
    palette_num = 2
  elseif puzzle_index >= 25 and puzzle_index <= 30 then
    palette_num = 3
  end

  local bg_tint = {
    {0.02, 0.41, 0.38},
    {0.73, 0.61, 0.66},
    {0.10, 0.00, 0.00},
  }
  bg_tint = bg_tint[palette_num]

  -- Glaze tiles
  local glaze_tile_name = string.format('still/p%d-tiles', palette_num)
  local glaze_tile_tex = draw.get(glaze_tile_name)
  local glaze_tile_quads = {}
  for r = 0, 7 do
    for c = 0, 15 do
      local index = r * 16 + c
      glaze_tile_quads[index] =
        love.graphics.newQuad(c * 100, r * 100, 100, 100, 1600, 800)
    end
  end
  local glaze_tile_opacity_in_game = {0.7, 0.8, 0.6}
  glaze_tile_opacity_in_game = glaze_tile_opacity_in_game[palette_num]

  local still = {}
  local still_offs = {}
  local register_still_sprite_set = function (set_name, offs)
    local t = {}
    still[set_name] = t
    for k, v in pairs(offs) do
      t[k] = string.format('still/p%d-%s-%s', palette_num, set_name, k)
    end
    still_offs[set_name] = offs
  end

  -- Obstacles
  local obst_offs = {}
  if palette_num == 1 then
    obst_offs['1.1'] = {0, 0}
    obst_offs['1.2'] = {0, 0}
    obst_offs['2'] = {0.5, -0.1}
    obst_offs['3'] = {0, 0}
  elseif palette_num == 2 then
    obst_offs['1'] = {0, 0}
    obst_offs['2'] = {0.08, -0.05}
    obst_offs['3.1'] = {0, 0}
    obst_offs['3.2'] = {0, 0}
    obst_offs['3.3'] = {0, 0}
  elseif palette_num == 3 then
    obst_offs['1'] = {0.05, -0.05}
    obst_offs['2.1'] = {-0.05, -0.2}
    obst_offs['2.2'] = {0, -0.2}
  end
  register_still_sprite_set('obst', obst_offs)

  -- Rebound obstacles
  local rebound_offs = {}
  rebound_offs['1.1'] = {0.03, 0}
  rebound_offs['1.2'] = {0.1, 0.03}
  rebound_offs['1.3'] = {0, -0.03}
  register_still_sprite_set('rebound', rebound_offs)

  -- Pollen
  local pollen_offs = {}
  if palette_num == 1 then
    pollen_offs['1.1'] = {0, 0}
    pollen_offs['1.2'] = {0, 0}
    pollen_offs['2.1'] = {0.15, 0}
    pollen_offs['2.2'] = {0, 0}
    pollen_offs['3.1'] = {0.2, -0.15}
    pollen_offs['3.2'] = {0.15, 0.2}
    pollen_offs['4.1'] = {-0.15, -0.15}
    pollen_offs['4.2'] = {0, 0}
  elseif palette_num == 2 then
    pollen_offs['1.1'] = {0, 0}
    pollen_offs['1.2'] = {0, 0}
    pollen_offs['2.1'] = {0.3, 0}
    pollen_offs['2.2'] = {0.12, 0.12}
    pollen_offs['3.1'] = {0.45, 0.4}
    pollen_offs['3.2'] = {0, 0.05}
    pollen_offs['4.1'] = {0.02, 0}
    pollen_offs['4.2'] = {0, -0.2}
    pollen_offs['5.1'] = {0, -0.5}
    pollen_offs['5.2'] = {0, -0.6}
  elseif palette_num == 3 then
    pollen_offs['1.1'] = {0, -0.1}
    pollen_offs['1.2'] = {-0.12, 0}
    pollen_offs['2.1'] = {0.2, -0.05}
    pollen_offs['2.2'] = {0, 0.15}
    pollen_offs['3.1'] = {-0.24, 0}
    pollen_offs['3.2'] = {-0.55, 0.6}
    pollen_offs['4.1'] = {0.43, -0.2}
    pollen_offs['4.2'] = {0, -0.3}
  end
  register_still_sprite_set('pollen', pollen_offs)

  local aseq = {}
  -- Butterfly
  for _, n in ipairs({
    'idle-side', 'idle-front', 'idle-back'
  }) do
    full_name = 'butterfly-' .. n
    aseq[full_name] = {}
    for i = 1, 16 do
      aseq[full_name][i] = string.format('butterflies/%s/%02d', n, i)
    end
  end
  for _, n in ipairs({
    'turn-front-side', 'turn-back-side', 'turn-side-front', 'turn-side-back',
  }) do
    full_name = 'butterfly-' .. n
    aseq[full_name] = {}
    for i = 1, 6 do
      aseq[full_name][i] = string.format('butterflies/%s/%02d', n, i)
    end
  end
  -- Weeds
  aseq['weeds-idle'] = {}
  for i = 1, 6 do
    aseq['weeds-idle'][i] = string.format('weeds/p%d-idle/%02d', palette_num, i)
  end
  aseq['weeds-trigger'] = {}
  for i = 1, 10 do
    aseq['weeds-trigger'][i] = string.format('weeds/p%d-trigger/%02d', palette_num, i)
  end
  -- Blossoms
  aseq['bloom-idle'] = {}
  for i = 1, 6 do
    aseq['bloom-idle'][i] = string.format('bloom/idle/%02d', i)
  end
  aseq['bloom-visited'] = {}
  for i = 1, 8 do
    aseq['bloom-visited'][i] = string.format('bloom/visited/%02d', i)
  end
  -- Chameleon
  aseq['chameleon-eye'] = {}
  for i = 1, 25 do
    aseq['chameleon-eye'][i] = string.format('chameleon/p%d-eye/%02d', palette_num, i)
  end
  aseq['chameleon-body'] = {}
  for i = 1, 3 do
    aseq['chameleon-body'][i] = string.format('chameleon/p%d-body/%02d', palette_num, i)
  end
  for d = 1, 6 do
    local t = {}
    aseq[string.format('chameleon-tongue-%d', d)] = t
    for i = 1, 8 do
      local name = string.format('chameleon/p%d-tongue/%d-%d', palette_num, d, i)
      if not draw.get(name) then break end
      t[i] = name
    end
  end

  local aseq_loop = function (seq_name, frame_rate)
    local n = math.floor(T / 240 * frame_rate)
    local list = aseq[seq_name]
    return list[n % #list + 1]
  end
  local aseq_proceed = function (seq_name, rate)
    local list = aseq[seq_name]
    return list[math.floor(rate * (#list - 1)) + 1]
  end

  local pop_scale_effect = function (anim_progress)
    local ease = math.sqrt(anim_progress) * (1 - ease_exp_out(anim_progress)) * 4
    local rel_scale_x = 1 + ease * math.sin(anim_progress * 12) * 0.15
    local rel_scale_y = 1 + ease * math.sin(anim_progress * 12 + 1.4) * 0.11
    return rel_scale_x, rel_scale_y
  end

  s.draw = function ()
    love.graphics.clear(unpack(bg_tint))

    -- Grid lines
    love.graphics.setColor(0.95, 0.95, 0.95, 0.06)
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

    -- Tiles
    love.graphics.setColor(1, 1, 1, glaze_tile_opacity_in_game)
    for r = 0, board.nrows - 1 do
      for c = 0, board.ncols - 1 do
        local o = board.find_one(r, c, 'obstacle')
        if not o or not o.empty_background then
          local r1 = r + puzzles[puzzle_index].tile[1] - 1
          local c1 = c + puzzles[puzzle_index].tile[2] - 1
          if r1 >= 0 and r1 < 8 and c1 >= 0 and c1 < 16 then
            local index = r1 * 16 + c1
            love.graphics.draw(
              glaze_tile_tex, glaze_tile_quads[index],
              board_offs_x + cell_w * c,
              board_offs_y + cell_w * r,
              0, cell_scale * global_scale
            )
          end
        end
      end
    end

    -- Objects
    local object_images = {}
    local obj_img = function (name, r, c, dx, dy, scale, rel_scale_x, rel_scale_y, rotation, layer)
      object_images[#object_images + 1] = {
        r = r, c = c,
        name = name,
        dx = dx or 0,
        dy = dy or 0,
        scale = scale,
        rel_scale_x = rel_scale_x,
        rel_scale_y = rel_scale_y,
        rotation = rotation or 0,
        layer = layer or 0,
      }
    end
    local obj_img_draw = function ()
      table.sort(object_images, function (a, b)
        return a.layer < b.layer or (a.layer == b.layer and
          (a.r < b.r or (a.r == b.r and a.c < b.c)))
      end)
      for i = 1, #object_images do
        local item = object_images[i]
        local w, h = nil, nil
        if item.scale ~= nil then
          w, h = item.scale * cell_w, item.scale * cell_w
        elseif item.rel_scale_x ~= nil then
          local img = draw.get(item.name)
          w = item.rel_scale_x * img:getWidth() * global_scale
          h = item.rel_scale_y * img:getHeight() * global_scale
        end
        local r = item.rotation
        local dx = item.dx - 0.5
        local dy = item.dy - 0.5
        if r ~= 0 then
          dx, dy =
            dx * math.cos(r) - dy * math.sin(r),
            dx * math.sin(r) + dy * math.cos(r)
        end
        draw.img(item.name,
          board_offs_x + cell_w * (item.c + 0.5 + dx),
          board_offs_y + cell_w * (item.r + 0.5 + dy),
          w, h,
          0.5, 0.5, r
        )
      end
    end

    love.graphics.setColor(1, 1, 1)
    board.each('obstacle', function (o)
      if not o.empty_background then
        local id = o.image
        local rel_scale_x, rel_scale_y = 1, 1
        local anim_progress = clamp_01(since_anim / 120)
        if anim_progress < 1 and find_anim(o, 'hit') then
          rel_scale_x, rel_scale_y = pop_scale_effect(anim_progress)
        end
        local rotation = (o.rotation or 0) * math.pi / 2
        obj_img(still.obst[id], o.r, o.c,
          0.5 + still_offs.obst[id][1],
          0.5 + still_offs.obst[id][2],
          nil, rel_scale_x, rel_scale_y, rotation)
      end
    end)

    board.each('reflect_obstacle', function (o)
      local id = o.image
      local rel_scale_x, rel_scale_y = 1, 1
      local anim_progress = clamp_01(since_anim / 120)
      if anim_progress < 1 and find_anim(o, 'hit') then
        rel_scale_x, rel_scale_y = pop_scale_effect(anim_progress)
      end
      local rotation = (o.rotation or 0) * math.pi / 2
      obj_img(still.rebound[id], o.r, o.c,
        0.5 + still_offs.rebound[id][1],
        0.5 + still_offs.rebound[id][2],
        nil, rel_scale_x, rel_scale_y, rotation)
    end)

    -- Key: chameleon object; value: animation progress {eat, provoke}
    -- When `eat` is active, `provoke` does not matter (progress set to -1)
    -- (provoke, eat) = (0, 0) and (1, 1) are the same thing
    -- Saved for later use
    local chameleon_anim_progress = {}

    board.each('chameleon', function (o)
      local anim_progress = clamp_01((since_anim - 50) / 60)
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
      chameleon_anim_progress[o] = {eat_progress, provoke_progress}

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
        used_rate = anim_progress
      end
      local aseq_frame
      if used_rate == 0 then
        aseq_frame = aseq_loop('bloom-idle', 24)
      else
        aseq_frame = aseq_proceed('bloom-visited', used_rate)
      end
      obj_img(aseq_frame, o.r, o.c, 0.59, 0.5, 1.2, nil, nil, 0, 1)

--[[
      local used_rate = (o.used and 1 or 0)
      local anim_progress = clamp_01(since_anim / 90)
      if anim_progress < 1 and find_anim(o, 'use') then
        used_rate = ease_exp_out(anim_progress)
      end
      psys_by_obj[o].ordinary_fade = used_rate
]]
    end)

    -- Animated positions
    local butterfly_animated_pos = {}
    -- Eaten progresses
    local butterfly_eaten_progress = {}
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

      local eaten_progress = 0
      if find_anim(o, 'eaten') then
        eaten_progress = ease_quad_in_out(clamp_01((since_anim - 90) / 30))
      elseif o.eaten then
        eaten_progress = 1
      end
      butterfly_eaten_progress[o] = eaten_progress
    end)

    board.each('pollen', function (o)
      local tint = group_colours[o.group]

      local shadow_radius = (o.matched and 0 or 1)
      local anim_progress = clamp_01((since_anim - 120) / 60)
      if anim_progress < 1 and find_anim(o, 'pollen_match') then
        shadow_radius = 1 - ease_quad_in_out(anim_progress)
      end

      local highlight_radius = (o.visited and 0 or 1)
      local anim_progress = clamp_01((since_anim - 50) / 60)
      if anim_progress < 1 and find_anim(o, 'pollen_visit') ~= nil then
        highlight_radius = 1 - ease_quad_in_out(anim_progress)
      end

    --[[
      local t = T / 240 * 1.5
      local rel_scale_x = 1 + math.sin(t) * 0.01
      local rel_scale_y = 1 + math.sin(t + 1.5) * 0.01
    ]]
      local rel_scale_x, rel_scale_y = 1, 1

      local id = o.image
      local anim_progress = clamp_01((since_anim - 30) / 120)
      if anim_progress < 1 and find_anim(o, 'pollen_visit') then
        local sx, sy = pop_scale_effect(anim_progress)
      --[[
        rel_scale_x = rel_scale_x * sx
        rel_scale_y = rel_scale_y * sy
      ]]
        rel_scale_x, rel_scale_y = sx, sy
      end
      local rotation = (o.rotation or 0) * math.pi / 2
      obj_img(still.pollen[id], o.r, o.c,
        0.5 + still_offs.pollen[id][1],
        0.5 + still_offs.pollen[id][2],
        nil, rel_scale_x, rel_scale_y, rotation)

      -- Particles following a butterfly?
      local follow, follow_rate = nil, 0
      local eaten_progress = 0
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
        eaten_progress = butterfly_eaten_progress[o.carrier]
      end
      psys_by_obj[o].follow = follow
      psys_by_obj[o].follow_rate = follow_rate
      psys_by_obj[o].ordinary_fade = eaten_progress

      -- Particles waving and fading out due to matching?
      local wave_out = (o.matched and 1 or 0)
      local anim_progress = clamp_01((since_anim - 60) / 240)
      if anim_progress < 1 and find_anim(o, 'pollen_match') then
        wave_out = ease_quad_in_out(anim_progress)
      end
      psys_by_obj[o].wave_out = wave_out
    end)

    love.graphics.setColor(1, 1, 1)
    board.each('weeds', function (o)
      local aseq_frame = aseq_loop('weeds-idle', 24)
      local anim_progress = clamp_01(since_anim / 60)
      if anim_progress < 1 then
        local a = find_anim(o, 'weeds_trigger')
        if a ~= nil then
          aseq_frame = aseq_proceed('weeds-trigger', anim_progress)
        end
      end
      obj_img(
        aseq_frame,
        o.r, o.c,
        0.59, 0.55, 2.7)
    end)

    obj_img_draw()

    board.each('chameleon', function (o)
      local eat_progress, provoke_progress = unpack(chameleon_anim_progress[o])
      local aseq_frames = {}  -- {name, alpha}
      if provoke_progress == -1 then
        eat_progress = math.min(1, eat_progress * 1.1)
        local f1 = aseq_proceed('chameleon-body', eat_progress)
        local alpha = math.sqrt(math.min(eat_progress / 0.3))
        aseq_frames[#aseq_frames + 1] = {f1, alpha}
        local f2 = aseq_proceed('chameleon-tongue-4', eat_progress)
        aseq_frames[#aseq_frames + 1] = {f2, alpha}
      end
      if provoke_progress > 0 or provoke_progress == -1 then
        if provoke_progress == -1 then provoke_progress = 1 end
        local f = aseq_proceed('chameleon-eye', provoke_progress)
        local alpha = math.sqrt(math.min(provoke_progress / 0.3))
        aseq_frames[#aseq_frames + 1] = {f, alpha}
      end
      for i = 1, #aseq_frames do
        local f, alpha = unpack(aseq_frames[i])
        love.graphics.setColor(1, 1, 1, alpha)
        draw.img(
          f,
          board_offs_x + cell_w * (o.c + 0.5),
          board_offs_y + cell_w * (o.r + 0.5),
          draw.get(f):getWidth() * cell_scale * global_scale
        )
      end
    end)

    -- Particle systems (under butterflies)
    for i = 1, #psys do
      local p = psys[i]
      local o = obj_by_psys[p]
      if o.name == 'bloom' or (o.name == 'pollen' and not o.visited) then
        p.draw()
      end
    end

    board.each('butterfly', function (o)
      local x0, y0 = unpack(butterfly_animated_pos[o])
      love.graphics.setColor(1, 1, 1)

      local aseq_frame = nil

      -- Idle sequence
      local idle_aseq
      local flip = false
      if o.dir == 2 then
        idle_aseq = 'butterfly-idle-front'
      elseif o.dir == 4 then
        idle_aseq = 'butterfly-idle-back'
      else
        idle_aseq = 'butterfly-idle-side'
        flip = (o.dir == 3)
      end
      aseq_frame = aseq_loop(idle_aseq, 24)

      -- Turn sequence
      local anim_progress = clamp_01(since_anim / 50)
      if anim_progress < 1 then
        local a = find_anim(o, 'turn')
        if a ~= nil then
          local to_angle = (o.dir - 1)
          local from_angle = (a.from_dir - 1)
          local diff = (to_angle - from_angle + 4) % 4
          if diff == 3 then diff = -1 end

          if diff == 2 then
            diff = 1
            if anim_progress < 0.5 then
              anim_progress = anim_progress * 2
              to_angle = (from_angle + 1) % 4
            else
              anim_progress = (anim_progress - 0.5) * 2
              to_angle = (from_angle + 2) % 4
              from_angle = (from_angle + 1) % 4
            end
          else
            anim_progress = math.min(1, anim_progress * 2)
          end

          local turn_aseq = nil
          -- 0 - 1, 2 - 1: side-front (flip false/true)
          -- 1 - 0, 1 - 2: front-side (flip false/true)
          -- 0 - 3, 2 - 3: side-back (flip false/true)
          -- 3 - 0, 3 - 2: back-side (flip false/true)
          if to_angle == 1 then
            turn_aseq = 'butterfly-turn-side-front'
            flip = (from_angle == 2)
          elseif to_angle == 3 then
            turn_aseq = 'butterfly-turn-side-back'
            flip = (from_angle == 2)
          elseif from_angle == 1 then
            turn_aseq = 'butterfly-turn-front-side'
            flip = (to_angle == 2)
          elseif from_angle == 3 then
            turn_aseq = 'butterfly-turn-back-side'
            flip = (to_angle == 2)
          end
          aseq_frame = aseq_proceed(turn_aseq, anim_progress)
        end
      end

      local alpha = find_anim(o, 'spawn_from_weeds') and clamp_01((since_anim - 60) / 60) or 1
      alpha = alpha * (1 - butterfly_eaten_progress[o])

      love.graphics.setColor(1, 1, 1, alpha)
      draw.img(
        aseq_frame,
        x0, y0, cell_w * (flip and -2 or 2), cell_w * 2)
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
