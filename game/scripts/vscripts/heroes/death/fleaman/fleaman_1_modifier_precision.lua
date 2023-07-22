fleaman_1_modifier_precision = class({})
local tempTable = require("libraries/tempTable")

function fleaman_1_modifier_precision:IsHidden() return false end
function fleaman_1_modifier_precision:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_1_modifier_precision:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  AddStatusEfx(self.ability, "fleaman_1_modifier_precision_status_efx", self.caster, self.parent)

	if IsServer() then
		self:SetStackCount(0)
		self:AddMultStack()
	end
end

function fleaman_1_modifier_precision:OnRefresh(kv)
	if IsServer() then self:AddMultStack() end
end

function fleaman_1_modifier_precision:OnRemoved()
  RemoveStatusEfx(self.ability, "fleaman_1_modifier_precision_status_efx", self.caster, self.parent)
	RemoveBonus(self.ability, "AGI", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_1_modifier_precision:OnStackCountChanged(old)
	if old == self:GetStackCount() then return end
	if self:GetStackCount() == 0 then self:Destroy() return end

  RemoveBonus(self.ability, "AGI", self.parent)
  AddBonus(self.ability, "AGI", self.parent, self:GetStackCount() * self.ability:GetSpecialValueFor("agi"), 0, nil)
end

-- UTILS -----------------------------------------------------------

function fleaman_1_modifier_precision:AddMultStack()
	local duration = CalcStatus(self.ability:GetSpecialValueFor("duration"), self.caster, self.parent)

  if IsServer() then
    self:SetDuration(duration, true)
    self:IncrementStackCount()
    self.parent:EmitSound("Fleaman.Precision")
  end
  
  AddModifier(self.parent, self.caster, self.ability, "fleaman_1_modifier_precision_stack", {
    duration = duration, modifier = tempTable:AddATValue(self)
  }, false)
end

-- EFFECTS -----------------------------------------------------------

function fleaman_1_modifier_precision:GetStatusEffectName()
    return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function fleaman_1_modifier_precision:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end