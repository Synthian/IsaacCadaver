local Helper = include("Helper")
local json = require("json")

local TaintedCadaver = {}

PlayerType.PLAYER_TAINTED_CADAVER = Isaac.GetPlayerTypeByName("Cadaver", true)

local TAINTED_CADAVER_STATS = {
  STATIC_TEAR_DELAY = 2.0,
  DAMAGE_MODIFIER = 0
}

local lastItemDamage = -1.0
local lastCalculatedDamage = -1.0
local currentMultiplier = -1.0

function TaintedCadaver.ModifyStats(player, cacheFlag)
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER then
    if cacheFlag == CacheFlag.CACHE_FIREDELAY or cacheFlag == CacheFlag.CACHE_DAMAGE then
      if string.format("%.2f", player.Damage) == string.format("%.2f", lastCalculatedDamage) and player.MaxFireDelay ~= TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY then
        local lockedRate = 30.0 / (TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY + 1.0)
        local newRate = 30.0 / (player.MaxFireDelay + 1)
        currentMultiplier = newRate / lockedRate
        player.MaxFireDelay = TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY
        lastCalculatedDamage = (lastItemDamage + TAINTED_CADAVER_STATS.DAMAGE_MODIFIER) * currentMultiplier
        player.Damage = lastCalculatedDamage
      end

      if string.format("%.2f", player.Damage) ~= string.format("%.2f", lastCalculatedDamage) and player.MaxFireDelay == TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY then
        lastItemDamage = player.Damage
        lastCalculatedDamage = (player.Damage + TAINTED_CADAVER_STATS.DAMAGE_MODIFIER) * currentMultiplier
        player.Damage = lastCalculatedDamage
      end

      if string.format("%.2f", player.Damage) ~= string.format("%.2f", lastCalculatedDamage) and player.MaxFireDelay ~= TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY then
        lastItemDamage = player.Damage
        local lockedRate = 30.0 / (TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY + 1.0)
        local newRate = 30.0 / (player.MaxFireDelay + 1)
        currentMultiplier = newRate / lockedRate
        player.MaxFireDelay = TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY
        lastCalculatedDamage = (player.Damage + TAINTED_CADAVER_STATS.DAMAGE_MODIFIER) * currentMultiplier
        player.Damage = lastCalculatedDamage
      end 
    end
  end
end

EntityFlag.FLAG_CADAVER_PET = 1<<61

function TaintedCadaver.ManageArmy(player)
  local maggots = {}
  local entities = Isaac:GetRoomEntities()
  for i, entity in ipairs(entities) do
    if entity:GetEntityFlags() & EntityFlag.FLAG_CADAVER_PET == EntityFlag.FLAG_CADAVER_PET then
      table.insert(maggots, entity)
    end
  end

  if #maggots < 4 then
    local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
    maggot:AddEntityFlags(EntityFlag.FLAG_CADAVER_PET)
    maggot:AddCharmed(EntityRef(maggot), -1)
  end

  -- local entities = Isaac:GetRoomEntities()
  -- for i, entity in ipairs(entities) do
  --   if entity:IsEnemy() and not entity:HasEntityFlags(1<<80) then
      
  --   end
  -- end
end


function TaintedCadaver.Reset(isContinued)
  if not isContinued then
    numFriendlyUnits = 0
    maggots = {}
  end
end

return TaintedCadaver