templar_u_modifier_praise = class({})

function templar_u_modifier_praise:IsHidden() return false end
function templar_u_modifier_praise:IsPurgable() return false end
function templar_u_modifier_praise:RemoveOnDeath() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_u_modifier_praise:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddStatusEfx(self.ability, "templar_u_modifier_praise_status_efx", self.caster, self.parent)

  if IsServer() then
    self:PlayEfxStart()
    self:OnIntervalThink()
  end
end

function templar_u_modifier_praise:OnRefresh(kv)
end

function templar_u_modifier_praise:OnRemoved()
  RemoveStatusEfx(self.ability, "templar_u_modifier_praise_status_efx", self.caster, self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function templar_u_modifier_praise:OnIntervalThink()
  local allies = {}
  local index = 0
  local interval = 0.1

  for _, hero in pairs(HeroList:GetAllHeroes()) do
    if hero:GetTeamNumber() == self.caster:GetTeamNumber()
    and hero:IsAlive() and hero:IsOutOfGame() == false
    and hero:GetHealthPercent() < self.ability:GetSpecialValueFor("hp_cap") then
      index = index + 1
      table.insert(allies, index, hero)
    end
  end

  if index > 0 then
    interval = self.ability:GetSpecialValueFor("interval_base")
    local random_ally = allies[RandomInt(1, #allies)]
    random_ally:Heal(CalcHeal(self.caster, self.ability:GetSpecialValueFor("heal")), self.ability)
    if IsServer() then self:StartEfxBeam(random_ally) end
  end

  if index > 1 then
    for i = 1, #allies - 1 do
      interval = interval * self.ability:GetSpecialValueFor("interval_reduction")
    end
  end

  if IsServer() then self:StartIntervalThink(interval) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function templar_u_modifier_praise:GetStatusEffectName()
  return "particles/status_fx/status_effect_shield_rune.vpcf"
end

function templar_u_modifier_praise:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function templar_u_modifier_praise:PlayEfxStart()  
  local particle = "particles/econ/items/luna/luna_lucent_ti5_gold/luna_eclipse_cast_moonfall_gold.vpcf"
  local efx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(efx, 0, self.parent:GetOrigin())
  self:AddParticle(efx, false, false, -1, true, false)

  local string = "particles/bioshadow/bioshadow_poison_hit_shake.vpcf"
  local effect = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
  ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(effect, 1, Vector(300, 0, 0))
  ParticleManager:ReleaseParticleIndex(effect)

  if IsServer() then self.parent:EmitSound("Hero_Chen.HandOfGodHealHero") end
end

function templar_u_modifier_praise:StartEfxBeam(unit)
  local particle = "particles/econ/items/luna/luna_lucent_ti5_gold/luna_eclipse_impact_notarget_moonfall_gold.vpcf"
  local efx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:SetParticleControl(efx, 0, unit:GetOrigin())
	ParticleManager:SetParticleControlEnt(efx, 1, unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(efx, 5, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(efx, 6, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(efx)

  if IsServer() then unit:EmitSound("Hero_Luna.Eclipse.Target") end
  if IsServer() then unit:EmitSound("Hero_Chen.HandOfGodHealHero") end
end