flea_u_modifier_passive = class({})

function flea_u_modifier_passive:IsHidden() return false end
function flea_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_u_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function flea_u_modifier_passive:OnRefresh(kv)
end

function flea_u_modifier_passive:OnRemoved()
	RemoveBonus(self.ability, "_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_u_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	keys.target:AddNewModifier(self.caster, self.ability, "flea_u_modifier_weakness", {})
end

function flea_u_modifier_passive:OnStackCountChanged(old)
	RemoveBonus(self.ability, "_1_STR", self.parent)

	if self:GetStackCount() > 0 then
		AddBonus(self.ability, "_1_STR", self.parent, self:GetStackCount(), 0, nil)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------