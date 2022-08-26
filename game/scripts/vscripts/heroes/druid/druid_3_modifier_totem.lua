druid_3_modifier_totem = class({})

function druid_3_modifier_totem:IsHidden()
	return false
end

function druid_3_modifier_totem:IsPurgable()
	return false
end

function druid_3_modifier_totem:IsDebuff()
	return false
end

function druid_3_modifier_totem:IsAura()
	return true
end

function druid_3_modifier_totem:GetModifierAura()
	return "druid_3_modifier_totem_effect"
end

function druid_3_modifier_totem:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function druid_3_modifier_totem:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function druid_3_modifier_totem:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_3_modifier_totem:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.min_health = self.parent:GetMaxHealth()
	self.disable_heal = 1
	self.ms = 0

	-- UP 3.11
	if self.ability:GetRank(11) then
		self.ms = 75
	end

	if IsServer() then
		self:PlayEfxStart()

		-- UP 3.41
		if self.ability:GetRank(41) then
			self:StartIntervalThink(2)
		end
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
		MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}

	return funcs
end

function druid_3_modifier_totem:OnHealReceived(keys)
    if keys.unit ~= self.parent then return end
    if keys.inflictor == nil then return end
    if keys.gain < 1 then return end

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
end

function druid_3_modifier_totem:OnDeath(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function druid_3_modifier_totem:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end

	self.min_health = self.min_health - 1
end

function druid_3_modifier_totem:GetDisableHealing()
	return self.disable_heal
end

function druid_3_modifier_totem:GetMinHealth()
	return self.min_health
end

function druid_3_modifier_totem:GetVisualZDelta()
	return 150
end

function druid_3_modifier_totem:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end

function druid_3_modifier_totem:OnIntervalThink()
	self:PlayEfxQuill()

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do
		self:PlayEfxQuillImpact(unit)
		
		unit:AddNewModifier(self.caster, self.ability, "druid_3_modifier_quill", {
			duration = self.ability:CalcStatus(5, self.caster, unit)
		})
	end
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

function druid_3_modifier_totem:PlayEfxQuill()
	local particle_cast = "particles/druid/druid_lotus/lotus_quill.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 10, Vector(self.ability:GetAOERadius(), 0, 0))
	ParticleManager:SetParticleControl(effect_cast, 61, Vector(1, 0, 1))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Bristleback.QuillSpray.Cast") end
end

function druid_3_modifier_totem:PlayEfxQuillImpact(target)
	local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_Bristleback.QuillSpray.Target") end
end