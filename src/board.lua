local Board = {
  moves = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}},
}

function Board.create(puzzle)
  local b = {}

  b.cleared = false

  b.objs = {
    obstacle = {},
    reflect_obstacle = {},
    bloom = {},
    weeds = {},
    pollen = {},
    chameleon = {},
    butterfly = {},
  }

  local add = function (args, defer)
    local name, r, c = unpack(args)
    local o = {r = r, c = c, name = name}
    for k, v in pairs(args) do
      if type(k) == 'string' then o[k] = v end
    end
    if o.range_y ~= nil and o.range_y < 0 then
      o.r = o.r + o.range_y
      o.range_y = -o.range_y
      o.range_y_flipped = true
    end
    if o.range_x ~= nil and o.range_x < 0 then
      o.c = o.c + o.range_x
      o.range_x = -o.range_x
      o.range_x_flipped = true
    end
    if name == 'bloom' then
      o.used = false
    elseif name == 'weeds' then
      o.triggered = false
    elseif name == 'pollen' then
      o.visited = false
      o.matched = false
      o.carrier = nil
    elseif name == 'chameleon' then
      o.provoked = false
    elseif name == 'butterfly' then
      o.carrying = nil
    end
    if not defer then
      local t = b.objs[name]
      t[#t + 1] = o
    end
    return o
  end

  b.nrows, b.ncols = unpack(puzzle.size)
  for i = 1, #puzzle.objs do
    add(puzzle.objs[i])
  end

  local each = function (name, fn)
    local t = b.objs[name]
    -- Handles all newly spawned objects
    local i = 1
    while i <= #t do
      fn(t[i])
      i = i + 1
    end
  end
  b.each = each

  local find_one = function (r, c, name)
    local t = b.objs[name]
    for i = 1, #t do
      local o = t[i]
      if o.r == r and o.c == c then return o end
    end
    return nil
  end
  b.find_one = find_one

  local find_one_ranged = function (r, c, name)
    local t = b.objs[name]
    for i = 1, #t do
      local o = t[i]
      local or1 = o.r + (o.range_y or 0)
      local oc1 = o.c + (o.range_x or 0)
      if r >= o.r and r <= or1 and c >= o.c and c <= oc1 then
        return o
      end
    end
    return nil
  end
  b.find_one = find_one

  local find = function (r, c, name)
    local objs = {}
    local t = b.objs[name]
    for i = 1, #t do
      local o = t[i]
      if o.r == r and o.c == c then objs[#objs + 1] = o end
    end
    return objs
  end
  b.find = find

  local moves = Board.moves

  -- List of (list of {table, index, value})
  local undo = {}

  local undoable_set = function (changes, table, key, value)
    local prev_value = table[key]
    if prev_value == value then return end
    table[key] = value
    changes[#changes + 1] = {table, key, prev_value}
  end
  local undoable_add = function (changes, o)
    local table = b.objs[o.name]
    undoable_set(changes, table, #table + 1, o)
  end
  local undoable_remove = function (changes, o)
    local table = b.objs[o.name]
    for i = 1, #table do
      if table[i] == o then
        for j = i, #table do
          undoable_set(changes, table, j, table[j + 1])
        end
        break
      end
    end
  end

  local add_anim = function (anims, target, name, args, replace_fn)
    if anims[target] == nil then anims[target] = {} end
    local a = args or {}
    local existing = anims[target][name]
    if existing == nil then
      anims[target][name] = a
    elseif replace_fn and replace_fn(a, existing) then
      anims[target][name] = a
    end
  end

  -- Returns undo list and animations
  local move_insects = function (r, c)
    local changes = {}
    local anims = {}
    local spawned = {}

    local updated_chameleons = {}
    local visited_pollen = {}

    each('butterfly', function (o)
      if o.eaten then return end

      local ro, co = o.r, o.c
      local best_dist, best_dir_diff, best_dir =
        (b.nrows + b.ncols) * 2, 4, nil
      if r == nil or o.newly_spawned then
        best_dir = o.dir
        o.newly_spawned = nil
      else
        local manh_dist0 = math.abs(ro - r) + math.abs(co - c)
        for step_dir = 1, 4 do
          local r1 = ro + moves[step_dir][1]
          local c1 = co + moves[step_dir][2]
          local dist = math.max(math.abs(r1 - r), math.abs(c1 - c))
          local manh_dist = math.abs(r1 - r) + math.abs(c1 - c)
          if manh_dist > manh_dist0 then dist = (b.nrows + b.ncols) * 2 end
          local dir_delta = (step_dir - o.dir + 4) % 4
          local dir_diff = (dir_delta == 3 and 1 or dir_delta)
          if dir_diff == 2 then dist = dist + (b.nrows + b.ncols) end
          if dist < best_dist or (dist == best_dist and (
              dir_diff < best_dir_diff or (
              dir_diff == best_dir_diff and dir_delta == 3))) then
            best_dist, best_dir_diff, best_dir = dist, dir_diff, step_dir
          end
        end
      end
      if best_dir_diff ~= 2 then
        local r1 = o.r + moves[best_dir][1]
        local c1 = o.c + moves[best_dir][2]
        if r1 >= 0 and r1 < b.nrows and c1 >= 0 and c1 < b.ncols then
          -- Reflect?
          local rebound = find_one(r1, c1, 'reflect_obstacle')
          if rebound ~= nil then
            best_dir = (best_dir + 1) % 4 + 1
            local r2 = o.r + moves[best_dir][1]
            local c2 = o.c + moves[best_dir][2]
            if r2 >= 0 and r2 < b.nrows and c2 >= 0 and c2 < b.ncols
                and not find_one(r2, c2, 'obstacle')
                and not find_one(r2, c2, 'reflect_obstacle') then
              r1, c1 = r2, c2
              add_anim(anims, rebound, 'hit')
            end
          end
          -- Weeds?
          local weeds = find_one(r1, c1, 'weeds')
          if weeds ~= nil and not weeds.triggered then
            undoable_set(changes, weeds, 'triggered', true)
            -- Spawn butterflies!
            local d1, d2 = best_dir % 4 + 1, (best_dir + 2) % 4 + 1
            local b1 = add({'butterfly', r1, c1, dir = d1, newly_spawned = true}, true)
            local b2 = add({'butterfly', r1, c1, dir = d2, newly_spawned = true}, true)
            undoable_add(changes, b1)
            undoable_add(changes, b2)
            add_anim(anims, b1, 'spawn_from_weeds')
            add_anim(anims, b2, 'spawn_from_weeds')
            add_anim(anims, weeds, 'weeds_trigger')
            r1 = r1 + moves[best_dir][1]
            c1 = c1 + moves[best_dir][2]
          end
          -- Move if not blocked
          local obst = find_one(r1, c1, 'obstacle')
          if obst ~= nil then
            add_anim(anims, obst, 'hit')
          else
            -- Animation
            add_anim(anims, o, 'move', {from_r = o.r, from_c = o.c})
            -- Apply changes
            undoable_set(changes, o, 'r', r1)
            undoable_set(changes, o, 'c', c1)
            -- Meet any flowers?
            local target = find_one(r1, c1, 'pollen')
            -- `visited_pollen` is kept so that
            -- multiple simultaneous visiting butterflies collect the pollen
            if target ~= nil and (not target.visited or visited_pollen[target]) then
              if o.carrying ~= nil then
                if o.carrying.group == target.group then
                  visited_pollen[target] = true
                  undoable_set(changes, target, 'visited', true)
                  undoable_set(changes, target, 'carrier', o)
                  undoable_set(changes, target, 'matched', true)
                  undoable_set(changes, o.carrying, 'matched', true)
                  add_anim(anims, target, 'pollen_visit')
                  add_anim(anims, target, 'pollen_match')
                  add_anim(anims, o.carrying, 'pollen_match')
                  undoable_set(changes, o, 'carrying', nil)
                  add_anim(anims, o, 'carry_pollen', {release_group = target.group})
                  -- Check whether cleared
                  if not b.cleared then
                    local cleared = true
                    local t = b.objs['pollen']
                    for i = 1, #t do
                      if not t[i].matched then
                        cleared = false
                        break
                      end
                    end
                    if cleared then
                      undoable_set(changes, b, 'cleared', true)
                    end
                  end
                end
              else
                visited_pollen[target] = true
                undoable_set(changes, target, 'visited', true)
                undoable_set(changes, target, 'carrier', o)
                undoable_set(changes, o, 'carrying', target)
                add_anim(anims, target, 'pollen_visit')
                add_anim(anims, o, 'carry_pollen')  -- release_group = nil: taking on
              end
            end
          end
        end
      end

      -- Chameleons?
      -- These are checked even if no movement is taking place
      local cha = find_one_ranged(o.r, o.c, 'chameleon')
      if cha ~= nil then
        local anim_eat = function ()
          local orig_r, orig_c = cha.r, cha.c
          if cha.range_x_flipped then orig_c = orig_c + cha.range_x end
          if cha.range_y_flipped then orig_r = orig_r + cha.range_y end
          local eat_distance = math.abs(o.r - orig_r) + math.abs(o.c - orig_c) + 1
          add_anim(anims, cha, 'eat', {eat_distance = eat_distance}, function (a, b)
            return a.eat_distance > b.eat_distance
          end)
        end
        if not updated_chameleons[cha] then
          updated_chameleons[cha] = true
          -- Change state
          if cha.provoked then
            -- Eat
            undoable_set(changes, cha, 'provoked', false)
            anim_eat()
          else
            -- Provoke
            undoable_set(changes, cha, 'provoked', true)
            add_anim(anims, cha, 'provoke')
          end
        elseif not cha.provoked then
          -- Eat also
          anim_eat()
        end
        if not cha.provoked then
          -- Changed back to 'not provoked', so eat
          undoable_set(changes, o, 'eaten', true)
          add_anim(anims, o, 'eaten')
        end
      end

      if o.dir ~= best_dir then
        add_anim(anims, o, 'turn', {from_dir = o.dir})
      end
      undoable_set(changes, o, 'dir', best_dir)
    end)

    -- Chameleons
    each('chameleon', function (o)
      if not updated_chameleons[o] then
        if o.provoked then
          undoable_set(changes, o, 'provoked', false)
          add_anim(anims, o, 'return_idle')
        end
      end
    end)

    return changes, anims
  end

  local trigger
  trigger = function (r, c)
    if r == nil then
      local changes, anims = move_insects(nil, nil)
      if #changes == 0 then
        -- Nothing happens, but return the animations anyway
        return anims
      end
      undo[#undo + 1] = changes
      return anims
    end
    local o = find_one(r, c, 'bloom')
    if o and not o.used then
      local changes, anims = move_insects(r, c)
      undoable_set(changes, o, 'used', true)
      undo[#undo + 1] = changes
      add_anim(anims, o, 'use')
      return anims
    else
      return trigger(nil, nil)
    end
  end
  b.trigger = trigger

  b.trigger_bloom = function (index)
    local o = b.objs['bloom'][index]
    if o ~= nil and not o.used then
      return trigger(o.r, o.c)
    end
  end

  b.undo = function ()
    if #undo == 0 then return end
    local changes = undo[#undo]
    undo[#undo] = nil
    for i = #changes, 1, -1 do
      local table, key, value = unpack(changes[i])
      table[key] = value
    end
  end
  b.can_undo = function () return #undo > 0 end

  return b
end

return Board
