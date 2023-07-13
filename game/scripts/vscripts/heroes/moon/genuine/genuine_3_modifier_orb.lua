genuine_3_modifier_orb = class({})

function genuine_3_modifier_orb:IsHidden() return true end
function genuine_3_modifier_orb:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_3_modifier_orb:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddModifier(self.caster, self.caster, self.ability, "genuine_3_modifier_travel", {}, false)

	if IsServer() then self.parent:EmitSound("Hero_Puck.Illusory_Orb") end
end

function genuine_3_modifier_orb:OnRefresh(kv)
end

function genuine_3_modifier_orb:OnRemoved()
	if IsServer() then
    self.caster:RemoveModifierByName("genuine_3_modifier_travel")
		self.parent:StopSound("Hero_Puck.Illusory_Orb")
		UTIL_Remove(self:GetParent())
	end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------