local ItemPools = {}

local spawnHistory = {
  Vestments = false,
  ForbiddenFruit = false,
  RottenFlesh = false,
  Probiotics = false,
  Halitosis = false,
  TechDrones = false,
  MorgueKey = false,
  HydrochloricAcid = false
}

function ItemPools.LoadData(table)
  if table ~= nil then
    spawnHistory = table
  end
end

function ItemPools.SaveData()
  return spawnHistory
end

function ItemPools.Reset(isContinued)
  if not isContinued then
    for k, v in pairs(spawnHistory) do
      spawnHistory[k] = false
    end
  end
end

function ItemPools.RemoveLockedTrinkets(pickup)
  if pickup.SubType == TrinketType.TRINKET_PROBIOTICS and not CadaverAchievements.Probiotics then
    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_NULL)
  end
end

function ItemPools.GetCollectible(itemPoolType, decrease, seed)
  CadaverItemRNG:SetSeed(seed, 0)
  local r = CadaverItemRNG:RandomFloat()
  if itemPoolType == ItemPoolType.POOL_TREASURE and not spawnHistory.RottenFlesh and CadaverAchievements.RottenFlesh and r < 0.01 and r >= 0.0075 then
    spawnHistory.RottenFlesh = true
    return CollectibleType.COLLECTIBLE_ROTTEN_FLESH
  elseif itemPoolType == ItemPoolType.POOL_TREASURE and not spawnHistory.Halitosis and CadaverAchievements.Halitosis and r < 0.0075 and r >= 0.005 then
    spawnHistory.Halitosis = true
    return CollectibleType.COLLECTIBLE_HALITOSIS
  elseif itemPoolType == ItemPoolType.POOL_TREASURE and not spawnHistory.TechDrones and CadaverAchievements.TechDrones and r < 0.005 and r >= 0.0025 then
    spawnHistory.TechDrones = true
    return CollectibleType.COLLECTIBLE_TECH_DRONES
  elseif itemPoolType == ItemPoolType.POOL_TREASURE and not spawnHistory.HydrochloricAcid and CadaverAchievements.HydrochloricAcid and r < 0.0025 then
    spawnHistory.HydrochloricAcid = true
    return CollectibleType.COLLECTIBLE_HYDROCHLORIC_ACID
  elseif itemPoolType == ItemPoolType.POOL_ANGEL and not spawnHistory.Vestments and CadaverAchievements.Vestments and r < 0.02 then
    spawnHistory.Vestments = true
    return CollectibleType.COLLECTIBLE_VESTMENTS
  elseif itemPoolType == ItemPoolType.POOL_DEVIL and not spawnHistory.ForbiddenFruit and CadaverAchievements.ForbiddenFruit and r < 0.01 then
    spawnHistory.ForbiddenFruit = true
    return CollectibleType.COLLECTIBLE_FORBIDDEN_FRUIT
  elseif itemPoolType == ItemPoolType.POOL_SECRET and not spawnHistory.MorgueKey and CadaverAchievements.MorgueKey and r < 0.02 then
    spawnHistory.MorgueKey = true
    return CollectibleType.COLLECTIBLE_MORGUE_KEY
  end
  return nil
end

return ItemPools