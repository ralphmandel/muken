dasdingo_2_modifier_passive = class({})

function dasdingo_2_modifier_passive:IsHidden() return true end
function dasdingo_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_2_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  if IsServer() then self:StartIntervalThink(1) end
end

function dasdingo_2_modifier_passive:OnRefresh(kv)
end

function dasdingo_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo_2_modifier_passive:OnIntervalThink()
  local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
  for _, mod_thinker in pairs(thinkers) do
    local modifier = mod_thinker:FindModifierByNameAndCaster("dasdingo_2_modifier_aura", self.caster)
    if modifier then self:CreateRoot(mod_thinker) end
  end

  if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("root_interval")) end
end

-- UTILS -----------------------------------------------------------

function dasdingo_2_modifier_passive:CreateRoot(tree_modifier)
  if IsServer() then self:PlayEfxRoot(tree_modifier) end

  local enemies = FindUnitsInRadius(
    self.parent:GetTeamNumber(), tree_modifier:GetOrigin(), nil, self.ability:GetAOERadius(),
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
  )

  for _,enemy in pairs(enemies) do
    local multiplier = 1 - (((tree_modifier:GetOrigin() - enemy:GetOrigin()):Length2D() / self.ability:GetAOERadius()) * 0.75)
    
    AddModifier(enemy, self.ability, "dasdingo_2_modifier_aura_effect", {
      duration = self.ability:GetSpecialValueFor("root_interval") - 0.5,
      multiplier = multiplier
    }, false)
  end
end

-- EFFECTS -----------------------------------------------------------

function dasdingo_2_modifier_passive:PlayEfxRoot(target)
  local particle = "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast.vpcf"
  local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
  ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
  ParticleManager:ReleaseParticleIndex(effect)

  if IsServer() then target:EmitSound("Hero_Treant.LeechSeed.Cast") end
end