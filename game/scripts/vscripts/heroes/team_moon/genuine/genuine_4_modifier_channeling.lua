genuine_4_modifier_channeling = class({})

function genuine_4_modifier_channeling:IsHidden() return true end
function genuine_4_modifier_channeling:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_channeling:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  if IsServer() then self:StartIntervalThink(0.1) end
end

function genuine_4_modifier_channeling:OnRefresh(kv)
end

function genuine_4_modifier_channeling:OnRemoved()
  self.parent:InterruptChannel()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_4_modifier_channeling:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
	
	return funcs
end

function genuine_4_modifier_channeling:GetModifierConstantManaRegen()
  local ability = self:GetAbility()
	return -ability:GetManaCost(ability:GetLevel()) * (ability:GetSpecialValueFor("channel_time") / ability:GetChannelTime())
end

function genuine_4_modifier_channeling:OnIntervalThink()
  if self.parent:GetMana() < 10 then self:Destroy() return end
  if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------