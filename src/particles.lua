local white_tex_1x1_data = love.image.newImageData(1, 1, 'rgba8')
white_tex_1x1_data:setPixel(0, 0, 1, 1, 1, 1)
local white_tex_1x1 = love.graphics.newImage(white_tex_1x1_data)
local shader_light = love.graphics.newShader([[
uniform float fade;
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
  float alpha;
  alpha = clamp(1 - 2 * length(vec2(texture_coords.x - 0.5, (texture_coords.y - 0.5) * 1.1)) - fade, 0.0, 1.0);
  // Map [0, 1 - fade] onto [0, (1 - fade)^2], with a sine easing
  alpha = (sin((alpha / (1 - fade) - 0.5) * 3.14159265359) + 1) / 2 * (1 - fade) * (1 - fade);
  return vec4(color.rgb, alpha);
}
]])
local rect = function (x1, y1, x2, y2)
  love.graphics.draw(white_tex_1x1, x1, y1, 0, x2 - x1, y2 - y1, 0, 0)
end

return function (options)
  local s = {}
  s.x = 0
  s.y = 0
  s.tint = {0.6, 0.7, 0.8}

  -- Particles
  -- {x, y, age}
  local ps = {}

  local until_next_spawn = 0

  local y_max = (options and options.y_max) or 70
  local x_spread = (options and options.x_spread) or 20
  local scale = (options and options.scale) or 1

  local map_asin = function (x) return 0.5 + math.asin(2 * x - 1) / math.pi end
  local new_particle = function ()
    return {
      x_rg = (map_asin(map_asin(math.random())) - 0.5) * 0.04,
      x_offs = (math.random() - 0.5) * x_spread,
      v = (1 + math.random() * 0.1) * 0.06,
      y_lim = (1 + math.random()^2 * 0.4) * y_max,
      y_offs = (math.random() - 0.5) * 10,
      lfo1_f = (1 + math.random() * 0.3) * 0.012,
      lfo1_a = math.random() * 15,
      lfo1_ph = math.random() * math.pi * 2,
      lfo2_f = (1 + math.random() * 0.3) * 0.006,
      lfo2_a = math.random()^3 * 8,
      lfo2_ph = math.random() * math.pi * 2,
      lfo3_f = (1 + math.random() * 0.5) * 0.008,
      lfo3_a = (1 + math.random() * 0.3) * 35,
      lfo4_f = (1 + math.random() * 0.5) * 0.005,
      lfo4_a = (1 + math.random() * 0.3) * 25,
      age = 0,
    }
  end

  for i = 1, 40 do
    local p = new_particle()
    p.age = math.random() * (p.y_lim / p.v)
    ps[#ps + 1] = p
  end

  s.update = function ()
    until_next_spawn = until_next_spawn - 1
    if #ps < 40 and until_next_spawn < 0 then
      -- Spawn a new particle
      ps[#ps + 1] = new_particle()
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

  -- Opacity mapping function
  local k = 3.5
  local max_val = ((k^k) / (k+1)^(k+1))
  local opacity_mapping = function (x)
    return math.sqrt(x * (1 - x)^k / max_val)
  end

  s.draw = function ()
    local x, y = s.x, s.y
    local r, g, b = unpack(s.tint)

    local ordinary_fade = s.ordinary_fade or 0

    local follow_rate = 0
    local follow_x, follow_y = x, y
    if s.follow ~= nil then
      follow_x, follow_y = unpack(s.follow)
      follow_rate = s.follow_rate
    end

    local wave_out = s.wave_out

    love.graphics.setColor(r, g, b)
    love.graphics.setShader(shader_light)
    shader_light:send('fade', 1 - (1 - follow_rate) * (1 - ordinary_fade))
    rect(x - 30, y - 30, x + 30, y + 30)

    love.graphics.setShader(nil)
    for i = 1, #ps do
      local p = ps[i]
      local t = p.age + math.sin(p.age * p.lfo1_f + p.lfo1_a) * p.lfo1_a
      local x1 = p.x_offs + p.x_rg * t + math.sin(p.age * p.lfo2_f + p.lfo2_a) * p.lfo2_a
      local y1 = p.y_offs - p.v * t
      local y_rate = -y1 / p.y_lim
      local alpha = opacity_mapping(y_rate)
      local radius = math.sqrt(alpha) + y_rate * 0.75
      x1, y1 = x + x1, y + y1

      -- Ordinary fade
      radius = radius * (1 - ordinary_fade)

      -- Following
      if s.follow ~= nil then
        local x2, y2 = follow_x, follow_y
        x2 = x2 + math.sin(p.age * p.lfo3_f + p.lfo1_a) * p.lfo3_a
        y2 = y2 + math.sin(p.age * p.lfo4_f + p.lfo2_a) * p.lfo4_a
        x1 = x1 + (x2 - x1) * follow_rate
        y1 = y1 + (y2 - y1) * follow_rate
        if i % 2 == 0 then
          radius = radius * (1 - follow_rate)
        end
      end

      -- Waving out
      if wave_out then
        local x3, y3 = follow_x, follow_y
        x3 = x3 + math.sin(p.age * p.lfo3_f * 3 + p.lfo1_a) * p.lfo3_a * 6 * (1 - wave_out)
        y3 = y3 + math.sin(p.age * p.lfo4_f * 3 + p.lfo2_a) * p.lfo4_a * 6 * (1 - wave_out)
        x1 = x1 + (x3 - x1) * wave_out
        y1 = y1 + (y3 - y1) * wave_out
        radius = radius * (1 - wave_out)
      end

      if scale ~= 1 then
        x1 = x + (x1 - x) * scale
        y1 = y + (y1 - y) * scale
      end

      if alpha > 0 and radius > 0 then
        love.graphics.setColor(r, g, b, alpha)
        love.graphics.circle('fill', x1, y1, 1.2 * radius * scale, 12)
      end
    end
  end

  return s
end
