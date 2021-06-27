local Helper = require("Helper")
local CustomSouls = {}

Card.CARD_SOUL_CADAVER = Isaac.GetCardIdByName("SoulOfCadaver")
Card.CARD_SOUL_GOLDEN = Isaac.GetCardIdByName("GoldenSoul")

local SOUL_CARDS = { 
  Card.CARD_SOUL_ISAAC,
  Card.CARD_SOUL_MAGDALENE,
  Card.CARD_SOUL_CAIN,
  Card.CARD_SOUL_JUDAS,
  Card.CARD_SOUL_BLUEBABY,
  Card.CARD_SOUL_EVE,
  Card.CARD_SOUL_SAMSON,
  Card.CARD_SOUL_AZAZEL,
  Card.CARD_SOUL_EDEN,
  Card.CARD_SOUL_LOST,
  Card.CARD_SOUL_LILITH,
  Card.CARD_SOUL_KEEPER,
  Card.CARD_SOUL_APOLLYON,
  Card.CARD_SOUL_FORGOTTEN,
  Card.CARD_SOUL_BETHANY,
  Card.CARD_SOUL_JACOB,
  Card.CARD_SOUL_CADAVER }
  
  local GOLDEN_SOUL_CHANCE = 0.6
  
  function CustomSouls.RemoveLockedSouls(pickup)
    if (pickup.SubType == Card.CARD_SOUL_CADAVER and not CadaverAchievements.SoulOfCadaver) or 
    (pickup.SubType == Card.CARD_SOUL_GOLDEN and not CadaverAchievements.GoldenSoul) then
      pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.RUNE_SHARD)
    end
  end
  
  function CustomSouls.ChangeSprites(pickup)
    if pickup.SubType == Card.CARD_SOUL_CADAVER then
      local sprite = pickup:GetSprite()
      sprite:Load("gfx/items/soul_of_cadaver.anm2", true)
      sprite:Play("Appear")
    end
    if pickup.SubType == Card.CARD_SOUL_GOLDEN then
      local sprite = pickup:GetSprite()
      sprite:Load("gfx/items/golden_soul.anm2", true)
      sprite:Play("Appear")
    end
  end
  
  function CustomSouls.UseGoldenSoul(player)
    local soul = SOUL_CARDS[Helper.OneIndexedRandom(CadaverRNG, #SOUL_CARDS)]
    player:UseCard(soul)
    if CadaverRNG:RandomFloat() < GOLDEN_SOUL_CHANCE then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_SOUL_GOLDEN, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
    end
  end
  
  function CustomSouls.UseCadaverSoul(player)
    for i=1,8 do
      local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
      maggot:AddCharmed(EntityRef(maggot), -1)
    end
    for i=1,8 do
      local leech = Isaac.Spawn(EntityType.ENTITY_SMALL_LEECH, 0, 0, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
      leech:AddCharmed(EntityRef(leech), -1)
    end
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, Helper.RandomNearbyPosition(player), Vector(0,0), nil)
  end
  
  return CustomSouls