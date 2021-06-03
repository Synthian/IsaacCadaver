local Achievements = include("Achievements")
local RottenFlesh = include("RottenFlesh")
local Vestments = include("Vestments")
local ForbiddenFruit = include("ForbiddenFruit")
local Probiotics = include("Probiotics")
local RottenIsaac = include("RottenIsaac")
local CustomSouls = include("CustomSouls")  
local RottenChest = include("RottenChest")
local ItemPools = include("ItemPools")
local json = include("json")                                                                                         
local Cadaver = RegisterMod("Cadaver", 1)

Achievements.RegisterCallbacks(Cadaver)

CadaverRNG = RNG()

-- # POST GAME START #
function Cadaver:StartRun(isContinued)
    RNG():SetSeed(Game():GetSeeds():GetStartSeed(), 0)

    if Cadaver:HasData() then
        local table = json.decode(Cadaver:LoadData())
        ForbiddenFruit.LoadData(table.ForbiddenFruit)
        Vestments.LoadData(table.Vestments)
        Achievements.LoadData(table.CadaverAchievements)
        ItemPools.LoadData(table.ItemPools)
    else
        Achievements.Reset()
    end

    RottenIsaac.Reset(isContinued)
    Vestments.Reset(isContinued)
    ForbiddenFruit.Reset(isContinued)
    ItemPools.Reset(isContinued)

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

-- # POST HEART CREATION #
function Cadaver:ModifyHearts(pickup)
    RottenIsaac.ReplaceHearts(pickup)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Cadaver.ModifyHearts, PickupVariant.PICKUP_HEART)

-- # MODIFY TRINKET DROPS #
function Cadaver:ModifyTrinket(selectedTrinket, RNG)
    return ItemPools.GetTrinket(selectedTrinket, RNG)
end
Cadaver:AddCallback(ModCallbacks.MC_GET_TRINKET, Cadaver.ModifyTrinket)

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
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Cadaver.EffectUpdate)

-- # CADAVER-SPECIFIC EFFECT UPDATES #
function Cadaver:CadaverEffectUpdate(player)
    RottenIsaac.ConvertHealth(player)
    RottenIsaac.Birthright(player)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Cadaver.CadaverEffectUpdate, PlayerType.PLAYER_CADAVER)

-- # POST PLAYER INIT #
function Cadaver:PlayerInit(player)
	if player:GetName() == "Cadaver" then
		RottenIsaac.AddCostume(player)
	end
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Cadaver.PlayerInit)

-- # STAT UPDATES #
function Cadaver:ModifyStats(player, cacheFlag)
    Probiotics.ModifyStats(player, cacheFlag)
    ForbiddenFruit.ModifyStats(player, cacheFlag)
    RottenFlesh.ModifyStats(player, cacheFlag)
    RottenIsaac.ModifyStats(player, cacheFlag)
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
function Cadaver:UseItem()
    return ForbiddenFruit.Use()
end
Cadaver:AddCallback(ModCallbacks.MC_USE_ITEM, Cadaver.UseItem, CollectibleType.COLLECTIBLE_FORBIDDEN_FRUIT)

-- # ROTTEN CHEST COLLISION #
function Cadaver:RottenChestCollision(pickup, collider, low)
    RottenChest.OpenChest(pickup, collider, low)
end
Cadaver:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Cadaver.RottenChestCollision, PickupVariant.PICKUP_ROTTENCHEST)

-- # DEBUG COMMANDS #
function Cadaver:OnCommand(command, args)
    if command == "resetcadaver" then
        Achievements.Reset()
    elseif command == "unlockcadaver" then
        Achievements.UnlockAll()
    elseif command == "achievecadaver" then
        Achievements.ReadOut()
    end
end
Cadaver:AddCallback(ModCallbacks.MC_EXECUTE_CMD, Cadaver.OnCommand)
