lawbreaker_2_modifier_passive = class({})

function lawbreaker_2_modifier_passive:IsHidden() return false end
function lawbreaker_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:PlayEfxStart()
    self:SetStackCount(0)
    self.ability:EnableShotRefresh(true)
  end
end

function lawbreaker_2_modifier_passive:OnRefresh(kv)
end

function lawbreaker_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:OnIntervalThink()
  if IsServer() then self:IncrementStackCount() end
end

function lawbreaker_2_modifier_passive:OnStackCountChanged(old)
  self.ability:SetActivated(self:GetStackCount() >= self.ability:GetSpecialValueFor("min_shots"))
  if self:GetStackCount() == 0 then self.parent:RemoveModifierByName("lawbreaker_2_modifier_combo") end

  self:CheckShots()
end

-- UTILS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:CheckShots()
  if self:GetStackCount() == self.ability:GetSpecialValueFor("max_shots") then
    self.ability:EnableShotRefresh(false)
  else
    self.ability:EnableShotRefresh(true)
  end

  if self.particle then
    if IsServer() then self:PlayEfxStart() end
    for bar = 1, self.ability:GetSpecialValueFor("max_shots") do
      local value = 1
      if bar > self:GetStackCount() then value = 0 end
      ParticleManager:SetParticleControl(self.particle, bar + 1, Vector(value, 0, 0))
    end
  end

  self.ability:SetCurrentAbilityCharges(self:GetStackCount())
end

-- EFFECTS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:PlayEfxStart()
  if self.particle then ParticleManager:DestroyParticle(self.particle, true) end
  local string = "particles/lawbreaker/shots_count/lawbreaker_shots_overhead.vpcf"
  self.particle = ParticleManager:CreateParticle(string, PATTACH_OVERHEAD_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(self.particle, 1, Vector(self.ability:GetSpecialValueFor("max_shots"), 0, 0))
  self:AddParticle(self.particle, false, false, -1, false, false)
end