shadowmancer_1_modifier_passive = class({})

function shadowmancer_1_modifier_passive:IsHidden()
	return true
end

function shadowmancer_1_modifier_passive:IsPurgable()
	return false
end

function shadowmancer_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function shadowmancer_1_modifier_passive:OnRefresh(kv)
end

function shadowmancer_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function shadowmancer_1_modifier_passive:OnAttackLanded(keys)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function shadowmancer_1_modifier_passive:GetEffectName()
	return "particles/shadowmancer/shadowmancer_arcana_ambient.vpcf"
end

function shadowmancer_1_modifier_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end