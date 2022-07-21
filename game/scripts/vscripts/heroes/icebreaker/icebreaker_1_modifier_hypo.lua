icebreaker_1_modifier_hypo = class({})

function icebreaker_1_modifier_hypo:IsHidden()
	return false
end

function icebreaker_1_modifier_hypo:IsPurgable()
    return true
end

function icebreaker_1_modifier_hypo:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_1_modifier_hypo:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.slow_ms = self.ability:GetSpecialValueFor("slow_ms")
	self.slow_as = self.ability:GetSpecialValueFor("slow_as")
	self.frozen_duration = self.ability:GetSpecialValueFor("frozen_duration")
	self.max_stack = self.ability:GetSpecialValueFor("max_stack")

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "icebreaker_1_modifier_hypo_status_efx", true) end

	if IsServer() then
		self:SetStackCount(0)

		-- UP 1.41
	    if self.ability:GetRank(41) then
			self:EnablePureDamageThinker(1.2)
        end
	end
end

function icebreaker_1_modifier_hypo:OnRefresh(kv)
end

function icebreaker_1_modifier_hypo:OnRemoved(kv)
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "icebreaker_1_modifier_hypo_status_efx", false) end

	self:ModifySlow(0)
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_1_modifier_hypo:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function icebreaker_1_modifier_hypo:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():IsCreep() then return -self:GetStackCount() * 10 end
end

function icebreaker_1_modifier_hypo:OnIntervalThink()
	self.damageTable.damage = self.parent:GetMaxHealth() * self.damage_mult
	if self.parent:GetUnitName() == "boss_gorillaz" then self.damageTable.damage = self.damageTable.damage * 0.5 end
	ApplyDamage(self.damageTable)
end

function icebreaker_1_modifier_hypo:OnStackCountChanged(old)
	if self:GetStackCount() >= self.max_stack then
		self.parent:AddNewModifier(self.caster, self.ability, "icebreaker_1_modifier_frozen", {
			duration = self.ability:CalcStatus(self.frozen_duration, self.caster, self.parent)
		})
		return
	end

	if self:GetStackCount() ~= old then
		self:ModifySlow(self:GetStackCount())
	end
end

-- UTILS -----------------------------------------------------------

function icebreaker_1_modifier_hypo:ModifySlow(stack_count)
	if self.pidx then ParticleManager:DestroyParticle(self.pidx, false) end
	
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then base_stats:SetBaseAttackTime(stack_count * self.slow_as) end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	self:CheckCounterEfx()

	if stack_count > 0 then
		self:PopupIce(false)
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
			percent = stack_count * self.slow_ms
		})
	end
end

function icebreaker_1_modifier_hypo:EnablePureDamageThinker(intervals)
	self.damage_mult = intervals * 0.01
	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = 0,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self.ability
	}

	self:StartIntervalThink(intervals)
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_1_modifier_hypo:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker_1_modifier_hypo:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function icebreaker_1_modifier_hypo:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf"
end

function icebreaker_1_modifier_hypo:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_1_modifier_hypo:CheckCounterEfx()
	local mod = self.parent:FindModifierByName("bocuse_3_modifier_mark")
	if mod then mod:PopupSauce(true) end
end

function icebreaker_1_modifier_hypo:PopupIce(immediate)
	if self.pidx then ParticleManager:DestroyParticle(self.pidx, immediate) end

	local particle = "particles/units/heroes/hero_drow/drow_hypothermia_counter_stack.vpcf"
    if self.parent:HasModifier("bocuse_3_modifier_mark") then particle = "particles/icebreaker/icebreaker_counter_stack.vpcf" end
    self.pidx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.pidx, 1, Vector(0, self:GetStackCount(), 0))
	
	if not immediate then
		if IsServer() then self.parent:EmitSound("Hero_Icebreaker.Frost") end
	end
end