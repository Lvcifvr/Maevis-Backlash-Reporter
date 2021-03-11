local f = CreateFrame("Frame");
local COMBAT_LOG_DELAY = 50 -- MS
local instability_timestamp, instability_players, instability_stacks, backlash_damage, backlash_absorbed, backlash_targets = nil, {}, {}, 0, 0, 0
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event, ...)
  local arg = {...}
  if instability_timestamp ~= nil and (arg[1] - instability_timestamp) > (COMBAT_LOG_DELAY / 1000) then
    report()
  end
  if arg[2] == "SPELL_AURA_APPLIED" and arg[9] == 69766 then
    instability_stacks[arg[7]] = 1
  elseif arg[2] == "SPELL_AURA_APPLIED_DOSE" and arg[9] == 69766 then
    instability_stacks[arg[7]] = arg[13]
  elseif arg[2] == "SPELL_AURA_REMOVED" and arg[9] == 69766 then
    instability_timestamp = arg[1]
    table.insert(instability_players, arg[7])
  elseif (arg[2] == "SPELL_DAMAGE" or arg[2] == "SPELL_MISSED") and (arg[9] == 69770 or arg[9] == 71046 or arg[9] == 71044 or arg[9] == 71045) then
      backlash_targets = backlash_targets + 1
      if arg[2] == "SPELL_DAMAGE" then
        backlash_damage = backlash_damage + arg[12]
      elseif arg[2] == "SPELL_MISSED" and arg[12] == "ABSORB" then
        backlash_absorbed = backlash_absorbed + arg[13]
      end
  end
end)

function reset()
  instability_timestamp = nil
  for index, name in pairs(instability_players) do
    instability_stacks[name] = 0
  end
  table.wipe(instability_players)
end

function report()
  local text = "\124cFFFF0000[MBR]: "
  for index, name in pairs(instability_players) do
    text = text .. name .. " blowed up with: " .. (instability_stacks[name] or "?") .. " stacks!"
  end
  print(text)
  reset()
end
