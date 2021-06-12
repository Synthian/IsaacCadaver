local Achievements = require("Achievements")
local RottenFlesh = require("RottenFlesh")
local Vestments = require("Vestments")
local ForbiddenFruit = require("ForbiddenFruit")
local Probiotics = require("Probiotics")
local RottenIsaac = require("RottenIsaac")
local Halitosis = include("Halitosis")
local TaintedCadaver = include("TaintedCadaver")
local CustomSouls = require("CustomSouls")  
local RottenChest = require("RottenChest")
local ItemPools = require("ItemPools")
local json = require("json")
local Cadaver = RegisterMod("Cadaver", 1)

Achievements.RegisterCallbacks(Cadaver)

CadaverRNG = RNG() -- Used for general RNG, just seeded at the start with the run seed
CadaverItemRNG = RNG() -- Used for seeded RNG, never use without setting the seed right beforehand

-- # POST GAME START #
function Cadaver:StartRun(isContinued)
    CadaverRNG:SetSeed(Game():GetSeeds():GetStartSeed(), 0)

    if Cadaver:HasData() then
        local table = json.decode(Cadaver:LoadData())
        ForbiddenFruit.LoadData(table.ForbiddenFruit)
        Vestments.LoadData(table.Vestments)
        Achievements.LoadData(table.CadaverAchievements)
        ItemPools.LoadData(table.ItemPools)
    else
        Achievements.Reset()
    end

    Vestments.Reset(isContinued)
    ForbiddenFruit.Reset(isContinued)
    ItemPools.Reset(isContinued)
    TaintedCadaver.Reset(isContinued)

    -- Evaluate stats after everything has been setup
    local player = Isaac.GetPlayer(0)
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end
Cadaver:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Cadaver.StartRun)

-- # POST NORMAL CHEST CREATION #
function Cadaver:ModifyPickups(pickup)
    RottenChest.ReplaceChests(pickup)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Cadaver.ModifyPickups, PickupVariant.PICKUP_CHEST)

-- # POST TAROT CARD CREATION #
function Cadaver:ModifyTarotCards(pickup)
    CustomSouls.RemoveLockedSouls(pickup)
    CustomSouls.ChangeSprites(pickup)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Cadaver.ModifyTarotCards, PickupVariant.PICKUP_TAROTCARD)

-- # POST TRINKET CREATION #
function Cadaver:ModifyTrinkets(pickup)
    ItemPools.RemoveLockedTrinkets(pickup)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Cadaver.ModifyTrinkets, PickupVariant.PICKUP_TRINKET)

-- # POST HEART CREATION #
function Cadaver:ModifyHearts(pickup)
    RottenIsaac.ReplaceHearts(pickup)
    TaintedCadaver.ReplaceHearts(pickup)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Cadaver.ModifyHearts, PickupVariant.PICKUP_HEART)

-- # MODIFY COLLECTIBLE DROPS #
function Cadaver:ModifyCollectible(itemPoolType, decrease, seed)
    return ItemPools.GetCollectible(itemPoolType, decrease, seed)
end
Cadaver:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, Cadaver.ModifyCollectible)

-- # EFFECT UPDATES (Every frame) #
function Cadaver:EffectUpdate(player)
    Vestments.UpdateVestmentsEffect(player)
    ForbiddenFruit.UpdateForbiddenFruitEffect(player)
    Probiotics.UpdateProbioticsEffect(player)
    Halitosis.UpdateHalitosisEffect(player)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Cadaver.EffectUpdate)

-- # CADAVER-SPECIFIC EFFECT UPDATES #
function Cadaver:CadaverEffectUpdate(player)
    RottenIsaac.ConvertHealth(player)
    RottenIsaac.Birthright(player)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Cadaver.CadaverEffectUpdate, PlayerType.PLAYER_CADAVER)

-- # TAINTED CADAVER EFFECT UPDATES #
function Cadaver:TaintedCadaverEffectUpdate(player)
    TaintedCadaver.ConvertHealth(player)
    TaintedCadaver.ManageArmy(player)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Cadaver.TaintedCadaverEffectUpdate, PlayerType.PLAYER_TAINTED_CADAVER)

-- # TAINTED CADAVER ARMY DAMAGE #
function Cadaver:TaintedCadaverArmyDamage(entity, amount, flags, source, countdownFrames)
    return TaintedCadaver.SoldierDamage(entity, amount, flags, source, countdownFrames)
end
Cadaver:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Cadaver.TaintedCadaverArmyDamage)

-- # POST LASER INIT #
function Cadaver:PostLaserInit(laser)
    TaintedCadaver:InitSoldierLasers(laser)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_LASER_INIT, Cadaver.PostLaserInit)

