local Board = {
  moves = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}},
}

function Board.create()
  local b = {}

  b.nrows = 4
  b.ncols = 8

  b.objs = {
    bloom = {},
    pollen = {},
    butterfly = {},
  }
  local add = function (name, obj)
    local t = b.objs[name]
    t[#t + 1] = obj
  end
  add('bloom', {r = 0, c = 4, used = false})
  add('bloom', {r = 0, c = 5, used = false})
  add('bloom', {r = 1, c = 3, used = false})
  add('bloom', {r = 2, c = 5, used = false})
  add('pollen', {r = 1, c = 4, group = 1, visited = false})
  add('pollen', {r = 2, c = 3, group = 1, visited = false})
  add('butterfly', {r = 1, c = 7, dir = 2, carrying = 0})

  b.each = function (name, fn)
    local t = b.objs[name]
    for i = 1, #t do fn(t[i]) end
  end

  local moves = Board.moves

  local move_insects = function (r, c)
    b.each('butterfly', function (o)
      local ro, co = o.r, o.c
      local best_dist, best_dir_diff, best_dir =
        b.nrows + b.ncols, 4, nil
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
      if best_dir_diff ~= 2 then
        o.r = o.r + moves[best_dir][1]
        o.c = o.c + moves[best_dir][2]
      end
      o.dir = best_dir
    end)
  end

  b.trigger = function (r, c)
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
