local draw = require 'draw_utils'
local Board = require 'board'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_Imprima']

  local board = Board.create()

  local cell_w = 100
  local board_offs_x = (W - cell_w * board.ncols) / 2
  local board_offs_y = (H - cell_w * board.nrows) / 2

  local pt_to_cell = function (x, y)
    local c = math.floor((x - board_offs_x) / cell_w)
    local r = math.floor((y - board_offs_y) / cell_w)
    if r < 0 or r >= board.nrows or c < 0 or c >= board.ncols then
      return nil
    end
    return r, c
  end

  local pt_r, pt_c

  s.press = function (x, y)
    pt_r, pt_c = pt_to_cell(x, y)
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
  end

  s.release = function (x, y)
    local r1, c1 = pt_to_cell(x, y)
    if r1 == pt_r and c1 == pt_c then
      board.trigger(r1, c1)
    end
    pt_r, pt_c = nil, nil
  end

  s.update = function ()
  end

  s.draw = function ()
    love.graphics.clear(0, 0.01, 0.03)

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
    board.each('bloom', function (o)
      love.graphics.setColor(1, 0.4, 0.5, o.used and 0.2 or 1)
      love.graphics.circle('fill',
        board_offs_x + cell_w * (o.c + 0.5),
        board_offs_y + cell_w * (o.r + 0.5),
        cell_w * (o.used and 0.4 or 0.25))
    end)
    local group_colours = {
      {0.8, 0.5, 1},
      {0.5, 0.9, 0.5},
    }
    board.each('pollen', function (o)
      local tint = group_colours[o.group]
      love.graphics.setColor(tint[1], tint[2], tint[3], o.visited and 0.2 or 1)
      love.graphics.circle('fill',
        board_offs_x + cell_w * (o.c + 0.5),
        board_offs_y + cell_w * (o.r + 0.5),
        cell_w * 0.4)
    end)
    board.each('butterfly', function (o)
      local x0 = board_offs_x + cell_w * (o.c + 0.5)
      local y0 = board_offs_y + cell_w * (o.r + 0.5)
      if o.carrying ~= nil then
        local tint = group_colours[o.carrying.group]
        love.graphics.setColor(tint[1], tint[2], tint[3])
        love.graphics.circle('fill', x0, y0, cell_w * 0.25)
      end
      love.graphics.setColor(1, 1, 0.3)
      love.graphics.circle('fill', x0, y0, cell_w * 0.2)
      love.graphics.setLineWidth(4.0)
      love.graphics.line(x0, y0,
        x0 + cell_w * 0.4 * Board.moves[o.dir][2],
        y0 + cell_w * 0.4 * Board.moves[o.dir][1])
    end)

    -- Pointer
    if pt_r ~= nil then
      love.graphics.setColor(1, 1, 0.3, 0.2)
      love.graphics.rectangle('fill',
        board_offs_x + cell_w * pt_c,
        board_offs_y + cell_w * pt_r,
        cell_w, cell_w)
    end
  end

  s.destroy = function ()
  end

  return s
end
