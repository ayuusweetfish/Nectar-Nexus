W = 1280
H = 720

local isMobile = (love.system.getOS() == 'Android' or love.system.getOS() == 'iOS')
local isWeb = (love.system.getOS() == 'Web')

love.window.setMode(
  isWeb and (W / 3 * 2) or W,
  isWeb and (H / 3 * 2) or H,
  { fullscreen = false, highdpi = true }
)

local globalScale, Wx, Hx, offsX, offsY

local updateLogicalDimensions = function ()
  love.window.setTitle('Nectar Nexus')
  local wDev, hDev = love.graphics.getDimensions()
  globalScale = math.min(wDev / W, hDev / H)
  Wx = wDev / globalScale
  Hx = hDev / globalScale
  offsX = (Wx - W) / 2
  offsY = (Hx - H) / 2
end
updateLogicalDimensions()

-- Load font
local fontSizeFactory = function (path, preload)
  local font = {}
  if preload ~= nil then
    for i = 1, #preload do
      local size = preload[i]
      font[size] = love.graphics.newFont(path, size)
    end
  end
  return function (size)
    if font[size] == nil then
      font[size] = love.graphics.newFont(path, size)
    end
    return font[size]
  end
end
-- _G['font_Imprima'] = fontSizeFactory('assets/Imprima-Regular.ttf', {28, 36})
-- love.graphics.setFont(_G['font_Imprima'](40))

_G['sceneLoading'] = require 'scene_loading'
local load_next = function ()
  _G['sceneIntro'] = require 'scene_intro'
  _G['sceneGameplay'] = require 'scene_gameplay'
  _G['sceneEnding'] = require 'scene_ending'
end

local curScene = sceneLoading(load_next)
local lastScene = nil
local transitionTimer = 0
local currentTransition = nil
local transitions = {}
_G['transitions'] = transitions

_G['replaceScene'] = function (newScene, transition)
  lastScene = curScene
  curScene = newScene
  transitionTimer = 0
  currentTransition = transition or transitions['fade'](0.1, 0.1, 0.1)
end

local mouseScene = nil
function love.mousepressed(x, y, button, istouch, presses)
  if button ~= 1 then return end
  if lastScene ~= nil then return end
  mouseScene = curScene
  curScene.press((x - offsX) / globalScale, (y - offsY) / globalScale)
end
function love.mousemoved(x, y, button, istouch)
  curScene.hover((x - offsX) / globalScale, (y - offsY) / globalScale)
  if mouseScene ~= curScene then return end
  curScene.move((x - offsX) / globalScale, (y - offsY) / globalScale)
end
function love.mousereleased(x, y, button, istouch, presses)
  if button ~= 1 then return end
  if mouseScene ~= curScene then return end
  curScene.release((x - offsX) / globalScale, (y - offsY) / globalScale)
  mouseScene = nil
end
function love.keypressed(key)
  if key == 'lshift' then
    if not isMobile and not isWeb then
      love.window.setFullscreen(not love.window.getFullscreen())
      updateLogicalDimensions()
    end
  elseif curScene.key ~= nil then
    curScene.key(key)
  end
end

-- Background track
-- Load after visuals have been ready
local audio = require 'audio'
local bgm, bgm_update = audio.loop(
  nil, 0,
  'aud/background.ogg', (80 * 3) * (60 / 72),
  1600 * 4)
bgm:setVolume(1)

local T = 0
local timeStep = 1 / 240

local sinceAudioUpdate = 0

function love.update(dt)
  T = T + dt
  local count = 0
  while T > timeStep and count < 4 do
    T = T - timeStep
    count = count + 1
    if lastScene ~= nil then
      lastScene:update()
      -- At most 4 ticks per update for transitions
      if count <= 4 then
        transitionTimer = transitionTimer + 1
      end
    else
      curScene:update()
    end
  end

  sinceAudioUpdate = sinceAudioUpdate + dt
  if sinceAudioUpdate >= 0.5 then
    sinceAudioUpdate = sinceAudioUpdate - 0.5
    bgm_update()
  end
  audio.sfx_update(dt)
end

transitions['fade'] = function (r, g, b)
  return {
    dur = 120,
    draw = function (x)
      local opacity = 0
      if x < 0.5 then
        lastScene:draw()
        opacity = x * 2
      else
        curScene:draw()
        opacity = 2 - x * 2
      end
      love.graphics.setColor(r, g, b, opacity)
      love.graphics.rectangle('fill', -offsX, -offsY, Wx, Hx)
    end
  }
end

function love.draw()
  love.graphics.scale(globalScale)
  love.graphics.setColor(1, 1, 1)
  love.graphics.push()
  love.graphics.translate(offsX, offsY)
  if lastScene ~= nil then
    local x = transitionTimer / currentTransition.dur
    currentTransition.draw(x)
    if x >= 1 then
      if lastScene.destroy then lastScene.destroy() end
      lastScene = nil
    end
  else
    curScene.draw()
  end
  love.graphics.pop()
end
