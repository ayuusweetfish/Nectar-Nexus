local Board = {
  moves = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}},
}

function Board.create()
  local b = {}

  b.nrows = 3
  b.ncols = 5

  b.objs = {
    bloom = {},
    pollen = {},
    butterfly = {},
  }
  local add = function (name, obj)
    local t = b.objs[name]
    t[#t + 1] = obj
  end
  add('bloom', {r = 0, c = 1, used = false})
  add('bloom', {r = 1, c = 0, used = false})
  add('bloom', {r = 2, c = 3, used = false})
  add('pollen', {r = 1, c = 2, group = 1, visited = false})
  add('pollen', {r = 1, c = 1, group = 1, visited = false})
  add('pollen', {r = 2, c = 1, group = 2, visited = false})
  add('pollen', {r = 2, c = 2, group = 2, visited = false})
  add('butterfly', {r = 1, c = 4, dir = 2, carrying = nil})

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

  local move_insects = function (r, c)
    each('butterfly', function (o)
      local ro, co = o.r, o.c
      local best_dist, best_dir_diff, best_dir =
        b.nrows + b.ncols, 4, nil
      if r == nil then
        best_dir = o.dir
      else
        for step_dir = 1, 4 do
          local r1 = ro + moves[step_dir][1]
          local c1 = co + moves[step_dir][2]
          local dist = math.abs(r1 - r) + math.abs(c1 - c)
          local dir_delta = (step_dir - o.dir + 4) % 4
          local dir_diff = (dir_delta == 3 and 1 or dir_delta)
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
          o.r = r1
          o.c = c1
          -- Meet any flowers?
          local target = find_one(o.r, o.c, 'pollen')
          if target ~= nil then
            if o.carrying ~= nil then
              if o.carrying.group == target.group then
                target.visited = true
                o.carrying = nil
              end
            else
              target.visited = true
              o.carrying = target
            end
          end
        end
      end
      o.dir = best_dir
    end)
  end

  b.trigger = function (r, c)
    if r == nil then
      move_insects(nil, nil)
    end
    local t = b.objs['bloom']
    for i = 1, #t do
      local o = t[i]
      if o.r == r and o.c == c then
        if not o.used then
          o.used = true
          move_insects(r, c)
        end
        break
      end
    end
  end

  return b
end

return Board
