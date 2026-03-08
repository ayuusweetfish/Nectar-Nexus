local imgs = {}

local img_paths = {}

local imgs_to_load = {}
local function find_imgs(path)
  local files = love.filesystem.getDirectoryItems('img' .. path)
  for i = 1, #files do
    local basename = files[i]
    if basename:sub(-4) == '.png' or basename:sub(-4) == '.jpg' then
      local name = (path .. '/' .. basename:sub(1, #basename - 4)):sub(2)
      if name:sub(1, 6) ~= 'vines/' then
        local img_path = 'img' .. path .. '/' .. basename
        img_paths[name] = img_path
        imgs_to_load[#imgs_to_load + 1] = name
      end
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
  local a_priority = ((a:sub(1, 22) == 'butterflies/idle-side/' or a == 'bloom/visited/08') and 0 or 1)
  local b_priority = ((b:sub(1, 22) == 'butterflies/idle-side/' or b == 'bloom/visited/08') and 0 or 1)
  if a_priority ~= b_priority then return a_priority < b_priority end
  return a < b
end)

local load_single_image = function (name)
  local img_path = img_paths[name]
  local use_mipmaps = (name:sub(1, 6) == 'vines/')
  local data = love.image.newImageData(img_path)
  if use_mipmaps and not full_npot then
    -- Extend to power-of-two
    local w, h = data:getDimensions()
    local ext_w, ext_h = 1, 1
    while ext_w < w do ext_w = ext_w * 2 end
    while ext_h < h do ext_h = ext_h * 2 end
    local ext_data = love.image.newImageData(ext_w, ext_h)
    ext_data:paste(data, 0, 0, 0, 0, w, h)
    data:release()
    data = ext_data
  end
  imgs[name] = love.graphics.newImage(data, { mipmaps = use_mipmaps })
end

local unload_single_image = function (name)
  imgs[name]:release()
  imgs[name] = nil
end

-- Returns (progress, total, name)
local imgs_to_load_ptr = 0
local full_npot = love.graphics.getSupported()['fullnpot']
local load_img_step = function ()
  if imgs_to_load_ptr >= #imgs_to_load then return end
  imgs_to_load_ptr = imgs_to_load_ptr + 1
  local name = imgs_to_load[imgs_to_load_ptr]
  load_single_image(name)
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
  load = load_single_image,
  unload = unload_single_image,
  get = function (name) return imgs[name] end,
  img = img,
  shadow = shadow,
  enclose = enclose,
}
setmetatable(draw_, { __call = function (self, ...) draw(...) end })
return draw_
