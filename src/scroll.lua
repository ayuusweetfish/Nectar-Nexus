return function (options)
  local s = {}

  s.dx = 0

  local x_min = (options and options.x_min) or -1e20
  local x_max = (options and options.x_max) or 1e20

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
    intertia_v = 0
  end

  -- Return values
  -- false: Event passthrough
  -- 1: Event should not be passed further
  -- 2: ... In addition, all underlying pointer presses should be cancelled
  s.move = function (x, y)
    if not held then return false end
    s.dx = hxo + x
    if s.dx < x_min then
      s.dx = x_min - (W * 0.3) * (1 - math.exp((s.dx - x_min) / (W * 0.3)))
    elseif s.dx > x_max then
      s.dx = x_max + (W * 0.3) * (1 - math.exp((x_max - s.dx) / (W * 0.3)))
    end
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
    if held then
      if captured then
        if history_ptr == HISTORY_WINDOW then
          history_ptr = 1
        else
          history_ptr = history_ptr + 1
        end
        history[history_ptr] = s.dx
      end
    else
      -- Inertia and deceleration
      if intertia_v ~= 0 then
        local sign = (intertia_v < 0 and -1 or 1)
        local decel = DECEL
        if s.dx < x_min then
          decel = decel * math.exp((x_min - s.dx) / W * 4)
        elseif s.dx > x_max then
          decel = decel * math.exp((s.dx - x_max) / W * 4)
        end
        local next_v = (math.abs(intertia_v) < decel and 0 or intertia_v - sign * decel)
        s.dx = s.dx + (intertia_v + next_v) / 2
        intertia_v = next_v
      end
      -- Pull into range
      if s.dx < x_min then
        s.dx = s.dx + (x_min - s.dx) * 0.04
      elseif s.dx > x_max then
        s.dx = s.dx + (x_max - s.dx) * 0.04
      end
    end
  end

  return s
end
