bloodstained_2_modifier_passive = class({})

function bloodstained_2_modifier_passive:IsHidden() return false end
function bloodstained_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_2_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:OnIntervalThink() end
end

function bloodstained_2_modifier_passive:OnRefresh(kv)
end

function bloodstained_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_2_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function bloodstained_2_modifier_passive:GetModifierHealAmplify_PercentageTarget()
	if self:GetParent():PassivesDisabled() then return 0 end
	return self:GetAbility():GetSpecialValueFor("heal_power")
end

function bloodstained_2_modifier_passive:OnDeath(keys)
	if (keys.unit:GetOrigin() - self.parent:GetOrigin()):Length2D() > self.ability:GetAOERadius() then return end
	if keys.unit:GetTeamNumber() == self.caster:GetTeamNumber() then return end
	if keys.unit:IsIllusion() then return end

	local heal = self.ability:GetSpecialValueFor("special_kill_heal") * keys.unit:GetLevel()
	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then heal = heal * base_stats:GetHealPower() end

	if heal > 0 then
		self.parent:Heal(heal, self.parent)
		self:PlayEfxDeathHeal(keys.unit)
	end
end

function bloodstained_2_modifier_passive:OnHealReceived(keys)
	if keys.unit ~= self.parent then return end
	if keys.inflictor ~= self.ability then return end
	self:ApplyExtraLife(math.floor(keys.gain))
end

function bloodstained_2_modifier_passive:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end
	if self.parent:GetTeamNumber() == keys.target:GetTeamNumber() then return end

	local heal = keys.original_damage * self:GetLifestealPercent() * 0.01
	self.parent:Heal(heal, self.ability)
	self:PlayEfxLifesteal(keys.target)
end

function bloodstained_2_modifier_passive:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(math.floor(self:GetLifestealPercent()))
		self:StartIntervalThink(FrameTime())
	end
end

-- UTILS -----------------------------------------------------------

function bloodstained_2_modifier_passive:ApplyExtraLife(extra_life)
	if self.parent:GetHealth() < self.parent:GetBaseMaxHealth() * 0.9 then return end
	if extra_life < 1 then return end

	local cap = self.ability:GetSpecialValueFor("special_cap")

	local mod = self.parent:FindAllModifiersByName("bloodstained__modifier_extra_hp")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then
			modifier:SetStackCount(extra_life + modifier:GetStackCount())
			return
		end
	end

	if cap > 0 then
		self.parent:AddNewModifier(self.caster, self.ability, "bloodstained__modifier_extra_hp", {
			extra_life = extra_life, cap = cap
		})
	end
end

function bloodstained_2_modifier_passive:GetLifestealPercent()
	local base_heal = self.ability:GetSpecialValueFor("base_heal")
	local bonus_heal = self.ability:GetSpecialValueFor("bonus_heal")
	local deficit_percent =  1 - (self.parent:GetHealth() / self.parent:GetMaxHealth())

	return (bonus_heal * deficit_percent) + base_heal
end

-- EFFECTS -----------------------------------------------------------

function bloodstained_2_modifier_passive:GetEffectName()
	return "particles/bioshadow/bioshadow_drain.vpcf"
end

function bloodstained_2_modifier_passive:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bloodstained_2_modifier_passive:PlayEfxLifesteal(target)
	local particle_cast = "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)

	local particle_cast2 = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf"
    local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:ReleaseParticleIndex(effect_cast2)

	if IsServer() then self.parent:EmitSound("Bloodstained.Lifesteal") end
end

function bloodstained_2_modifier_passive:PlayEfxDeathHeal(target)
	local particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)

	local particle_cast2 = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf"
	local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast2, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast2, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast2)
end