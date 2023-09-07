genuine_4_modifier_aura_effect = class({})

function genuine_4_modifier_aura_effect:IsHidden() return false end
function genuine_4_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function genuine_4_modifier_aura_effect:OnRefresh(kv)
end

function genuine_4_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_4_modifier_aura_effect:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_PROPERTY_ABSORB_SPELL
	}
	
	return funcs
end

function genuine_4_modifier_aura_effect:GetModifierAvoidDamage(keys)
  return self:IsAvoided()
end

function genuine_4_modifier_aura_effect:GetAbsorbSpell(keys)
  return self:IsAvoided()
end

-- UTILS -----------------------------------------------------------

function genuine_4_modifier_aura_effect:IsAvoided()
  if GameRules:IsDaytime() and GameRules:IsTemporaryNight() == false then return 0 end

  if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("chance") then
    if IsServer() then self:PlayEfxSpellBlock() end
    return 1
  end

  return 0
end

-- EFFECTS -----------------------------------------------------------

function genuine_4_modifier_aura_effect:PlayEfxSpellBlock()
	local particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("DOTA_Item.LinkensSphere.Activate") end
end