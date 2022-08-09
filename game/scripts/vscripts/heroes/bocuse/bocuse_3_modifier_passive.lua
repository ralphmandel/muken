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

	keys.target:AddNewModifier(self.caster, self.ability, "bocuse_3_modifier_mark", {})
	if IsServer() then keys.target:EmitSound("Hero_Bocuse.Sauce") end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------