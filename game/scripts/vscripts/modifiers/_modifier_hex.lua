_modifier_hex = class({})

--------------------------------------------------------------------------------
function _modifier_hex:IsPurgable()
	return true
end

function _modifier_hex:IsHidden()
	return false
end

function _modifier_hex:GetTexture()
	return "_modifier_hex"
end

function _modifier_hex:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_hex:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if self.parent:IsIllusion() then
    self.parent:Kill(self.ability, self.caster)
    return
  end

	local effects = {
    [1] = {model = "models/props_gameplay/pig.vmdl", sound = "Item.PigPole.Target", pfx = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"},
    [2] = {model = "models/props_gameplay/pig.vmdl", sound = "Item.PigPole.Target", pfx = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"},
    [3] = {model = "models/props_gameplay/frog.vmdl", sound = "Hero_Lion.Hex.Target", pfx = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"},
    [4] = {model = "models/props_gameplay/cold_frog.vmdl", sound = "Hero_Lion.Hex.Target", pfx = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"},
    [5] = {model = "models/props_gameplay/chicken.vmdl", sound = "Hero_ShadowShaman.Hex.Target", pfx = "particles/units/heroes/hero_shadowshaman/shadowshaman_voodoo.vpcf"},
    [6] = {model = "models/props_gameplay/chicken.vmdl", sound = "Hero_ShadowShaman.Hex.Target", pfx = "particles/units/heroes/hero_shadowshaman/shadowshaman_voodoo.vpcf"},
    [7] = {model = "models/items/hex/sheep_hex/sheep_hex.vmdl", sound = "Hero_ShadowShaman.SheepHex.Target", pfx = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"},
    [8] = {model = "models/items/hex/sheep_hex/sheep_hex_gold.vmdl", sound = "Hero_ShadowShaman.SheepHex.Target", pfx = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"},
  }

  self.effect = effects[kv.effect or RandomInt(1, #effects)]

  if IsServer() then self:PlayEfxStart(true) end
end

function _modifier_hex:OnRefresh(kv)
end

function _modifier_hex:OnDestroy()
  if IsServer() then self:PlayEfxStart(false) end
end

--------------------------------------------------------------------------------

function _modifier_hex:CheckState()
	local state = {
		[MODIFIER_STATE_HEXED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_MUTED] = true
	}

	return state
end

function _modifier_hex:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}

	return funcs
end

function _modifier_hex:GetModifierMoveSpeed_Limit()
	return 175
end

function _modifier_hex:GetModifierModelChange()
	return self.effect.model
end

--------------------------------------------------------------------------------

function _modifier_hex:PlayEfxStart(bStart)
  local particle_cast = self.effect.pfx
  self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)

  local cosmetics = self.parent:FindAbilityByName("cosmetics")
  if cosmetics then
    for i = 1, #cosmetics.cosmetic, 1 do
      cosmetics:HideCosmetic(cosmetics.cosmetic[i]:GetModelName(), bStart)
    end
  end

  if IsServer() then
    if bStart then
      self.parent:EmitSound(self.effect.sound)
      self.parent:EmitSound("Hero_Lion.Voodoo")
    else
      if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
      if self.parent:IsHexed() == false then
        self.parent:EmitSound("Generic.Hex.Out")
        self.parent:StopSound("Item.PigPole.Target")
        self.parent:StopSound("Hero_ShadowShaman.SheepHex.Target")
      end
    end
  end
end