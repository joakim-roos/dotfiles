-- Right Command: hold to speak, release to mute the default microphone.
require('hs.ipc')

local mask = hs.eventtap.event.rawFlagMasks.deviceRightCommand
local device, deviceUID, level
local down = false
local supportsMute = false
local saved = hs.settings.get('pushToTalk.levels') or {}

local function remember()
  if not device then return end
  local current = device:inputVolume()
  if current and current > 0 then
    level = current
    if saved[deviceUID] ~= current then
      saved[deviceUID] = current
      hs.settings.set('pushToTalk.levels', saved)
    end
  end
end

local function setSpeaking(speaking)
  if not device then return end
  if supportsMute then
    if device:inputMuted() ~= (not speaking) then
      if not device:setInputMuted(not speaking) then
        hs.alert.show('Push-to-talk: microphone mute failed')
      end
    end
  else
    local target = speaking and level or 0
    if device:inputVolume() ~= target then device:setInputVolume(target) end
  end
end

local function selectDevice()
  local nextDevice = hs.audiodevice.defaultInputDevice()
  local nextUID = nextDevice and nextDevice:uid()
  if nextUID == deviceUID then return false end
  if device then
    remember()
    setSpeaking(false)
  end
  device, deviceUID = nextDevice, nextUID
  down = false
  if device then
    level = saved[deviceUID] or 100
    supportsMute = device:inputMuted() ~= nil
    if not saved[deviceUID] then remember() end
    setSpeaking(false)
    if supportsMute then
      device:setInputVolume(level)
    else
      hs.alert.show('This microphone has no mute control. Input volume alone may not block sound.')
    end
  end
  return true
end

local function update(raw)
  local changed = selectDevice()
  if not device then return end
  local pressed = hs.accessibilityState() and (raw & mask) ~= 0
  if pressed == down and not changed then
    setSpeaking(down)
    return
  end
  if down then remember() end
  if pressed then device:setInputVolume(level) end
  down = pressed
  setSpeaking(down)
end

rightCmdWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
  update(event:rawFlags())
  return false
end):start()

-- Detect device changes and recover from a missed key release.
pushToTalkTimer = hs.timer.doEvery(0.2, function()
  if hs.accessibilityState() and not rightCmdWatcher:isEnabled() then
    rightCmdWatcher:start()
  end
  selectDevice()
  -- Polling omits the right-side flag. Only events identify Right Command.
  if down and not hs.eventtap.checkKeyboardModifiers().cmd then
    update(0)
  else
    setSpeaking(down)
  end
end)

hs.shutdownCallback = function()
  if device then
    remember()
    setSpeaking(false)
  end
end

selectDevice()
