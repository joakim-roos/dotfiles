-- Run from the dotfiles root. This test uses simulated devices and records no audio.
local function run()
  local callback, tick
  local writes, alerts = 0, 0
  local held = false
  local d = {volume=28, mute=false}
  function d:uid() return 'test-mic' end
  function d:inputVolume() return self.volume end
  function d:setInputVolume(v) self.volume=v; return true end
  function d:inputMuted() return self.mute end
  function d:setInputMuted(v) self.mute=v; return true end
  local fake = {
    settings={get=function() return {} end, set=function() writes=writes+1 end},
    audiodevice={defaultInputDevice=function() return d end},
    accessibilityState=function() return true end,
    alert={show=function() alerts=alerts+1 end},
    eventtap={event={rawFlagMasks={deviceRightCommand=16},types={flagsChanged=1}},
      checkKeyboardModifiers=function() return {cmd=held,_raw=held and 1048576 or 0} end,
      new=function(_,fn) callback=fn; return {start=function(self) return self end,isEnabled=function() return true end} end},
    timer={doEvery=function(_,fn) tick=fn; return {} end}
  }
  local env=setmetatable({hs=fake,require=function() end},{__index=_G})
  assert(loadfile('.hammerspoon/init.lua','t',env))()
  local function event(raw) callback({rawFlags=function() return raw end}) end
  assert(d.mute,'startup must mute')
  held=true; event(1048592); assert(not d.mute,'Right Command must unmute')
  for i=1,20 do tick() end
  assert(not d.mute,'timer must preserve held Right Command')
  held=false; event(0); assert(d.mute,'release must mute')
  held=true; event(1048584); tick(); assert(d.mute,'Left Command must not unmute')
  event(1048592); held=false; tick(); assert(d.mute,'missed release must recover')
  d.mute=false; tick(); assert(d.mute,'external unmute must recover')
  held=true; event(1048592); d.volume=42; held=false; event(0)
  assert(d.volume==42,'speaking level must persist')
  local before=writes
  collectgarbage('collect'); local mem=collectgarbage('count')
  for i=1,50000 do tick() end
  collectgarbage('collect'); local delta=collectgarbage('count')-mem
  assert(writes==before,'idle must not write settings')
  assert(delta<10,'idle must not retain growing Lua state')
  fake.shutdownCallback(); assert(d.mute,'shutdown must mute')
  assert(alerts==0,'normal use must not generate alerts')
  print('PASS: startup, right/left keys, held polling, release recovery, external mute recovery, saved level, shutdown')
  print('PASS: 50000 idle ticks, no settings writes; retained Lua memory delta KB',delta)
end
run()
