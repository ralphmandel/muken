templar_3_modifier_combo = class({})

function templar_3_modifier_combo:IsHidden() return true end
function templar_3_modifier_combo:IsPurgable() return false end
function templar_3_modifier_combo:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_3_modifier_combo:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  
  if IsServer() then
    self:SetStackCount(self.ability:GetSpecialValueFor("hits"))
    self:PlayEfxStart()
    self:StartIntervalThink(0.8)
  end
end

function templar_3_modifier_combo:OnRefresh(kv)
end

function templar_3_modifier_combo:OnRemoved()
  if IsServer() then self.parent:StopSound("Templar.Light") end
end

-- API FUNCTIONS -----------------------------------------------------------

function templar_3_modifier_combo:OnIntervalThink()
  if IsServer() then
    self:PlayEfxHit()

    AddModifier(self.parent, self.ability, "_modifier_stun", {duration = 0.1}, false)

    ApplyDamage({
      victim = self.parent, attacker = self.caster,
      damage = self.ability:GetSpecialValueFor("damage"),
      damage_type = self.ability:GetAbilityDamageType(),
      ability = self.ability
    })

    self:DecrementStackCount()
    self:StartIntervalThink(0.15)
  end
end

function templar_3_modifier_combo:OnStackCountChanged(old)
  if self:GetStackCount() == 0 and self:GetStackCount() ~= old then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function templar_3_modifier_combo:PlayEfxStart()
  local particle_pre = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_beam_shaft.vpcf"
  self.pfx = ParticleManager:CreateParticle(particle_pre, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(self.pfx, 0, self.parent:GetOrigin())
	self:AddParticle(self.pfx, false, false, -1, true, false)

  if IsServer() then self.parent:EmitSound("Templar.Light") end
end

function templar_3_modifier_combo:PlayEfxHit()
  if IsServer() then self.parent:EmitSound("Templar.Combo.Hit") end
end