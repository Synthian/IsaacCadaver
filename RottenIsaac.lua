local Helper = require("Helper")
local RottenIsaac = {}

PlayerType.PLAYER_CADAVER = Isaac.GetPlayerTypeByName("Cadaver")

local CADAVER_STATS = {
  STATIC_TEAR_DELAY = 19.0,
  DAMAGE_MODIFIER = 0
}

local lastItemDamage = -1.0
local lastCalculatedDamage = -1.0
local currentMultiplier = -1.0

function RottenIsaac.AddCostume(player)
  local cadaverCostume = Isaac.GetCostumeIdByPath("gfx/characters/cadaver.anm2")
  player:AddNullCostume(cadaverCostume)
end

function RottenIsaac.SpawnFriends()
  local player = Isaac.GetPlayer(0)
  local r = CadaverRNG:RandomFloat()
  
  if r < 0.2 then
    -- 1-2 random locusts
    for i=1,Helper.OneIndexedRandom(CadaverRNG, 2) do
      Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, Helper.OneIndexedRandom(CadaverRNG, 5), Helper.RandomNearbyPosition(player), Vector(0,0), nil)
    end
  elseif r < 0.4 then
    -- 1-2 blue spiders
    for i=1,Helper.OneIndexedRandom(CadaverRNG, 2) do
      player:AddBlueSpider(Helper.RandomNearbyPosition(player))
    end
  elseif r < 0.6 then
    -- 1 charmed Pooter
    local pooter = Isaac.Spawn(EntityType.ENTITY_POOTER, 0, 0, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
    pooter:AddCharmed(EntityRef(pooter), -1)
  elseif r < 0.8 then
    -- 1-2 charmed small maggots and 1-2 charmed small leeches
    for i=1,Helper.OneIndexedRandom(CadaverRNG, 2) do
      local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
      maggot:AddCharmed(EntityRef(maggot), -1)
    end
    for i=1,Helper.OneIndexedRandom(CadaverRNG, 2) do
      local leech = Isaac.Spawn(EntityType.ENTITY_SMALL_LEECH, 0, 0, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
      leech:AddCharmed(EntityRef(leech), -1)
    end
  else
    -- 1 charmed charger
    local charger = Isaac.Spawn(EntityType.ENTITY_CHARGER, 0, 0, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
    charger:AddCharmed(EntityRef(charger), -1)
  end
end

function RottenIsaac.ReplaceHearts(pickup)
  local player = Isaac.GetPlayer(0)
  CadaverItemRNG:SetSeed(pickup.DropSeed, 0)
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER then
    -- Bail if we're in the secret room that only allows red hearts
    local room = Game():GetLevel():GetCurrentRoomDesc().Data
    if room.Type == RoomType.ROOM_SUPERSECRET and room.Variant == 0 then return end
    
    if Helper.IsRedHeart(pickup.Type, pickup.Variant, pickup.SubType) then
      if pickup:IsShopItem() then
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, true)
      else
        if CadaverItemRNG:RandomFloat() < 0.05 then
          pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, false, false, true)
        else
          pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, false, false, true)
        end
      end
    end
  end
end

function RottenIsaac.ConvertHealth(player)
  if player:GetBlackHearts() == 0 and player:GetEffectiveMaxHearts() == 0 and player:GetEternalHearts() == 0 and player:GetSoulHearts() == 1 then
    player:AddBoneHearts(1)
    player:AddHearts(1)
  else
    local hearts = player:GetHearts()
    local rottenHearts = player:GetRottenHearts()
    local rottenReplacements = hearts - (rottenHearts * 2) 
    player:AddHearts(-rottenReplacements)
    player:AddRottenHearts(rottenReplacements)
    
    local soulHearts = player:GetSoulHearts()
    player:AddSoulHearts(-soulHearts)
    for i=1,soulHearts do
      RottenIsaac.SpawnFriends()
    end
  end
end

function RottenIsaac.ModifyStats(player, cacheFlag)
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER or player:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_FLESH) then
    if cacheFlag == CacheFlag.CACHE_FIREDELAY or cacheFlag == CacheFlag.CACHE_DAMAGE then
      -- Just tears changed
      if string.format("%.2f", player.Damage) == string.format("%.2f", lastCalculatedDamage) and player.MaxFireDelay ~= CADAVER_STATS.STATIC_TEAR_DELAY then
        local lockedRate = 30.0 / (CADAVER_STATS.STATIC_TEAR_DELAY + 1.0)
        local newRate = 30.0 / (player.MaxFireDelay + 1)
        currentMultiplier = newRate / lockedRate
        player.MaxFireDelay = CADAVER_STATS.STATIC_TEAR_DELAY
        lastCalculatedDamage = (lastItemDamage + CADAVER_STATS.DAMAGE_MODIFIER) * currentMultiplier
        player.Damage = lastCalculatedDamage
      end
      
      -- Just damage changed
      if string.format("%.2f", player.Damage) ~= string.format("%.2f", lastCalculatedDamage) and player.MaxFireDelay == CADAVER_STATS.STATIC_TEAR_DELAY then
        lastItemDamage = player.Damage
        lastCalculatedDamage = (player.Damage + CADAVER_STATS.DAMAGE_MODIFIER) * currentMultiplier
        player.Damage = lastCalculatedDamage
      end
      
      -- Damage and tears changed
      if string.format("%.2f", player.Damage) ~= string.format("%.2f", lastCalculatedDamage) and player.MaxFireDelay ~= CADAVER_STATS.STATIC_TEAR_DELAY then
        lastItemDamage = player.Damage
        local lockedRate = 30.0 / (CADAVER_STATS.STATIC_TEAR_DELAY + 1.0)
        local newRate = 30.0 / (player.MaxFireDelay + 1)
        currentMultiplier = newRate / lockedRate
        player.MaxFireDelay = CADAVER_STATS.STATIC_TEAR_DELAY
        lastCalculatedDamage = (player.Damage + CADAVER_STATS.DAMAGE_MODIFIER) * currentMultiplier
        player.Damage = lastCalculatedDamage
      end 
    end
  end
end

function RottenIsaac.Birthright(player)
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
    local entities = Isaac:GetRoomEntities()
    for i, entity in ipairs(entities) do
      if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.BLUE_FLY and entity.SubType == 0 then
        Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, Helper.OneIndexedRandom(CadaverRNG, 5), entity.Position, entity.Velocity, nil)
        entity:Remove()
      end
    end
  end
end

return RottenIsaac