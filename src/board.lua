local Board = {
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
  add('bloom', {r = 2, c = 5, used = true})
  add('pollen', {r = 1, c = 4, group = 1, visited = false})
  add('pollen', {r = 2, c = 3, group = 1, visited = false})
  add('butterfly', {r = 1, c = 7, carrying = 0})

  b.each = function (name, fn)
    local t = b.objs[name]
    for i = 1, #t do fn(t[i]) end
  end

  local move_insects = function (r, c)
    b.each('butterfly', function (o)
      o.r = o.r + 1
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
