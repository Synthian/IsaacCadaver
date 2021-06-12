local Halitosis = {}

CollectibleType.COLLECTIBLE_HALITOSIS = Isaac.GetItemIdByName("Halitosis")
-- Custom sounds are currently bugged in Repentance. Will activate this sfx when it's fixed
SoundEffect.HALITOSIS = Isaac.GetSoundIdByName("HalitosisVocal")

local MAX_DURATION = 30
local currentDuration = 0

function Halitosis.Use(collectibleType, RNG, player, useFlags, slot)
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
    currentDuration = MAX_DURATION * 2
  else
    currentDuration = MAX_DURATION
  end
  SFXManager():Play(SoundEffect.SOUND_BEAST_FIRE_BARF, 1, 2, false, 1, 0)
end

local AIM_VECTORS = {}
AIM_VECTORS[Direction.LEFT] = Vector(-1, 0)
AIM_VECTORS[Direction.UP] = Vector(0, -1)
AIM_VECTORS[Direction.RIGHT] = Vector(1, 0)
AIM_VECTORS[Direction.DOWN] = Vector(0, 1)

function Halitosis.UpdateHalitosisEffect(player)
  if currentDuration > 0 then
    player.FireDelay = player.MaxFireDelay
    currentDuration = currentDuration - 1

    if currentDuration % 5 == 0 then
      local aimDirection = Vector(0,0)
      
      local tear = player:FireTear(player.Position + (AIM_VECTORS[player:GetHeadDirection()] * 10), AIM_VECTORS[player:GetHeadDirection()] * 10, false, true, false, player, 2)
      tear.TearFlags = tear.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING | TearFlags.TEAR_POISON | TearFlags.TEAR_FEAR
      tear.SizeMulti = Vector(3, 3)
      tear.SpriteScale = Vector(0.3, 0.3)
      local sprite = tear:GetSprite()
      sprite:Load("gfx/halitosis_tear.anm2", true)
      
      if player:GetHeadDirection() == Direction.LEFT then
        sprite.FlipX = true
        sprite:Play("MoveHori")
      elseif player:GetHeadDirection() == Direction.UP then
        sprite.FlipY = true
        sprite:Play("MoveVert")
      elseif player:GetHeadDirection() == Direction.DOWN then
        sprite:Play("MoveVert")
      elseif player:GetHeadDirection() == Direction.RIGHT then
        sprite:Play("MoveHori")
      end
    end
  end
end

return Halitosis