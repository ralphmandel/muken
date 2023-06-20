druid_5_modifier_aura = class({})

function druid_5_modifier_aura:IsHidden() return true end
function druid_5_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function druid_5_modifier_aura:IsAura() return true end
function druid_5_modifier_aura:GetModifierAura() return "druid_5_modifier_aura_effect" end
function druid_5_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end

function druid_5_modifier_aura:GetAuraSearchTeam()
  if self:GetAbility():GetSpecialValueFor("special_enemy_seed") == 1 then
    return DOTA_UNIT_TARGET_TEAM_BOTH
  end

  return self:GetAbility():GetAbilityTargetTeam()
end

function druid_5_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function druid_5_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

function druid_5_modifier_aura:GetAuraEntityReject(hEntity)
  if self:GetAbility():GetSpecialValueFor("special_druid_seed_extra") == 0 then
    return (self:GetParent() == hEntity)
  end

  return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_5_modifier_aura:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.tree_interval = self.ability:GetSpecialValueFor("tree_interval")
  self.parent:AddNewModifier(self.caster, self.ability, "druid_5_modifier_wind_effect", {})

  if IsServer() then
    self:PlayEfxStart()
    self:StartIntervalThink(self.tree_interval)
  end
end

function druid_5_modifier_aura:OnRefresh(kv)
end

function druid_5_modifier_aura:OnRemoved()
  self.parent:RemoveModifierByNameAndCaster("druid_5_modifier_wind_effect", self.caster)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_5_modifier_aura:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET
	}

	return funcs
end

function druid_5_modifier_aura:GetModifierHealAmplify_PercentageTarget()
  return self:GetAbility():GetSpecialValueFor("special_heal_amp")
end

function druid_5_modifier_aura:OnIntervalThink()
  local radius = self.ability:GetAOERadius()
  local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), radius, false)

  if trees then
    for _,tree in pairs(trees) do
      if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("tree_chance") then
        tree:CutDown(self.parent:GetTeamNumber())
      else
        self.ability:CreateSeedFromTree(tree:GetAbsOrigin() + Vector(0, 0, 100))
      end
      break
    end
  end

  if self.effect_aura then ParticleManager:SetParticleControl(self.effect_aura, 1, Vector(radius, 0, 0)) end
  if IsServer() then self:StartIntervalThink(self.tree_interval) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_5_modifier_aura:PlayEfxStart()
	local string_3 = "particles/druid/druid_ult_passive.vpcf"
	self.effect_aura = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_aura, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_aura, 1, Vector(self.ability:GetAOERadius(), 0, 0))
	self:AddParticle(self.effect_aura, false, false, -1, false, false)
end