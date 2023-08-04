genuine_4_modifier_under = class({})

function genuine_4_modifier_under:IsHidden() return false end
function genuine_4_modifier_under:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_under:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.invi = AddModifier(self.parent, self.ability, "_modifier_invisible", {delay = 0.5, spell_break = 1}, true)

  self.invi:SetEndCallback(function(interrupted)
		self:Destroy()
	end)

  self.ability:EndCooldown()
  self.ability:SetActivated(false)

  if IsServer() then self.parent:EmitSound("DOTA_Item.InvisibilitySword.Activate") end
end

function genuine_4_modifier_under:OnRefresh(kv)
end

function genuine_4_modifier_under:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", self.ability)

  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
  self.ability:SetActivated(true)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------