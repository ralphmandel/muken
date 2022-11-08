bocuse_3_modifier_passive = class({})

function bocuse_3_modifier_passive:IsHidden()
	return true
end

function bocuse_3_modifier_passive:IsPurgable()
	return false
end

function bocuse_3_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:OnIntervalThink() end
end

function bocuse_3_modifier_passive:OnRefresh(kv)
end

function bocuse_3_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bocuse_3_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.attacker:PassivesDisabled() then return end
	if keys.target:IsMagicImmune() then return end
	if self.ability:IsCooldownReady() == false then return end

	self:ApplyMark(keys.target)
end

function bocuse_3_modifier_passive:OnIntervalThink()
	if self.add_mark == true then
		self.add_mark = false
		self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	end

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

function bocuse_3_modifier_passive:ApplyMark(target)
	if target:IsAlive() == false then return end
	local max_stack = self.ability:GetSpecialValueFor("max_stack")
	local mark = target:FindModifierByNameAndCaster("bocuse_3_modifier_mark", self.caster)
	if mark then if mark:GetStackCount() >= max_stack then return end end

	self.add_mark = true

	target:AddNewModifier(self.caster, self.ability, "bocuse_3_modifier_mark", {})
	if IsServer() then target:EmitSound("Hero_Bocuse.Sauce") end
end

-- EFFECTS -----------------------------------------------------------