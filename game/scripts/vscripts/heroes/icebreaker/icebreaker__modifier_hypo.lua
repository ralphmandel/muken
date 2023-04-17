icebreaker__modifier_hypo = class({})

function icebreaker__modifier_hypo:IsHidden() return false end
function icebreaker__modifier_hypo:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_hypo:OnCreated(kv)
  self.caster = self:GetCaster():GetPlayerOwner():GetAssignedHero()
  self.parent = self:GetParent()
  self.ability = self.caster:FindAbilityByName(self:GetAbility():GetAbilityName())

	self.slow_as = 0.15
	self.slow_ms = 10
	self.max_stack = 10
	self.frozen_duration = 5

	local stack = kv.stack or 0
	local stack_min = kv.stack_min or 0

	if stack_min > stack then stack = stack_min end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker__modifier_hypo_status_efx", true) end

	if IsServer() then
		self:SetStackCount(stack)
		self:CheckCounterEfx()
	end
end

function icebreaker__modifier_hypo:OnRefresh(kv)
	local stack = kv.stack or 0
	local stack_min = kv.stack_min or 0

	stack = stack + self:GetStackCount()
	if stack_min > stack then stack = stack_min end

	if IsServer() then self:SetStackCount(stack) end
end

function icebreaker__modifier_hypo:OnRemoved()
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker__modifier_hypo_status_efx", false) end

	if self.pidx then ParticleManager:DestroyParticle(self.pidx, true) end
	self:ModifySlow(0)
	self:CheckCounterEfx()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__modifier_hypo:OnStackCountChanged(old)
	if self:GetStackCount() >= self.max_stack then
		self.parent:AddNewModifier(self.caster, self.ability, "icebreaker__modifier_frozen", {
			duration = CalcStatus(self.frozen_duration, self.caster, self.parent)
		})
		return
	end

	if self:GetStackCount() ~= old then
		if self:GetStackCount() == 0 then
			self:Destroy()
			return
		end
		
		self:ModifySlow(self:GetStackCount())
	end
end

-- UTILS -----------------------------------------------------------

function icebreaker__modifier_hypo:ModifySlow(stack_count)	
	BaseStats(self.parent):SetBaseAttackTime(stack_count * self.slow_as)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)

	if stack_count > 0 then
		self:PopupIce(true)
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
			percent = stack_count * self.slow_ms
		})
	end
end

-- EFFECTS -----------------------------------------------------------

function icebreaker__modifier_hypo:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker__modifier_hypo:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function icebreaker__modifier_hypo:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf"
end

function icebreaker__modifier_hypo:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker__modifier_hypo:CheckCounterEfx()
	local mod = self.parent:FindModifierByName("bocuse_3_modifier_sauce")
	if mod then
		if IsServer() then mod:PopupSauce(false) end
	end
end

function icebreaker__modifier_hypo:PopupIce(sound)
	if self.pidx then ParticleManager:DestroyParticle(self.pidx, true) end

	local particle = "particles/units/heroes/hero_drow/drow_hypothermia_counter_stack.vpcf"
  if self.parent:HasModifier("bocuse_3_modifier_sauce") then particle = "particles/icebreaker/icebreaker_counter_stack.vpcf" end
  self.pidx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.pidx, 1, Vector(0, self:GetStackCount(), 0))

	if sound == true then
		if IsServer() then self.parent:EmitSound("Hero_Icebreaker.Frost") end
	end
end