hunter_4_modifier_bandage = class({})

function hunter_4_modifier_bandage:IsHidden() return false end
function hunter_4_modifier_bandage:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_4_modifier_bandage:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.proj = {}

  self.hp_regen = self.ability:GetSpecialValueFor("hp_regen")
  self.max_bullets = self.ability:GetSpecialValueFor("max_bullets")
  self.debuff_duration = self.ability:GetSpecialValueFor("debuff_duration")

  if IsServer() then self:SetStackCount(self.ability:GetSpecialValueFor("bullets")) end
end

function hunter_4_modifier_bandage:OnRefresh(kv)
  self.hp_regen = self.ability:GetSpecialValueFor("hp_regen")
  self.max_bullets = self.ability:GetSpecialValueFor("max_bullets")
  self.debuff_duration = self.ability:GetSpecialValueFor("debuff_duration")

  if IsServer() then self:SetStackCount(self:GetStackCount() + self.ability:GetSpecialValueFor("bullets")) end
end

function hunter_4_modifier_bandage:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_4_modifier_bandage:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_EVENT_ON_ATTACK,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_EVENT_ON_ATTACK_FAIL,
    MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY
	}

	return funcs
end

function hunter_4_modifier_bandage:GetModifierConstantHealthRegen(keys)
  return self.hp_regen
end

function hunter_4_modifier_bandage:OnStackCountChanged(old)
  if IsServer() then
    if self:GetStackCount() > self.max_bullets then
      self:SetStackCount(self.max_bullets)
    end    
  end
end

function hunter_4_modifier_bandage:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
  if self:GetStackCount() == 0 then return end

  self.proj[keys.record] = true

  if IsServer() then self:DecrementStackCount() end
end

function hunter_4_modifier_bandage:OnAttackLanded(keys)
	if self.proj[keys.record] and keys.attacker == self.parent then self:ApplyPoison(keys) end
end

function hunter_4_modifier_bandage:OnAttackFailed(keys)
	if self.proj[keys.record] and keys.attacker == self.parent then self:ApplyPoison(keys) end
end

function hunter_4_modifier_bandage:OnAttackRecordDestroy(keys)
	self.proj[keys.record] = nil
end

-- UTILS -----------------------------------------------------------

function hunter_4_modifier_bandage:ApplyPoison(keys)
  AddModifier(keys.target, self.ability, "hunter_4_modifier_debuff", {duration = self.debuff_duration}, true)
end

-- EFFECTS -----------------------------------------------------------

function hunter_4_modifier_bandage:GetEffectName()
	return "particles/items_fx/healing_tango.vpcf"
end

function hunter_4_modifier_bandage:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end