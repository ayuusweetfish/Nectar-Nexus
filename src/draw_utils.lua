local imgs = {}

local imgs_to_load = {}
local function find_imgs(path)
  local files = love.filesystem.getDirectoryItems('img' .. path)
  for i = 1, #files do
    local basename = files[i]
    if basename:sub(-4) == '.png' or basename:sub(-4) == '.jpg' then
      local name = (path .. '/' .. basename:sub(1, #basename - 4)):sub(2)
      local img_path = 'img' .. path .. '/' .. basename
      imgs_to_load[#imgs_to_load + 1] = {name, img_path}
    else
      -- Folder?
      if love.filesystem.getInfo('img' .. path .. '/' .. basename).type == 'directory' then
        find_imgs(path .. '/' .. basename)
      end
    end
  end
end
find_imgs('')
table.sort(imgs_to_load, function (a, b)
  local a_priority = ((a[1]:sub(1, 22) == 'butterflies/idle-side/' or a[1] == 'bloom/visited/08') and 0 or 1)
  local b_priority = ((b[1]:sub(1, 22) == 'butterflies/idle-side/' or b[1] == 'bloom/visited/08') and 0 or 1)
  if a_priority ~= b_priority then return a_priority < b_priority end
  return a[1] < b[1]
end)

-- Returns (progress, total, name)
local imgs_to_load_ptr = 0
local load_img_step = function ()
  if imgs_to_load_ptr >= #imgs_to_load then return end
  imgs_to_load_ptr = imgs_to_load_ptr + 1
  local name, img_path = unpack(imgs_to_load[imgs_to_load_ptr])
  imgs[name] = love.graphics.newImage(img_path)
  return imgs_to_load_ptr, #imgs_to_load, name
end

local draw = function (drawable, x, y, w, h, ax, ay, r)
  ax = ax or 0.5
  ay = ay or 0.5
  r = r or 0
  local iw, ih = drawable:getDimensions()
  local sx = w and w / iw
  local sy = h and h / ih
  if sx == nil and sy == nil then
    sx, sy = 1, 1
  elseif sx == nil or sy == nil then
    local s = sx or sy
    sx, sy = s, s
  end
  love.graphics.draw(drawable,
    x, y, r,
    sx, sy,
    ax * iw, ay * ih)
end

local img = function (name, x, y, w, h, ax, ay, r)
  draw(imgs[name], x, y, w, h, ax, ay, r)
end

local shadow = function (R, G, B, A, drawable, x, y, w, h, ax, ay, r)
  love.graphics.setColor(R / 2, G / 2, B / 2, A * A / 2)
  draw(drawable, x + 1, y + 1, w, h, ax, ay, r)
  love.graphics.setColor(R, G, B, A)
  draw(drawable, x - 1, y - 1, w, h, ax, ay, r)
end

local enclose = function (drawable, w, h, extraOffsX, extraOffsY)
  local iw, ih = drawable:getDimensions()
  local offsX = (w - iw) / 2 + (extraOffsX or 0)
  local offsY = (h - ih) / 2 + (extraOffsY or 3)  -- Font specific
  local s = {}
  s.getDimensions = function (self)
    return w, h
  end
  s.draw = function (self, x, y, sc)
    love.graphics.rectangle('line',
      x, y, w * sc, h * sc, 10)
    love.graphics.draw(drawable, x + offsX * sc, y + offsY * sc, 0, sc)
  end
  return s
end

local draw_ = {
  load_img_step = load_img_step,
  get = function (name) return imgs[name] end,
  img = img,
  shadow = shadow,
  enclose = enclose,
}
setmetatable(draw_, { __call = function (self, ...) draw(...) end })
return draw_
