local ItemPools = {}

local spawnHistory = {
    Vestments = false,
    ForbiddenFruit = false,
    RottenFlesh = false,
    Probiotics = false
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
    if itemPoolType == ItemPoolType.POOL_TREASURE and not spawnHistory.RottenFlesh and CadaverAchievements.RottenFlesh and CadaverRNG:RandomFloat() < 0.003 then
        spawnHistory.RottenFlesh = true
        return CollectibleType.COLLECTIBLE_ROTTEN_FLESH
    elseif itemPoolType == ItemPoolType.POOL_ANGEL and not spawnHistory.Vestments and CadaverAchievements.Vestments and CadaverRNG:RandomFloat() < 0.02 then
        spawnHistory.Vestments = true
        return CollectibleType.COLLECTIBLE_VESTMENTS
    elseif itemPoolType == ItemPoolType.POOL_DEVIL and not spawnHistory.ForbiddenFruit and CadaverAchievements.ForbiddenFruit and CadaverRNG:RandomFloat() < 0.01 then
        spawnHistory.ForbiddenFruit = true
        return CollectibleType.COLLECTIBLE_FORBIDDEN_FRUIT
    end
    return nil
end

return ItemPools