local Achievements = {}

CadaverAchievements = {
  Isaac = false,
  BlueBaby = false,
  Satan = false,
  Lamb = false,
  Hush = false,
  MegaSatan = false,
  Delirium = false,
  Mother = false,
  Beast = false,
  Vestments = false,
  Probiotics = false,
  SoulOfCadaver = false,
  RottenChests = false,
  RottenFlesh = false,
  ForbiddenFruit = false,
  GoldenSoul = false
}

local MAX_ACHIEVEMENT_FRAMES = 240

local achievementFrames = 0
local achievementSprite = Sprite()
achievementSprite:Load("gfx/ui/achievement/achievements.anm2", true)

function Achievements.LoadData(table)
    if table == nil then
        Achievements.Reset()
    else
        CadaverAchievements = table
    end
end

function Achievements.UnlockAll()
    for k, v in pairs(CadaverAchievements) do
        CadaverAchievements[k] = true
    end
end

function Achievements.ReadOut()
    local unlocks = ""
    for k, v in pairs(CadaverAchievements) do
        if CadaverAchievements[k] then
            unlocks = unlocks .. k .. " "
        end
    end
    print(unlocks)
end

function Achievements.Reset()
    for k, v in pairs(CadaverAchievements) do
        CadaverAchievements[k] = false
    end
end

function Achievements.SaveData()
    return CadaverAchievements
end

function Achievements.DisplayAchievement()
    achievementSprite:LoadGraphics()
    achievementSprite:Play("Appear", true)
    achievementFrames = MAX_ACHIEVEMENT_FRAMES
end

function Achievements.TryUnlock()
    if CadaverAchievements.Isaac and CadaverAchievements.BlueBaby and not CadaverAchievements.Vestments then
        CadaverAchievements.Vestments = true
        achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_vestments.png")
        Achievements.DisplayAchievement()
    elseif CadaverAchievements.Satan and CadaverAchievements.Lamb and not CadaverAchievements.Probiotics then
        CadaverAchievements.Probiotics = true
        achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_probiotics.png")
        Achievements.DisplayAchievement()
    elseif CadaverAchievements.Hush and not CadaverAchievements.SoulOfCadaver then
        CadaverAchievements.SoulOfCadaver = true
        achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_soul_of_cadaver.png")
        Achievements.DisplayAchievement()
    elseif CadaverAchievements.MegaSatan and not CadaverAchievements.RottenChest then
        CadaverAchievements.RottenChest = true
        achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_rotten_chest.png")
        Achievements.DisplayAchievement()
    elseif CadaverAchievements.Delirium and not CadaverAchievements.RottenFlesh then
        CadaverAchievements.RottenFlesh = true
        achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_rotten_flesh.png")
        Achievements.DisplayAchievement()
    elseif CadaverAchievements.Mother and not CadaverAchievements.ForbiddenFruit then
        CadaverAchievements.ForbiddenFruit = true
        achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_forbidden_fruit.png")
        Achievements.DisplayAchievement()
    elseif CadaverAchievements.Beast and not CadaverAchievements.GoldenSoul then
        CadaverAchievements.GoldenSoul = true
        achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_golden_soul.png")
        Achievements.DisplayAchievement()
    end
end

function Achievements:IsaacAchievement(npc)
    local player = Isaac.GetPlayer(0)
    local stage = Game():GetLevel():GetStage()
    if player:GetName() == "Cadaver" then
        if npc.Variant == 0 and stage == LevelStage.STAGE5 and not CadaverAchievements.Isaac then
            CadaverAchievements.Isaac = true
            Achievements.TryUnlock()
        end
        
        if npc.Variant == 1 and stage == LevelStage.STAGE6 and not CadaverAchievements.BlueBaby then
            CadaverAchievements.BlueBaby = true
            Achievements.TryUnlock()
        end
    end
end

function Achievements:SatanAchievement(npc)
    local stage = Game():GetLevel():GetStage()
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Cadaver" and stage == LevelStage.STAGE5 and not CadaverAchievements.Satan then
        CadaverAchievements.Satan = true
        Achievements.TryUnlock()
    end
end

function Achievements:LambAchievement(npc)
    local stage = Game():GetLevel():GetStage()
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Cadaver" and stage == LevelStage.STAGE6 and not CadaverAchievements.Lamb then
        CadaverAchievements.Lamb = true
        Achievements.TryUnlock()
    end
end

function Achievements:HushAchievement(npc)
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Cadaver" and not CadaverAchievements.Hush then
        CadaverAchievements.Hush = true
        Achievements.TryUnlock()
    end
end

function Achievements:MegaSatanAchievement(npc)
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Cadaver" and not CadaverAchievements.MegaSatan then
        CadaverAchievements.MegaSatan = true
        Achievements.TryUnlock()
    end
end

function Achievements:DeliriumAchievement(npc)
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Cadaver" and not CadaverAchievements.Delirium  then
        CadaverAchievements.Delirium = true
        Achievements.TryUnlock()
    end
end

function Achievements:MotherAchievement(npc)
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Cadaver"  and not CadaverAchievements.Mother then
        CadaverAchievements.Mother = true
        Achievements.TryUnlock()
    end
end

function Achievements:BeastAchievement(npc)
    local player = Isaac.GetPlayer(0)
    if player:GetName() == "Cadaver" and npc.Variant == 0 and not CadaverAchievements.Beast then
        CadaverAchievements.Beast = true
        Achievements.TryUnlock()
    end
end

function Achievements.RegisterCallbacks(mod)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.IsaacAchievement, EntityType.ENTITY_ISAAC)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.SatanAchievement, EntityType.ENTITY_SATAN)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.LambAchievement, EntityType.ENTITY_THE_LAMB)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.HushAchievement, EntityType.ENTITY_HUSH)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.MotherAchievement, EntityType.ENTITY_MOTHER)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.BeastAchievement, EntityType.ENTITY_BEAST)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.DeliriumAchievement, EntityType.ENTITY_DELIRIUM)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.MegaSatanAchievement, EntityType.ENTITY_MEGA_SATAN_2)
end

function Achievements.DisplaySprites()
    if achievementFrames > 0 or achievementSprite:IsPlaying("Disappear") then
        achievementSprite:Render(Isaac.WorldToRenderPosition(Vector(320, 300)))
        achievementFrames = achievementFrames - 1
        if achievementFrames == 0 then
            achievementSprite:Play("Disappear")
        end
    end
end

function Achievements.UpdateSprites()
    achievementSprite:Update()
end

return Achievements
