hunter_u_modifier_passive = class({})

function hunter_u_modifier_passive:IsHidden() return true end
function hunter_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.has_tree = false
  self.records = {}

  if IsServer() then self:StartIntervalThink(1) end
end

function hunter_u_modifier_passive:OnRefresh(kv)
end

function hunter_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_u_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY
	}

	return funcs
end

function hunter_u_modifier_passive:GetModifierProcAttack_BonusDamage_Physical(keys)
	if self.records[keys.record] then
    return self.records[keys.record] * self.ability:GetSpecialValueFor("bonus_damage") * 0.01
	end
end

function hunter_u_modifier_passive:OnAttack(keys)
	if keys.attacker ~= self.parent then return end

  self.records[keys.record] = CalcDistanceBetweenEntityOBB(self.parent, keys.target)
end

function hunter_u_modifier_passive:OnAttackRecordDestroy(keys)
	self.records[keys.record] = nil
end

function hunter_u_modifier_passive:OnIntervalThink()
  if self.parent:HasModifier("hunter_u_modifier_camouflage") then
    if IsServer() then self:StartIntervalThink(-1) end
    self.has_tree = false
    return
  end

  local has_tree = HasTreeNearby(self.parent:GetOrigin(), 150)

  if self.has_tree == true and has_tree == true
  and self.parent:PassivesDisabled() == false then    
    local camo = AddModifier(self.parent, self.ability, "hunter_u_modifier_camouflage", {}, false)
    camo:SetEndCallback(function(interrupted)
      if IsServer() then self:StartIntervalThink(0.1) end
    end)

    if IsServer() then self:StartIntervalThink(-1) end
    self.has_tree = false
    return
  end

  self.has_tree = has_tree

  if IsServer() then self:StartIntervalThink(1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------