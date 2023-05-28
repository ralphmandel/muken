bald_5_modifier_goo = class({})

function bald_5_modifier_goo:IsHidden() return false end
function bald_5_modifier_goo:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_5_modifier_goo:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:SetStackCount(1)
    self:PlayEfxStart()
  end
end

function bald_5_modifier_goo:OnRefresh(kv)
  if IsServer() then
    self:IncrementStackCount()
    self:PlayEfxStart()
  end
end

function bald_5_modifier_goo:OnRemoved()
  RemoveBonus(self.ability, "_2_DEX", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_5_modifier_goo:OnStackCountChanged(old)
  local goo_max_stack = self.ability:GetSpecialValueFor("special_goo_max_stack")
  if self:GetStackCount() > goo_max_stack then
    self:SetStackCount(goo_max_stack)
  end

  RemoveBonus(self.ability, "_2_DEX", self.parent)
  AddBonus(self.ability, "_2_DEX", self.parent, self:GetStackCount() * self.ability:GetSpecialValueFor("special_goo_dex"), 0, nil)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)

  self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
    percent = self:GetStackCount() * self.ability:GetSpecialValueFor("special_goo_ms")
  })
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_5_modifier_goo:GetEffectName()
	return "particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_crimson_nasal_goo_debuff.vpcf"
end

function bald_5_modifier_goo:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function bald_5_modifier_goo:PlayEfxStart()
	local particle = "particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray_hit.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
  self:AddParticle(effect, false, false, -1, true, false)
end