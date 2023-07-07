dasdingo_5_modifier_ignition = class({})

function dasdingo_5_modifier_ignition:IsHidden() return false end
function dasdingo_5_modifier_ignition:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_5_modifier_ignition:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.step = kv.step

  if self.step == 1 then
    if self.parent:IsMagicImmune() == false then
      AddModifier(self.parent, self.caster, self.ability, "_modifier_stun", {}, false)
    end
    if IsServer() then self:PlayEfxStart() end
  end

  if self.step == 2 then
    if self.parent:IsMagicImmune() == false then
      AddModifier(self.parent, self.caster, self.ability, "_modifier_percent_movespeed_debuff", {percent = 25}, false)
    end
  end
  
  if IsServer() then self:OnIntervalThink() end
end

function dasdingo_5_modifier_ignition:OnRefresh(kv)
end

function dasdingo_5_modifier_ignition:OnRemoved()
  if self.step == 1 then
    RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_stun", self.ability)
    AddModifier(self.parent, self.caster, self.ability, "dasdingo_5_modifier_ignition", {
      duration = self.ability:GetSpecialValueFor("slow_duration"), step = 2
    }, true)
  end
  
  if self.step == 2 or self.parent:IsAlive() == false then
    RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
    if IsServer() then self.parent:StopSound("Dasdingo.Fire.Loop") end
  end
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo_5_modifier_ignition:OnIntervalThink()
	if IsServer() then
    self:ApplyIgnitionDamage()
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
  end
end

-- UTILS -----------------------------------------------------------

function dasdingo_5_modifier_ignition:ApplyIgnitionDamage()
  ApplyDamage({
    attacker = self.caster, victim = self.parent, ability = self.ability,
    damage = self.ability:GetSpecialValueFor("ignition_damage"),
    damage_type = self.ability:GetAbilityDamageType()
  })
end

-- EFFECTS -----------------------------------------------------------

function dasdingo_5_modifier_ignition:GetEffectName()
	return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf"
end

function dasdingo_5_modifier_ignition:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function dasdingo_5_modifier_ignition:PlayEfxStart()
	local particle_cast = "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then
    self.parent:EmitSound("Dasdingo.Fire.Loop")
    self.parent:EmitSound("Hero_Batrider.Flamebreak.Impact")
  end
end