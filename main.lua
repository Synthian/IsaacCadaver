local RottenIsaac = include("RottenIsaac")
local json = include("json")
local Cadaver = RegisterMod("Cadaver Standalone", 1)

CadaverRNG = RNG()

-- # POST GAME START #
function Cadaver:StartRun(isContinued)
    RNG():SetSeed(Game():GetSeeds():GetStartSeed(), 0)
    -- Evaluate stats after everything has been setup
    local player = Isaac.GetPlayer(0)
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end
Cadaver:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Cadaver.StartRun)

-- # POST HEART CREATION #
function Cadaver:ModifyHearts(pickup)
    RottenIsaac.ReplaceHearts(pickup)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Cadaver.ModifyHearts, PickupVariant.PICKUP_HEART)

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
    RottenIsaac.ModifyStats(player, cacheFlag)
end
Cadaver:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Cadaver.ModifyStats)
