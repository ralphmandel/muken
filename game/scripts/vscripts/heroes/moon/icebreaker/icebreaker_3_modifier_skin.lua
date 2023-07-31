icebreaker_3_modifier_skin = class({})

function icebreaker_3_modifier_skin:IsHidden() return false end
function icebreaker_3_modifier_skin:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_3_modifier_skin:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddModifier(self.parent, self.caster, self.ability, "_modifier_mana_regen", {
    amount = self.ability:GetSpecialValueFor("special_mp_regen") * 100
  }, false)

  self.hp_regen = self.ability:GetSpecialValueFor("hp_regen")

  self:SpreadHypo()

	if IsServer() then self:PlayEfxStart() end
end

function icebreaker_3_modifier_skin:OnRefresh(kv)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_mana_regen", self.ability)
  AddModifier(self.parent, self.caster, self.ability, "_modifier_mana_regen", {
    amount = self.ability:GetSpecialValueFor("special_mp_regen")
  }, false)

  self.hp_regen = self.ability:GetSpecialValueFor("hp_regen")

  self:SpreadHypo()

	if IsServer() then self:PlayEfxStart() end
end

function icebreaker_3_modifier_skin:OnRemoved()
  self:SpreadHypo()

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_mana_regen", self.ability)
  if IsServer() then self.parent:EmitSound("Hero_Lich.IceAge.Tick") end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_3_modifier_skin:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
	}

	return funcs
end

function icebreaker_3_modifier_skin:GetModifierConstantHealthRegen(keys)
  return self.hp_regen
end

function icebreaker_3_modifier_skin:GetModifierPhysical_ConstantBlock(keys)
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return 0 end
	if RandomFloat(0, 100) >= self.ability:GetSpecialValueFor("chance") then return 0 end

  AddModifier(keys.attacker, self.caster, self.ability, "icebreaker__modifier_hypo", {
    stack = self.ability:GetSpecialValueFor("hypo_stack")
  }, false)

  AddModifier(keys.attacker, self.caster, self.ability, "icebreaker__modifier_instant", {
    duration = self.ability:GetSpecialValueFor("special_mini_freeze")
  }, true)
  
	if IsServer() then self:PlayEfxBlock(keys.attacker) end

  return 0
end

-- UTILS -----------------------------------------------------------

function icebreaker_3_modifier_skin:SpreadHypo()
  local spread_radius = self.ability:GetSpecialValueFor("special_spread_radius")
  if spread_radius == 0 then return end

  self:PlayEfxSpread(self.parent)
  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, spread_radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
    0, 0, false
  )

  for _,enemy in pairs(enemies) do
    if IsServer() then enemy:EmitSound("Hero_DrowRanger.Marksmanship.Target") end
    AddModifier(enemy, self.caster, self.ability, "icebreaker__modifier_hypo", {
      stack = self.ability:GetSpecialValueFor("special_spread_stack")
    }, false)
  end
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_3_modifier_skin:PlayEfxStart()
  local particle = "particles/units/heroes/hero_lich/lich_ice_age.vpcf"
	local efx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControlEnt(efx, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(efx, 2, Vector(300, 300, 300))
	self:AddParticle(efx, false, false, -1, false, false)

  local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_frost_armor.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	self:AddParticle(particle2, false, false, -1, false, false)

  if IsServer() then self.parent:EmitSound("Hero_Lich.IceAge") end
end

function icebreaker_3_modifier_skin:PlayEfxBlock(target)
  if IsServer() then target:EmitSound("Hero_Lich.IceAge.Damage") end
end

function icebreaker_3_modifier_skin:PlayEfxSpread(target)
  local particle = "particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_explode_ti5.vpcf"
  local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
  ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
  ParticleManager:SetParticleControl(effect_cast, 3, target:GetOrigin())
end