icebreaker__modifier_hypo = class({})

function icebreaker__modifier_hypo:IsHidden() return false end
function icebreaker__modifier_hypo:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_hypo:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.slow_as = 0.15
	self.slow_ms = 10
	self.max_stack = 10
	self.frozen_duration = 5

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker__modifier_hypo_status_efx", true) end

	if IsServer() then self:SetStackCount(kv.stack) end
end

function icebreaker__modifier_hypo:OnRefresh(kv)
	if IsServer() then self:SetStackCount(self:GetStackCount() + kv.stack) end
end

function icebreaker__modifier_hypo:OnRemoved()
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker__modifier_hypo_status_efx", false) end

	self:ModifySlow(0)
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
		self:ModifySlow(self:GetStackCount())
	end
end

-- UTILS -----------------------------------------------------------

function icebreaker__modifier_hypo:ModifySlow(stack_count)
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
	local mod = self.parent:FindModifierByName("bocuse_3_modifier_mark")
	if mod then mod:PopupSauce(true) end
end

function icebreaker__modifier_hypo:PopupIce(immediate)
	if self.pidx then ParticleManager:DestroyParticle(self.pidx, immediate) end

	local particle = "particles/units/heroes/hero_drow/drow_hypothermia_counter_stack.vpcf"
  if self.parent:HasModifier("bocuse_3_modifier_mark") then particle = "particles/icebreaker/icebreaker_counter_stack.vpcf" end
  self.pidx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.pidx, 1, Vector(0, self:GetStackCount(), 0))
	
	if not immediate then
		if IsServer() then self.parent:EmitSound("Hero_Icebreaker.Frost") end
	end
end