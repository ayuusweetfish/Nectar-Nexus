return function ()
  local s = {}

  s.dx = 0

  local held = false
  local hx  -- Held start position
  local hxo -- Held offset (`dx` = pointer x + `hxo`)
  local captured = false

  s.press = function (x, y)
    held = true
    hx = x
    hxo = s.dx - x
    captured = false
  end

  -- Return values
  -- false: Event passthrough
  -- 1: Event should not be passed further
  -- 2: ... In addition, all underlying pointer presses should be cancelled
  s.move = function (x, y)
    if not held then return false end
    s.dx = hxo + x
    if (x - hx) * (x - hx) >= 400 then
      if not captured then
        -- Start capture
        return 2
      end
    elseif not captured then
      return false
    end
    return 1
  end

  s.release = function (x, y)
    held = false
    captured = false
  end

  s.update = function ()
  end

  return s
end
