bloodstained_4_modifier_frenzy = class({})

function bloodstained_4_modifier_frenzy:IsHidden()
	return false
end

function bloodstained_4_modifier_frenzy:IsPurgable()
	return true
end

function bloodstained_4_modifier_frenzy:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_4_modifier_frenzy:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.unslow = false
	self.min_health = 0

	local agi = self.ability:GetSpecialValueFor("agi")
	local ms = self.ability:GetSpecialValueFor("ms")

	-- UP 4.11
	if self.ability:GetRank(11) then
		self.unslow = true
		ms = ms + 25
	end

	-- UP 4.31
	if self.ability:GetRank(31) then
		self.min_health = 1
	end

	-- UP 4.41
	if self.ability:GetRank(41) then
		agi = agi + 10
	end

	self.parent:SetForceAttackTarget(self.ability.target)
	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = ms})

	if IsServer() then
		self:PlayEfxStart()
		self:OnIntervalThink()
	end
end

function bloodstained_4_modifier_frenzy:OnRefresh(kv)
end

function bloodstained_4_modifier_frenzy:OnRemoved()
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.parent:SetForceAttackTarget(nil)
	self.ability:RemoveBonus("_1_AGI", self.parent)

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_4_modifier_frenzy:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	if self.unslow == true then
		state = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_UNSLOWABLE] = true
		}
	end

	return state
end

function bloodstained_4_modifier_frenzy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bloodstained_4_modifier_frenzy:GetModifierStatusResistance()
	if self:GetAbility():GetCurrentAbilityCharges() % 2 ==0 then
		return 75
	end
end

function bloodstained_4_modifier_frenzy:GetMinHealth()
	return self.min_health
end

function bloodstained_4_modifier_frenzy:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:GetTeamNumber() == keys.target:GetTeamNumber() then return end

	-- UP 4.41
	if self.ability:GetRank(41)
	and RandomFloat(1, 100) <= 15 then
		keys.target:AddNewModifier(self.caster, self.ability, "bloodstained__modifier_bleeding", {
			duration = self.ability:CalcStatus(10, self.caster, keys.target)
		})
	end
end

function bloodstained_4_modifier_frenzy:OnIntervalThink()
	if self.ability.target:IsAlive() == false then self:Destroy() end
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_4_modifier_frenzy:GetEffectName()
	return "particles/bloodstained/frenzy/bloodstained_hands_v2.vpcf"
end

function bloodstained_4_modifier_frenzy:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function bloodstained_4_modifier_frenzy:PlayEfxStart()
	local particle_cast = "particles/bloodstained/frenzy/bloodstained_frenzy.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(
		effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", self.parent:GetOrigin(), true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_attack2", self.parent:GetOrigin(), true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true
	)
	self:AddParticle(effect_cast, false, false, -1, false, true)

	local particle_cast_2 = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
	local effect = ParticleManager:CreateParticle(particle_cast_2, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(500, 0, 0))

	if IsServer() then self.parent:EmitSound("Hero_ShadowDemon.DemonicPurge.Damage") end
end