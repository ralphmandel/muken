hunter_4_modifier_channeling = class({})

function hunter_4_modifier_channeling:IsHidden() return true end
function hunter_4_modifier_channeling:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_4_modifier_channeling:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if self.caster ~= self.parent then
    self.parent:Stop()
  end

  if IsServer() then self.parent:EmitSound("DOTA_Item.RepairKit.Target") end
end

function hunter_4_modifier_channeling:OnRefresh(kv)
end

function hunter_4_modifier_channeling:OnRemoved()
  if IsServer() then self.parent:StopSound("DOTA_Item.RepairKit.Target") end
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_4_modifier_channeling:CheckState()
	local state = {}

  if self:GetCaster() ~= self:GetParent() then
    table.insert(state, MODIFIER_STATE_COMMAND_RESTRICTED, true)
  end

	return state
end

function hunter_4_modifier_channeling:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_UNIT_MOVED
	}

	return funcs
end

function hunter_4_modifier_channeling:OnUnitMoved(keys)
	if keys.unit ~= self.parent then return end
  self.caster:InterruptChannel()
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function hunter_4_modifier_channeling:GetEffectName()
	return "particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff_rune.vpcf"
end

function hunter_4_modifier_channeling:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end