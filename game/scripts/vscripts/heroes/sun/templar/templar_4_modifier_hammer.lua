templar_4_modifier_hammer = class({})

function templar_4_modifier_hammer:IsHidden() return false end
function templar_4_modifier_hammer:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_4_modifier_hammer:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:SetStackCount(10)
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
    self:PlayEfxStart()
  end
end

function templar_4_modifier_hammer:OnRefresh(kv)
  if IsServer() then
    self:SetStackCount(10)
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
    self:PlayEfxStart()
  end
end

function templar_4_modifier_hammer:OnRemoved()
  RemoveBonus(self.ability, "AGI", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function templar_4_modifier_hammer:OnIntervalThink()
  if IsServer() then self:DecrementStackCount() end
end

function templar_4_modifier_hammer:OnStackCountChanged(old)
  if self:GetStackCount() ~= old and self:GetStackCount() == 0 then self:Destroy() return end

  local agi = self.ability:GetSpecialValueFor("agi_start") * 0.1 * self:GetStackCount()
  local slow = self.ability:GetSpecialValueFor("slow_start") * 0.1 * self:GetStackCount()

  RemoveBonus(self.ability, "AGI", self.parent)
  AddBonus(self.ability, "AGI", self.parent, agi, 0, nil)

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
  AddModifier(self.parent, self.ability, "_modifier_percent_movespeed_debuff", {percent = slow}, false)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function templar_4_modifier_hammer:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_shard_hammer_of_purity_overhead_debuff.vpcf"
end

function templar_4_modifier_hammer:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function templar_4_modifier_hammer:PlayEfxStart()
  local string = "particles/units/heroes/hero_omniknight/omniknight_shard_hammer_of_purity_target.vpcf"
  local effect = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
  ParticleManager:ReleaseParticleIndex(effect)

  if IsServer() then self.parent:EmitSound("Hero_Omniknight.HammerOfPurity.Target") end
end