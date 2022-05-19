icebreaker_0_modifier_slow = class({})

--------------------------------------------------------------------------------

function icebreaker_0_modifier_slow:IsHidden()
	return false
end

function icebreaker_0_modifier_slow:IsPurgable()
    return true
end

function icebreaker_0_modifier_slow:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_slow:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.freeze_duration = self.ability:GetSpecialValueFor("freeze_duration")
	self.max_stack = self.ability:GetSpecialValueFor("max_stack")
	self.slow = self.ability:GetSpecialValueFor("slow")

	self.hypothermia = self.caster:FindAbilityByName("icebreaker_x2__sight")
	if self.hypothermia then
		if self.hypothermia:IsTrained() then
			self.parent:AddNewModifier(self.caster, self.hypothermia, "icebreaker_x2_modifier_sight", {})
		end
	end

	local stack = kv.stack

	if IsServer() then
		self:SetStackCount(stack)
		self:CheckCounterEfx()
		self:PopupIce(false)
		self:StartIntervalThink(self:GetRemainingTime())
	end

	local as_slow = 0.2
	local frost = self.caster:FindAbilityByName("icebreaker_1__frost")
	if frost then
		if frost:IsTrained() then
			-- UP 1.21
			if frost:GetRank(21) then
				as_slow = 0.4
			end			
		end
	end

	local agi_mod = self.parent:FindModifierByName("_1_AGI_modifier")
	if agi_mod then agi_mod:SetBaseAttackTime(self:GetStackCount() * as_slow) end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("icebreaker_0_modifier_slow_status_effect", true) end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		percent = self.slow * self:GetStackCount()
	})
end

function icebreaker_0_modifier_slow:OnRefresh( kv )
	local stack = kv.stack

	if IsServer() then
		self:SetStackCount(self:GetStackCount() + stack)
		self:StartIntervalThink(self:GetRemainingTime())
	end

	if self:GetStackCount() >= self.max_stack then
		self:Destroy()
		self.parent:AddNewModifier(self.caster, self.ability, "icebreaker_0_modifier_freeze", {
			duration = self.ability:CalcStatus(self.freeze_duration, self.caster, self.parent)
		})
		return
	end

	if IsServer() then
		self:PopupIce(false)
	end

	local as_slow = 0.2
	local frost = self.caster:FindAbilityByName("icebreaker_1__frost")
	if frost then
		if frost:IsTrained() then
			-- UP 1.21
			if frost:GetRank(21) then
				as_slow = 0.4
			end			
		end
	end

	local agi_mod = self.parent:FindModifierByName("_1_AGI_modifier")
	if agi_mod then agi_mod:SetBaseAttackTime(self:GetStackCount() * as_slow) end
	
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		percent = self.slow * self:GetStackCount()
	})
end

function icebreaker_0_modifier_slow:OnRemoved( kv )
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("icebreaker_0_modifier_slow_status_effect", false) end

	ParticleManager:DestroyParticle(self.pidx, false)
	self:CheckCounterEfx()

	self.parent:RemoveModifierByName("icebreaker_x2_modifier_sight")

	local agi_mod = self.parent:FindModifierByName("_1_AGI_modifier")
	if agi_mod then agi_mod:SetBaseAttackTime(0) end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_silence")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility():GetAbilityName() == "icebreaker_2__discus"
		and modifier:GetCaster() == self.caster then
			modifier:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end

function icebreaker_0_modifier_slow:GetModifierAttackSpeedBonus_Constant()
	if self.parent:IsCreep() then
		return -self.slow * self:GetStackCount()
	end
end

function icebreaker_0_modifier_slow:OnIntervalThink()
	if self:GetRemainingTime() < 0.2 then return end
	local zero = self.caster:FindAbilityByName("icebreaker_u__zero")
	if zero == nil then return end
	if zero:IsTrained() == false then return end
	local stack = zero:GetSpecialValueFor("stack")

	-- UP 4.21
	if zero:GetRank(21) then
		stack = stack + 1
	end

	if IsServer() then
		if self:GetStackCount() > stack then
			self:SetStackCount(stack)
			self:PopupIce(false)
		end
	end

	self:StartIntervalThink(-1)
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_slow:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker_0_modifier_slow:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function icebreaker_0_modifier_slow:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf"
end

function icebreaker_0_modifier_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_0_modifier_slow:CheckCounterEfx()
	local mod = self.parent:FindModifierByName("bocuse_3_modifier_mark")
	if mod then mod:PopupSauce(true) end
end

function icebreaker_0_modifier_slow:PopupIce(immediate)
	if self.pidx ~= nil then ParticleManager:DestroyParticle(self.pidx, immediate) end

	local particle = "particles/units/heroes/hero_drow/drow_hypothermia_counter_stack.vpcf"
    if self.parent:HasModifier("bocuse_3_modifier_mark") then particle = "particles/icebreaker/icebreaker_counter_stack.vpcf" end
    self.pidx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent) -- target:GetOwner()
	ParticleManager:SetParticleControl(self.pidx, 1, Vector(0, self:GetStackCount(), 0))
	
	if not immediate then
		if IsServer() then self.parent:EmitSound("Hero_Icebreaker.Frost") end
	end
end