local Board = {
  moves = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}},
}

function Board.create()
  local b = {}

  b.objs = {
    obstacle = {},
    reflect_obstacle = {},
    bloom = {},
    pollen = {},
    butterfly = {},
  }
  local add = function (name, obj)
    local t = b.objs[name]
    t[#t + 1] = obj
  end
--[[
  b.nrows = 3
  b.ncols = 7
  add('obstacle', {r = 0, c = 5})
  add('obstacle', {r = 0, c = 6})
  add('obstacle', {r = 1, c = 1})
  add('bloom', {r = 0, c = 3, used = false})
  add('bloom', {r = 0, c = 0, used = false})
  add('bloom', {r = 2, c = 5, used = false})
  add('pollen', {r = 1, c = 4, group = 1, visited = false, matched = false})
  add('pollen', {r = 1, c = 3, group = 1, visited = false, matched = false})
  add('pollen', {r = 2, c = 3, group = 2, visited = false, matched = false})
  add('pollen', {r = 2, c = 4, group = 2, visited = false, matched = false})
  add('butterfly', {r = 1, c = 6, dir = 2, carrying = nil})
]]
  b.nrows = 5
  b.ncols = 5
  add('reflect_obstacle', {r = 4, c = 0})
  add('bloom', {r = 2, c = 1, used = false})
  add('bloom', {r = 1, c = 3, used = false})
  add('pollen', {r = 0, c = 2, group = 1, visited = false, matched = false})
  add('pollen', {r = 1, c = 2, group = 1, visited = false, matched = false})
  add('pollen', {r = 2, c = 3, group = 2, visited = false, matched = false})
  add('pollen', {r = 2, c = 4, group = 2, visited = false, matched = false})
  add('butterfly', {r = 3, c = 4, dir = 3, carrying = nil})
  add('butterfly', {r = 4, c = 4, dir = 3, carrying = nil})

  local each = function (name, fn)
    local t = b.objs[name]
    for i = 1, #t do fn(t[i]) end
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

  local add_anim = function (anims, target, name, args)
    if anims[target] == nil then anims[target] = {} end
    anims[target][name] = args or {}
  end

  -- Returns undo list and animations
  local move_insects = function (r, c)
    local changes = {}
    local anims = {}

    each('butterfly', function (o)
      local ro, co = o.r, o.c
      local best_dist, best_dir_diff, best_dir =
        (b.nrows + b.ncols) * 2, 4, nil
      if r == nil then
        best_dir = o.dir
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
          if find_one(r1, c1, 'reflect_obstacle') then
            best_dir = (best_dir + 1) % 4 + 1
            local r2 = o.r + moves[best_dir][1]
            local c2 = o.c + moves[best_dir][2]
            if r2 >= 0 and r2 < b.nrows and c2 >= 0 and c2 < b.ncols
                and not find_one(r2, c2, 'obstacle')
                and not find_one(r2, c2, 'reflect_obstacle') then
              r1, c1 = r2, c2
            end
          end
          if not find_one(r1, c1, 'obstacle') then
            -- Animation
            add_anim(anims, o, 'move', {from_r = o.r, from_c = o.c})
            -- Apply changes
            undoable_set(changes, o, 'r', r1)
            undoable_set(changes, o, 'c', c1)
            -- Meet any flowers?
            local target = find_one(r1, c1, 'pollen')
            if target ~= nil and not target.visited then
              if o.carrying ~= nil then
                if o.carrying.group == target.group then
                  undoable_set(changes, target, 'visited', true)
                  undoable_set(changes, target, 'matched', true)
                  undoable_set(changes, o.carrying, 'matched', true)
                  add_anim(anims, target, 'pollen_visit')
                  add_anim(anims, target, 'pollen_match')
                  add_anim(anims, o.carrying, 'pollen_match')
                  undoable_set(changes, o, 'carrying', nil)
                  add_anim(anims, o, 'carry_pollen', {release_group = target.group})
                end
              else
                undoable_set(changes, target, 'visited', true)
                undoable_set(changes, o, 'carrying', target)
                add_anim(anims, target, 'pollen_visit')
                add_anim(anims, o, 'carry_pollen')  -- release_group = nil: taking on
              end
            end
          end
        end
      end
      if o.dir ~= best_dir then
        add_anim(anims, o, 'turn', {from_dir = o.dir})
      end
      undoable_set(changes, o, 'dir', best_dir)
    end)

    return changes, anims
  end

  b.trigger = function (r, c)
    if r == nil then
      local changes, anims = move_insects(nil, nil)
      if #changes == 0 then
        -- Nothing happens
        return nil
      end
      undo[#undo + 1] = changes
      return anims
    end
    local t = b.objs['bloom']
    for i = 1, #t do
      local o = t[i]
      if o.r == r and o.c == c then
        if not o.used then
          local changes, anims = move_insects(r, c)
          undoable_set(changes, o, 'used', true)
          undo[#undo + 1] = changes
          add_anim(anims, o, 'use')
          return anims
        end
        break
      end
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
