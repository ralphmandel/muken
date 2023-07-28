hunter_u_modifier_passive = class({})

function hunter_u_modifier_passive:IsHidden() return true end
function hunter_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.records = {}

  --if IsServer() then self:StartIntervalThink(1) end
end

function hunter_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_u_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY
	}

	return funcs
end

function hunter_u_modifier_passive:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_passive:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_passive:GetModifierAttackRangeBonus()
  return self:GetAbility():GetSpecialValueFor("atk_range")
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

-- UTILS -----------------------------------------------------------

function hunter_u_modifier_passive:OnIntervalThink()
  --local loc = "Vector(" .. math.floor(self.parent:GetOrigin().x) .. ", " .. math.floor(self.parent:GetOrigin().y) .. ", 0)"
  --print(loc)

  print("KUBO -----------------------")
  local entities = Entities:FindAllInSphere(SHRINE_INFO[DOTA_TEAM_CUSTOM_1]["fountain_origin"], 300)
  for k, entity in pairs(entities) do
    print("class:", entity:GetClassname(), "isBaseNPC:", entity:IsBaseNPC())
  end
end

-- EFFECTS -----------------------------------------------------------