flea_3_modifier_attack = class({})

function flea_3_modifier_attack:IsHidden()
	return true
end

function flea_3_modifier_attack:IsPurgable()
	return false
end

function flea_3_modifier_attack:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_3_modifier_attack:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local agi_mult = self.ability:GetSpecialValueFor("agi_mult")

	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then
		self.damage = base_stats:GetStatTotal("AGI") * agi_mult
	else
		self.damage = 0
	end
end

function flea_3_modifier_attack:OnRefresh(kv)
end

function flea_3_modifier_attack:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_3_modifier_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_3_modifier_attack:GetModifierPreAttack_BonusDamage(keys)
	if IsServer() then
		return self.damage - 40
	end
end

function flea_3_modifier_attack:OnAttackLanded(keys)
	if IsServer() then
		if keys.attacker ~= self.parent then return end
		local silence_duration = self.ability:GetSpecialValueFor("silence_duration")

		if keys.target:IsAlive() then
			keys.target:AddNewModifier(self.caster, self.ability, "_modifier_silence", {
				duration = self.ability:CalcStatus(silence_duration, self.caster, keys.target),
				special = 3
			})
		end

		self:PlayEfxHit(keys.target)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_3_modifier_attack:PlayEfxHit(target)
	local string = "particles/units/heroes/hero_riki/riki_backstab.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then target:EmitSound("Hero_Riki.Backstab") end
end