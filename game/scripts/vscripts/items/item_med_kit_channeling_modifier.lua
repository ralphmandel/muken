item_med_kit_channeling_modifier = class({})

function item_med_kit_channeling_modifier:IsHidden() return true end
function item_med_kit_channeling_modifier:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function item_med_kit_channeling_modifier:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if self.caster ~= self.parent then
    self.parent:Stop()
  end

  if IsServer() then self.parent:EmitSound("DOTA_Item.RepairKit.Target") end
end

function item_med_kit_channeling_modifier:OnRefresh(kv)
end

function item_med_kit_channeling_modifier:OnRemoved()
  if IsServer() then self.parent:StopSound("DOTA_Item.RepairKit.Target") end
end

-- API FUNCTIONS -----------------------------------------------------------

function item_med_kit_channeling_modifier:CheckState()
	local state = {}

  if self:GetCaster() ~= self:GetParent() then
    table.insert(state, MODIFIER_STATE_COMMAND_RESTRICTED, true)
  end

	return state
end

function item_med_kit_channeling_modifier:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_UNIT_MOVED
	}

	return funcs
end

function item_med_kit_channeling_modifier:OnUnitMoved(keys)
	if keys.unit == self.caster then self.caster:InterruptChannel() end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------