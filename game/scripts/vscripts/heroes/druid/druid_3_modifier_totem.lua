druid_3_modifier_totem = class({})

function druid_3_modifier_totem:IsHidden() return false end
function druid_3_modifier_totem:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_3_modifier_totem:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
	self.min_health = self.parent:GetMaxHealth()

	if IsServer() then
		self:PlayEfxStart()
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
	end
end

function druid_3_modifier_totem:OnRefresh(kv)
end

function druid_3_modifier_totem:OnRemoved()
	if IsServer() then
		self.parent:StopSound("Hero_Juggernaut.FortunesTout.Loop")
		self.parent:EmitSound("Hero_Juggernaut.HealingWard.Stop")
	end

	if self.ambient then ParticleManager:DestroyParticle(self.ambient, false) end
	if self.parent:IsAlive() then self.parent:Kill(self.ability, nil) end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_3_modifier_totem:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

function druid_3_modifier_totem:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}

	return funcs
end

function druid_3_modifier_totem:OnDeath(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function druid_3_modifier_totem:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end

	self.min_health = self.min_health - 1
end

function druid_3_modifier_totem:GetDisableHealing()
	return 1
end

function druid_3_modifier_totem:GetMinHealth()
	return self.min_health
end

function druid_3_modifier_totem:GetVisualZDelta()
	return 150
end

function druid_3_modifier_totem:GetModifierMoveSpeedBonus_Constant()
	return 0
end

function druid_3_modifier_totem:OnIntervalThink()
  local heal = self.ability:GetSpecialValueFor("heal")
  local mana = self.ability:GetSpecialValueFor("mana")
  local base_stats = self.caster:FindAbilityByName("base_stats")

	if base_stats then
    heal = heal * base_stats:GetHealPower()
    mana = mana * base_stats:GetHealPower()
  end

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
		self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
		self.ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do
    unit:Heal(heal, self.ability)
    unit:GiveMana(mana)
	end

  if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("interval")) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_3_modifier_totem:PlayEfxStart(target)
	local eruption_string = "particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_eruption_dc.vpcf"
	local eruption_pfx = ParticleManager:CreateParticle(eruption_string, PATTACH_CUSTOMORIGIN, self.parent)
	ParticleManager:SetParticleControl(eruption_pfx, 0, self.parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(eruption_pfx)

	local ambient_string = "particles/econ/items/juggernaut/jugg_fall20_immortal/jugg_fall20_immortal_healing_ward.vpcf"
	self.ambient = ParticleManager:CreateParticle(ambient_string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.ambient, 0, self.parent:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:SetParticleControl(self.ambient, 1, Vector(self.ability:GetAOERadius(), 1, 1))
	ParticleManager:SetParticleControlEnt(self.ambient, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)

	if IsServer() then self.parent:EmitSound("Hero_Juggernaut.FortunesTout.Loop") end
end