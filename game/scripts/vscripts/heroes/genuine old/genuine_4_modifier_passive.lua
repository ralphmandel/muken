genuine_4_modifier_passive = class({})

function genuine_4_modifier_passive:IsHidden()
	return true
end

function genuine_4_modifier_passive:IsPurgable()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
	self.night = false

	self.bonus_vision = self.ability:GetSpecialValueFor("bonus_vision")

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

function genuine_4_modifier_passive:OnRefresh(kv)
end

function genuine_4_modifier_passive:OnRemoved(kv)
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_4_modifier_passive:CheckState()
	local state = {
		[MODIFIER_STATE_FORCED_FLYING_VISION] = GameRules:IsDaytime() == false
	}

	return state
end

function genuine_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION_UNIQUE,
		MODIFIER_EVENT_ON_ABILITY_START,
		MODIFIER_PROPERTY_ABSORB_SPELL
	}

	return funcs
end

function genuine_4_modifier_passive:GetBonusNightVisionUnique()
	if self.ability:GetCurrentAbilityCharges() % 3 == 0 then
		return self.bonus_vision + 250
	end

	return self.bonus_vision
end

function genuine_4_modifier_passive:OnAbilityStart(keys)
	if self.parent:GetTeamNumber() == keys.unit:GetTeamNumber() then return end
	local distance = CalcDistanceBetweenEntityOBB(self.parent, keys.unit)
	if distance > 1000 then return end
	if GameRules:IsDaytime() then return end

	-- UP 4.32
	if self.ability:GetRank(32) then
		self.ability:CreateStarfall(keys.unit)
	end
end

function genuine_4_modifier_passive:GetAbsorbSpell(keys)
	-- UP 4.21
	if self.ability:GetRank(21)
	and GameRules:IsDaytime() == false
	and RandomFloat(1, 100) <= 20
	and self.parent:PassivesDisabled() == false then
		self:PlayEfxBlockSpell()
		return 1
	end
end

function genuine_4_modifier_passive:OnIntervalThink()
	self:CheckNightMode()

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

function genuine_4_modifier_passive:CheckNightMode()
	local charges = 1

	if GameRules:IsDaytime() then
		self.night = false
		self.ability.invi = false

		RemoveBonus(self.ability, "_2_DEX", self.parent)

		local mod = self.parent:FindAllModifiersByName("_modifier_invisible")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then modifier:Destroy() end
		end
	else
		-- UP 4.11
		if self.ability:GetRank(11)
		and self.ability.invi == false then
			charges = 2
		end

		-- UP 4.12
		if self.ability:GetRank(12) and self.night == false then
			RemoveBonus(self.ability, "_2_DEX", self.parent)
			AddBonus(self.ability, "_2_DEX", self.parent, 10, 0, nil)
			self.night = true
		end
	end

	-- UP 4.31
	if self.ability:GetRank(31) then
		charges = charges * 3
	end

	self.ability:SetCurrentAbilityCharges(charges)
end

-- EFFECTS -----------------------------------------------------------

function genuine_4_modifier_passive:GetEffectName()
	return "particles/econ/events/diretide_2020/emblem/fall20_emblem_v2_effect.vpcf"
end

function genuine_4_modifier_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function genuine_4_modifier_passive:PlayEfxBlockSpell()
	local string = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("Item.LotusOrb.Target") end
end