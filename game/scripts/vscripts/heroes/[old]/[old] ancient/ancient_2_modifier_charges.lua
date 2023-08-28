ancient_2_modifier_charges = class({})

function ancient_2_modifier_charges:IsHidden() return true end
function ancient_2_modifier_charges:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_2_modifier_charges:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:StartIntervalThink(1) end
end

function ancient_2_modifier_charges:OnRefresh(kv)
end

function ancient_2_modifier_charges:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_2_modifier_charges:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function ancient_2_modifier_charges:OnOrder(keys)
  if keys.unit ~= self.parent then return end
  if keys.order_type == 8 or keys.order_type == 5 then
    self.ability.aggro_target = self.parent:GetAggroTarget()
  end
end

function ancient_2_modifier_charges:OnIntervalThink()
  self.parent:FindAbilityByName("ancient__jump"):SetLevel(math.floor(self.parent:GetIdealSpeed()))
  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------