-- # POST PLAYER INIT #
function Cadaver:PlayerInit(player)
	if player:GetPlayerType() == PlayerType.PLAYER_CADAVER then
		RottenIsaac.AddCostume(player)
	end

    if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER then
        TaintedCadaver.PlayerInit(player)
    end
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Cadaver.PlayerInit)

-- # STAT UPDATES #
function Cadaver:ModifyStats(player, cacheFlag)
    Probiotics.ModifyStats(player, cacheFlag)
    -- Halitosis.ModifyStats(player, cacheFlag)
    ForbiddenFruit.ModifyStats(player, cacheFlag)
    RottenFlesh.ModifyStats(player, cacheFlag)
    RottenIsaac.ModifyStats(player, cacheFlag)
    TaintedCadaver.ModifyStats(player, cacheFlag)
end
Cadaver:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Cadaver.ModifyStats)

-- # ROOM ENTER #
function Cadaver:EnterRoom()
    Vestments.SwapVestmentsItem()
    RottenChest.RemoveOpenChests()
end
Cadaver:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Cadaver.EnterRoom)

-- # RENDER #
function Cadaver:Render()
    Achievements.DisplaySprites()
end
Cadaver:AddCallback(ModCallbacks.MC_POST_RENDER, Cadaver.Render)

-- # UPDATE #
function Cadaver:Update()
    Achievements.UpdateSprites()
end
Cadaver:AddCallback(ModCallbacks.MC_POST_UPDATE, Cadaver.Update)

-- # GAME EXIT #
function Cadaver:Exit(shouldSave)
    Vestments.Exit()
    local saveData = {
        ForbiddenFruit = ForbiddenFruit.SaveData(),
        Vestments = Vestments.SaveData(),
        CadaverAchievements = Achievements.SaveData(),
        ItemPools = ItemPools.SaveData()
    }
    Cadaver:SaveData(json.encode(saveData))
end
Cadaver:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Cadaver.Exit)

-- ###### SPECIFIC ITEMS ######

-- # GOLDEN SOUL USAGE #
function Cadaver:UseGoldenSoul(card, player, flags)
    CustomSouls.UseGoldenSoul(player)
end
Cadaver:AddCallback(ModCallbacks.MC_USE_CARD, Cadaver.UseGoldenSoul, Card.CARD_SOUL_GOLDEN)

-- # CADAVER SOUL USAGE #
function Cadaver:UseCadaverSoul(card, player, flags)
    CustomSouls.UseCadaverSoul(player)
end
Cadaver:AddCallback(ModCallbacks.MC_USE_CARD, Cadaver.UseCadaverSoul, Card.CARD_SOUL_CADAVER)

-- # FORBIDDEN FRUIT USAGE #
function Cadaver:UseForbiddenFruit()
    return ForbiddenFruit.Use()
end
Cadaver:AddCallback(ModCallbacks.MC_USE_ITEM, Cadaver.UseForbiddenFruit, CollectibleType.COLLECTIBLE_FORBIDDEN_FRUIT)

-- # HALITOSIS USAGE #
function Cadaver:UseHalitosis(collectibleType, RNG, player, useFlags, slot)
    Halitosis.Use(collectibleType, RNG, player, useFlags, slot)
    TaintedCadaver.KillArmy()
end
Cadaver:AddCallback(ModCallbacks.MC_USE_ITEM, Cadaver.UseHalitosis, CollectibleType.COLLECTIBLE_HALITOSIS)

-- # ROTTEN CHEST COLLISION #
function Cadaver:RottenChestCollision(pickup, collider, low)
    RottenChest.OpenChest(pickup, collider, low)
end
Cadaver:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Cadaver.RottenChestCollision, PickupVariant.PICKUP_ROTTENCHEST)

-- # DEBUG COMMANDS #
function Cadaver:OnCommand(command, args)
    if command == "cd_reset" then
        Achievements.Reset()
    elseif command == "cd_unlockall" then
        Achievements.UnlockAll()
    elseif command == "cd_listunlock" then
        Achievements.ReadOut()
    elseif command == "cd_spawn" then
        TaintedCadaver.Spawn(args)
    elseif command == "cd_army" then
        TaintedCadaver.GetArmyStats()
    elseif command == "cd_entities" then
        local entities = Isaac:GetRoomEntities()
        for i, entity in ipairs(entities) do
            print("Type " .. entity.Type .. "Variant " .. entity.Variant .. "SubType " .. entity.SubType)
        end
    end
end
Cadaver:AddCallback(ModCallbacks.MC_EXECUTE_CMD, Cadaver.OnCommand)
