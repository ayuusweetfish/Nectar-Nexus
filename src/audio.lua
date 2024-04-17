local sources = {
  move = love.audio.newSource('aud/move.ogg', 'static'),
  undo = love.audio.newSource('aud/undo.ogg', 'static'),
  weeds = love.audio.newSource('aud/weeds.ogg', 'static'),
}

local T = 0
local delayed_sfx = {}  -- {time, name}
local sfx_update = function (dt)
  T = T + dt
  while #delayed_sfx > 0 and T >= delayed_sfx[1][1] do
    local name = delayed_sfx[1][2]
    sources[name]:stop()
    sources[name]:play()
    table.remove(delayed_sfx, 1)
  end
  if #delayed_sfx == 0 then T = 0 end
end

local sfx_cancel_all = function ()
  delayed_sfx = {}
end

local sfx = function (name, delay)
  if delay == 0 or delay == nil then
    sources[name]:stop()
    sources[name]:play()
  else
    local i = 1
    local t = T + delay
    while i <= #delayed_sfx do
      if t < delayed_sfx[i][1] then break end
      i = i + 1
    end
    table.insert(delayed_sfx, i, {t, name})
  end
end

-- Choose a value for `bufSize` so that
-- (loopLen (s) * sampleRate (Hz)) % (bufSize (B) / frameSize (B)) is close to 0
-- Note: frameSize is channelCount * (1 or 2 B, depending on bit depth)
local loop = function (introPath, introLen, loopPath, loopLen, bufSize)
  bufSize = bufSize or 1024

  local decLoop = love.sound.newDecoder(loopPath, bufSize)
  local sr = decLoop:getSampleRate()
  local ch = decLoop:getChannelCount()
  local bd = decLoop:getBitDepth()

  local decIntro
  if introPath ~= nil then
    love.sound.newDecoder(introPath, bufSize)
    if sr ~= decIntro:getSampleRate() then error('Sample rates mismatch') end
    if ch ~= decIntro:getChannelCount() then error('Channel count mismatch') end
    if bd ~= decIntro:getBitDepth() then error('Bit depth mismatch') end
  end

  local decLoopAlt = decLoop:clone()

  introLen = math.ceil(introLen * sr)
  loopLen = math.ceil(loopLen * sr)
  local pktSamples = math.floor(bufSize / (ch * bd / 8))

  local source = love.audio.newQueueableSource(sr, bd, ch, 64)

  local introRunning = (introPath ~= nil)
  local altRunning = false
  local curSample = -introLen
  local push = function ()
    local data = {}   -- SoundData, offset
    if introRunning then
      local pkt = decIntro:decode()
      if pkt == nil then
        introRunning = false
      else
        data[#data + 1] = pkt
      end
    end
    if curSample >= 0 then
      -- Decoded packet is non-nil if the given length is less than actual
      -- but the assignment is a no-op if the packet is nil anyway
      data[#data + 1] = decLoop:decode()
      if altRunning then
        local pkt = decLoopAlt:decode()
        if pkt == nil then
          altRunning = false
        else
          data[#data + 1] = pkt
        end
      end
      -- Check: should a new loop be started?
      -- Round to cancel inaccuracies introduced by packets
      if curSample + pktSamples / 2 >= loopLen then
        decLoopAlt, decLoop = decLoop, decLoopAlt
        altRunning = true
        decLoop:seek(0)
        data[#data + 1] = decLoop:decode()
        curSample = curSample - loopLen
      end
    end
    curSample = curSample + pktSamples
    if #data == 1 then
      source:queue(data[1])
    elseif #data >= 2 then
      local mix = love.sound.newSoundData(pktSamples, sr, bd, ch)
      for i = 1, pktSamples do
        for c = 1, ch do
          local mixSample = 0
          for _, d in ipairs(data) do
            if i <= d:getSampleCount() then
              mixSample = mixSample + d:getSample(i - 1, c)
            end
          end
          mix:setSample(i - 1, c, mixSample)
        end
      end
      source:queue(mix)
    end
  end

  local update = function ()
    for _ = 1, source:getFreeBufferCount() do push() end
    if not source:isPlaying() then source:play() end
  end
  update()

  return source, update
end

return {
  sfx = sfx,
  sfx_update = sfx_update,
  sfx_cancel_all = sfx_cancel_all,
  loop = loop
}
