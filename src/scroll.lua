return function ()
  local s = {}

  s.dx = 0

  local held = false
  local hx  -- Held start position
  local hxo -- Held offset (`dx` = pointer x + `hxo`)
  local captured = false
  -- Ring buffer of history `dx`
  local history, history_ptr
  local HISTORY_WINDOW = 40

  local intertia_v = 0
  local DECEL = 0.2

  s.press = function (x, y)
    held = true
    hx = x
    hxo = s.dx - x
    captured = false
    history, history_ptr = {}, HISTORY_WINDOW
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
        captured = true
        return 2
      end
    elseif not captured then
      return false
    end
    return 1
  end

  s.release = function (x, y)
    if held and captured then
      -- Calculate velocity
      local time, delta
      if #history < HISTORY_WINDOW then
        time = #history - 1
        delta = history[#history] - history[1]
      else
        time = HISTORY_WINDOW - 1
        delta = history[history_ptr] - history[history_ptr % HISTORY_WINDOW + 1]
      end
      intertia_v = delta / time
    end

    held = false
    captured = false
    history, history_ptr = nil, nil
  end

  s.update = function ()
    if held and captured then
      if history_ptr == HISTORY_WINDOW then
        history_ptr = 1
      else
        history_ptr = history_ptr + 1
      end
      history[history_ptr] = s.dx
    elseif intertia_v ~= 0 then
      local sign = (intertia_v < 0 and -1 or 1)
      local next_v = (math.abs(intertia_v) < DECEL and 0 or intertia_v - sign * DECEL)
      s.dx = s.dx + (intertia_v + next_v) / 2
      intertia_v = next_v
    end
  end

  return s
end