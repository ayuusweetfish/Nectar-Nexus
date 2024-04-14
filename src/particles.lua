return function ()
  local s = {}
  s.x = 0
  s.y = 0
  s.tint = {0.6, 0.7, 0.8}

  -- Particles
  -- {x, y, age}
  local ps = {}

  local until_next_spawn = 0

  s.update = function ()
    local map_asin = function (x) return 0.5 + math.asin(2 * x - 1) / math.pi end
    until_next_spawn = until_next_spawn - 1
    if #ps < 40 and until_next_spawn < 0 then
      -- Spawn a new particle
      ps[#ps + 1] = {
        x_rg = (map_asin(map_asin(math.random())) - 0.5) * 0.04,
        x_offs = (math.random() - 0.5) * 20,
        v = (1 + math.random() * 0.1) * 0.06,
        y_lim = 70 * (1 + math.random()^2 * 0.4),
        y_offs = (math.random() - 0.5) * 10,
        lfo1_f = (1 + math.random() * 0.3) * 0.012,
        lfo1_a = math.random() * 15,
        lfo1_ph = math.random() * math.pi * 2,
        lfo2_f = (1 + math.random() * 0.3) * 0.006,
        lfo2_a = math.random()^3 * 8,
        lfo2_ph = math.random() * math.pi * 2,
        age = 0,
      }
      until_next_spawn = math.floor(math.random() * 60)
    end
    local i = 1
    while i <= #ps do
      local p = ps[i]
      p.age = p.age + 1
      if p.v * p.age >= p.y_lim then
        ps[i] = ps[#ps]
        ps[#ps] = nil   -- Look out for cases where i == #ps
      else
        i = i + 1
      end
    end
  end

  s.draw = function ()
    local x, y = s.x, s.y
    local r, g, b = unpack(s.tint)
    for i = 1, #ps do
      local p = ps[i]
      local t = p.age + math.sin(p.age * p.lfo1_f + p.lfo1_a) * p.lfo1_a
      local x1 = p.x_offs + p.x_rg * t + math.sin(p.age * p.lfo2_f + p.lfo2_a) * p.lfo2_a
      local y1 = p.y_offs - p.v * t
      local y_rate = -y1 / p.y_lim
      -- Opacity, do not confuse with Beta function/distribution and the like
      local k = 3.5
      local alpha = math.sqrt(y_rate * (1 - y_rate)^k / ((k^k) / (k+1)^(k+1)))
      local radius = math.sqrt(alpha) + y_rate * 0.75
      love.graphics.setColor(r, g, b, alpha)
      love.graphics.circle('fill', x + x1, y + y1, 1.5 * radius)
    end
  end

  return s
end
