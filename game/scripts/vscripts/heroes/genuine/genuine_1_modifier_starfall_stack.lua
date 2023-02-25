genuine_1_modifier_starfall_stack = class({})

function genuine_1_modifier_starfall_stack:IsHidden() return false end
function genuine_1_modifier_starfall_stack:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_1_modifier_starfall_stack:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(1) end
end

function genuine_1_modifier_starfall_stack:OnRefresh(kv)
	local starfall_combo = self.ability:GetSpecialValueFor("special_starfall_combo")

	if IsServer() then
		if self:GetStackCount() < starfall_combo then
			self:IncrementStackCount()
			if self:GetStackCount() == starfall_combo then
				self.ability:CreateStarfall(self.parent)
				self:Destroy()
			end
		end
	end
end

function genuine_1_modifier_starfall_stack:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------