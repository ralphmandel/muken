ancient_4_modifier_walk = class ({})

function ancient_4_modifier_walk:IsHidden() return false end
function ancient_4_modifier_walk:IsPurgable() return false end
function ancient_4_modifier_walk:GetPriority() return MODIFIER_PRIORITY_ULTRA end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_4_modifier_walk:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.ability:SetActivated(false)
  self.ability:EndCooldown()
  AddModifier(self.parent, self.ability, "_modifier_petrified", {special = 1}, false)

	if IsServer() then
    self:PlayEfxStart()
    self:OnIntervalThink()
  end
end

function ancient_4_modifier_walk:OnRefresh(kv)
end

function ancient_4_modifier_walk:OnRemoved()
	self.ability:SetActivated(true)
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_petrified", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_4_modifier_walk:CheckState()
	local state = {
    [MODIFIER_STATE_ROOTED] = false,
    [MODIFIER_STATE_STUNNED] = false,
    [MODIFIER_STATE_FROZEN] = false
  }

	return state
end

function ancient_4_modifier_walk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}
	
	return funcs
end

function ancient_4_modifier_walk:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("ms_limit")
end

function ancient_4_modifier_walk:OnIntervalThink()
	self:ApplyDebuff()

	if IsServer() then
		self:PlayEfxTick()
		self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
	end
end

-- UTILS -----------------------------------------------------------

function ancient_4_modifier_walk:ApplyDebuff()
  local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    self.ability:GetAbilityTargetFlags(), 0, false
	)

	for _,enemy in pairs(enemies) do
    AddModifier(enemy, self.ability, "ancient_4_modifier_debuff", {
      duration = self.ability:GetSpecialValueFor("debuff_duration")
    }, false)
	end
end

-- EFFECTS -----------------------------------------------------------

function ancient_4_modifier_walk:PlayEfxStart()
	local particle = "particles/econ/items/pugna/pugna_ward_golden_nether_lord/pugna_gold_ambient.vpcf"
	local effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_caster, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_caster, 1, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_caster, 2, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_caster, 4, self.parent:GetOrigin())
	self:AddParticle(effect_caster, false, false, -1, false, false)

  if IsServer() then
    self.parent:EmitSound("Ancient.Aura.Cast")
    self.parent:EmitSound("Ancient.Aura.Effect")
  end
end

function ancient_4_modifier_walk:PlayEfxTick()
	local particle_cast = "particles/ancient/ancient_aura_pulses.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())

	if IsServer() then
		self.parent:EmitSound("Ancient.Aura.Layer")
		self.parent:EmitSound("Hero_EarthShaker.Totem.Attack.Immortal.Layer")
	end
end