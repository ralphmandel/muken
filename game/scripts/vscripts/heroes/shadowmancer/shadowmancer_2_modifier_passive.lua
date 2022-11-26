shadowmancer_2_modifier_passive = class({})

function shadowmancer_2_modifier_passive:IsHidden()
	return true
end

function shadowmancer_2_modifier_passive:IsPurgable()
	return false
end

function shadowmancer_2_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_2_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))

	if IsServer() then self:OnIntervalThink() end
end

function shadowmancer_2_modifier_passive:OnRefresh(kv)
end

function shadowmancer_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_2_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function shadowmancer_2_modifier_passive:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:HasModifier("shadowmancer_2_modifier_walk") then return end

	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

function shadowmancer_2_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end

	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

function shadowmancer_2_modifier_passive:OnIntervalThink()
	if self.ability:IsCooldownReady() and self.parent:HasModifier("shadowmancer_2_modifier_walk") == false then
		self.parent:AddNewModifier(self.caster, self.ability, "shadowmancer_2_modifier_walk", {})
	end

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------