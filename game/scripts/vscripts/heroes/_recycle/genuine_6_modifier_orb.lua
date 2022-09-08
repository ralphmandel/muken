genuine_6_modifier_orb = class({})

function genuine_6_modifier_orb:IsHidden()
	return true
end

function genuine_6_modifier_orb:IsPurgable()
	return false
end

function genuine_6_modifier_orb:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_6_modifier_orb:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self.parent:EmitSound("Hero_Puck.Illusory_Orb") end
end

function genuine_6_modifier_orb:OnRefresh(kv)
end

function genuine_6_modifier_orb:OnRemoved()
	if IsServer() then
		self.parent:StopSound("Hero_Puck.Illusory_Orb")
		UTIL_Remove(self:GetParent())
	end
end