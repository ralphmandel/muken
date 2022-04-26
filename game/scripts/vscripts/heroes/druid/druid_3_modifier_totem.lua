druid_3_modifier_totem = class({})

function druid_3_modifier_totem:IsHidden()
	return false
end

function druid_3_modifier_totem:IsPurgable()
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

--------------------------------------------------------------------------------

function druid_3_modifier_totem:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.movespeed = self.ability:GetSpecialValueFor("movespeed")
	self.hits = self.ability:GetSpecialValueFor("hits")
	self.no_bar = true

	-- UP 3.11
	if self.ability:GetRank(11) then
		self.movespeed = self.movespeed + 100
	end

	-- UP 3.12
	if self.ability:GetRank(12) then
		self.hits = self.hits + 5
	end

	Timers:CreateTimer((0.1), function()
		self.parent:ModifyHealth(self.parent:GetMaxHealth(), self.ability, false, 0)
		self.min_health = self.parent:GetMaxHealth()
		self.no_bar = false
	end)

	if IsServer() then
		self:PlayEfxStart()
	end
end

function druid_3_modifier_totem:OnRefresh(kv)
end

function druid_3_modifier_totem:OnRemoved()
	if IsValidEntity(self.parent) then
		if self.parent:IsAlive() then
			self.parent:Kill(self.ability, nil)
		end

		if IsServer() then
			self.parent:StopSound("Hero_Juggernaut.HealingWard.Loop")
			self.parent:EmitSound("Hero_Juggernaut.HealingWard.Stop")
		end
	end
end

--------------------------------------------------------------------------------

function druid_3_modifier_totem:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = self.no_bar
	}

	return state
end

function druid_3_modifier_totem:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MIN_HEALTH
	}

	return funcs
end

function druid_3_modifier_totem:OnDeath(keys)
	if keys.unit == self.parent then
		self:Destroy()
	end
end

function druid_3_modifier_totem:GetModifierExtraHealthBonus()
    return self.hits - 1
end

function druid_3_modifier_totem:GetModifierIgnoreMovespeedLimit()
	return 1
end


function druid_3_modifier_totem:GetModifierMoveSpeed_Limit()
	return self.movespeed
end


function druid_3_modifier_totem:GetModifierMoveSpeed_AbsoluteMin()
	return self.movespeed
end

function druid_3_modifier_totem:GetModifierMoveSpeedOverride()
	return self.movespeed
end


function druid_3_modifier_totem:GetVisualZDelta(keys)
	return 100
end

function druid_3_modifier_totem:GetDisableHealing(keys)
	return 1
end

function druid_3_modifier_totem:GetMinHealth(keys)
	return self.min_health or 0
end

function druid_3_modifier_totem:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	self.min_health = self.min_health - 1
end

--------------------------------------------------------------------------------

function druid_3_modifier_totem:PlayEfxStart()
	local string = "particles/druid/druid_skill3_totem.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.ability:GetAOERadius(), 0, 0))
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Juggernaut.HealingWard.Loop") end
end