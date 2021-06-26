local Probiotics = {}

TrinketType.TRINKET_PROBIOTICS = Isaac.GetTrinketIdByName("Probiotics")

local DAMAGE = 1
local TEAR_DELAY = -0.5
local SPEED = 0.25
local LUCK = 1

local active = false

function Probiotics.ModifyStats(player, cacheFlag)
  if player:HasTrinket(TrinketType.TRINKET_PROBIOTICS) and player:GetRottenHearts() > 0 then
    active = true
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
      player.MaxFireDelay = player.MaxFireDelay + TEAR_DELAY
    elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage + DAMAGE
    elseif cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = player.MoveSpeed + SPEED
    elseif cacheFlag == CacheFlag.CACHE_LUCK then
      player.Luck = player.Luck + LUCK
    end
  end
end

function Probiotics.UpdateProbioticsEffect(player)
  if player:HasTrinket(TrinketType.TRINKET_PROBIOTICS) then
    if not active and player:GetRottenHearts() > 0 then
      player:AddCacheFlags(CacheFlag.CACHE_ALL)
      player:EvaluateItems()
    elseif active and player:GetRottenHearts() == 0 then
      player:AddCacheFlags(CacheFlag.CACHE_ALL)
      player:EvaluateItems()
      active = false
    end
  end
end

return Probiotics
