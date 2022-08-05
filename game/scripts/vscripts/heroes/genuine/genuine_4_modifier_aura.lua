genuine_4_modifier_aura = class({})

function genuine_4_modifier_aura:IsHidden()
	return true
end

function genuine_4_modifier_aura:IsPurgable()
	return false
end

-- AURA -----------------------------------------------------------

function genuine_4_modifier_aura:IsAura()
	if self:GetParent():PassivesDisabled() then return false end
	return true
end

function genuine_4_modifier_aura:GetModifierAura()
	return "genuine_4_modifier_aura_effect"
end

function genuine_4_modifier_aura:GetAuraRadius()
	return self:GetAbility():GetCastRange(nil, nil)
end

function genuine_4_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function genuine_4_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.fly_vision = false

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

function genuine_4_modifier_aura:OnRefresh(kv)
	-- UP 4.31
	if self.ability:GetRank(31) then
		self.fly_vision = true
	end
end

function genuine_4_modifier_aura:OnRemoved(kv)
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_4_modifier_aura:CheckState()
	local state = {}

	if self.fly_vision == true then
		state = {
			[MODIFIER_STATE_FORCED_FLYING_VISION] = GameRules:IsDaytime() == false
		}
	end

	return state
end

function genuine_4_modifier_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION_UNIQUE,
		MODIFIER_PROPERTY_ABSORB_SPELL
	}

	return funcs
end

function genuine_4_modifier_aura:GetBonusNightVisionUnique()
	return self:GetAbility():GetSpecialValueFor("bonus_vision")
end

function genuine_4_modifier_aura:GetAbsorbSpell(keys)
	local chance = 15
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	-- UP 4.21
	if self.ability:GetRank(21)
	and GameRules:IsDaytime() == false
	and RandomFloat(1, 100) <= chance
	and self.parent:PassivesDisabled() == false then
		self:PlayEfxBlockSpell()
		return 1
	end
end

function genuine_4_modifier_aura:OnIntervalThink()
	-- UP 4.11
	if self.ability:GetRank(11) then
		self:CheckInviMode()
	end

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

function genuine_4_modifier_aura:CheckInviMode()
	local charges = 1

	if GameRules:IsDaytime() then
		self.ability.invi = false

		local mod = self.parent:FindAllModifiersByName("_modifier_invisible")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then modifier:Destroy() end
		end
	else
		if self.ability.invi == false then
			charges = 2
		end
	end

	self.ability:SetCurrentAbilityCharges(charges)
end

-- EFFECTS -----------------------------------------------------------

function genuine_4_modifier_aura:GetEffectName()
	return "particles/econ/events/diretide_2020/emblem/fall20_emblem_v2_effect.vpcf"
end

function genuine_4_modifier_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function genuine_4_modifier_aura:PlayEfxBlockSpell()
	local string = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("Item.LotusOrb.Target") end
end