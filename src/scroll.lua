return function (options)
  local s = {}

  s.dx = 0

  local x_min = (options and options.x_min) or -1e20
  local x_max = (options and options.x_max) or 1e20
  local screen_x_min = (options and options.screen_x_min) or -1e20
  local screen_x_max = (options and options.screen_x_max) or 1e20
  local screen_y_min = (options and options.screen_y_min) or -1e20
  local screen_y_max = (options and options.screen_y_max) or 1e20
  local carousel = (options and options.carousel) or false

  local w = math.min(screen_x_max - screen_x_min, W)

  local held = false
  local hx  -- Held start position
  local hxo -- Held offset (`dx` = pointer x + `hxo`)
  local captured = false
  -- Ring buffer of history `dx`
  local history, history_ptr
  local HISTORY_WINDOW = 40

  local inertia_v = 0
  local DECEL = 0.2

  local carousel_target

  s.press = function (x, y)
    if x < screen_x_min or x > screen_x_max or
       y < screen_y_min or y > screen_y_max then
      return false
    end
    held = true
    hx = x
    hxo = s.dx - x
    captured = false
    history, history_ptr = {}, HISTORY_WINDOW
    inertia_v = 0
    return true
  end

  -- Return values
  -- false: Event passthrough
  -- 1: Event should not be passed further
  -- 2: ... In addition, all underlying pointer presses should be cancelled
  s.move = function (x, y)
    if not held then return false end
    s.dx = hxo + x
    local w_lim = w * 0.38
    if s.dx < x_min then
      s.dx = x_min - w_lim * (1 - math.exp((s.dx - x_min) / w_lim))
    elseif s.dx > x_max then
      s.dx = x_max + w_lim * (1 - math.exp((x_max - s.dx) / w_lim))
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
      inertia_v = delta / time
      -- Carousel?
      if carousel then
        carousel_target = math.floor((s.dx + math.max(-w/2, math.min(w/2, inertia_v * 60))) / w + 0.5) * w
        carousel_target = math.max(x_min, math.min(x_max, carousel_target))
        inertia_v = inertia_v / 2
      end
    end

    local prev_held = held
    held = false
    captured = false
    history, history_ptr = nil, nil
    return prev_held
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
      if inertia_v ~= 0 then
        local sign = (inertia_v < 0 and -1 or 1)
        local decel = DECEL
        if s.dx < x_min then
          decel = decel * math.exp((x_min - s.dx) / W * 4)
        elseif s.dx > x_max then
          decel = decel * math.exp((s.dx - x_max) / W * 4)
        end
        local next_v = (math.abs(inertia_v) < decel and 0 or inertia_v - sign * decel)
        s.dx = s.dx + (inertia_v + next_v) / 2
        inertia_v = next_v
      end
      -- Pull towards target
      if carousel_target ~= nil then
        s.dx = s.dx + (carousel_target - s.dx) * 0.06
      else
        -- Pull into range
        if s.dx < x_min then
          s.dx = s.dx + (x_min - s.dx) * 0.04
        elseif s.dx > x_max then
          s.dx = s.dx + (x_max - s.dx) * 0.04
        end
      end
    end
  end

  s.carousel_page_index = function ()
    return math.floor(-s.dx / w + 0.5 + 1)
  end

  return s
end
