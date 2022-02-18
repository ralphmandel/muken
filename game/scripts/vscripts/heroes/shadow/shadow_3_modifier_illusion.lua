shadow_3_modifier_illusion = class({})

function shadow_3_modifier_illusion:IsHidden()
	return true
end

function shadow_3_modifier_illusion:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function shadow_3_modifier_illusion:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	
	self.bar = false
	self.stop = false
	self.hidden = true
	self.aggro = nil
	self.aspd = kv.aspd
	self.radius = 600
	self.ms = 0

	-- UP 3.3
	if self.ability:GetRank(3) then
		self.ms = 50
	end

	-- Dominated Shadow
	if kv.ignore_order == 0 then
		self.ignore = false
		self.parent:SetDayTimeVisionRange(400)
		self.parent:SetNightTimeVisionRange(300)
		self:PlayEfxControl()
	end

	-- Regular Shadow
	if kv.ignore_order == 1 then
		self.ignore = true
		self.parent:SetDayTimeVisionRange(150)
		self.parent:SetNightTimeVisionRange(150)
	end

	-- Pursuit Shadow
	if kv.ignore_order == 2 then
		self.bar = true
		self.ms = 50
		self.radius = FIND_UNITS_EVERYWHERE
		self.ignore = true
		self.parent:SetDayTimeVisionRange(150)
		self.parent:SetNightTimeVisionRange(150)
		self:PlayEfxShadow()
	end

	self:StartIntervalThink(0.25)
end

function shadow_3_modifier_illusion:OnRefresh(kv)
	self.aspd = kv.aspd

	-- Dominated Shadow
	if kv.ignore_order == 0 then
		self.ignore = false
		self.parent:SetDayTimeVisionRange(400)
		self.parent:SetNightTimeVisionRange(300)
		self:PlayEfxControl()
	end
end

function shadow_3_modifier_illusion:OnRemoved( kv )
	if self.ignore == false then
		-- UP 3.7
		local second_shadow = self.caster:FindAbilityByName("shadow_3__second_shadow")
		if second_shadow then
			if second_shadow:IsTrained() then
				second_shadow:SetActivated(true)
			end
		end
	end

	if self.effect_cast  then ParticleManager:DestroyParticle(self.effect_cast, false) end
	if self.paticle_ctrl then ParticleManager:DestroyParticle(self.paticle_ctrl, false) end

	if self.parent:IsAlive() then
		self.parent:Kill(self.ability, nil)
	end
end

--------------------------------------------------------------------------------

function shadow_3_modifier_illusion:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = self.bar,
		[MODIFIER_STATE_UNTARGETABLE] = self.bar,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = self.ignore,
		[MODIFIER_STATE_INVISIBLE] = self.hidden,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true
	}

	return state
end

function shadow_3_modifier_illusion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE
	}
	
	return funcs
end

function shadow_3_modifier_illusion:GetModifierInvisibilityLevel()
	return 0
end

function shadow_3_modifier_illusion:GetModifierMoveSpeedBonus_Percentage(target)
	return self.ms
end

function shadow_3_modifier_illusion:GetModifierFixedAttackRate()
	return self.aspd * 0.01
end

function shadow_3_modifier_illusion:GetModifierProcAttack_Feedback(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.target:IsMagicImmune() then return end
	if keys.target:HasModifier("shadow_0_modifier_poison") then return end
	if self.parent:PassivesDisabled() then return end

	-- UP 3.3
	if self.ability:GetRank(3) then
		keys.target:AddNewModifier(self.caster, self.ability, "shadow_0_modifier_poison", {})
		self:PlayEfxHit(keys.target)
	end
end

--------------------------------------------------------------------------------

function shadow_3_modifier_illusion:CheckInvisibleMode()
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 300,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
		16, 1, false
	)

	local find = false
	for _,enemy in pairs(enemies) do
		find = true
	end

	if find then
		self.hidden = false
	else
		self.hidden = true
	end
end

function shadow_3_modifier_illusion:CheckPoisonedUnits()
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		16, 1, false
	)

	local aggro = nil
	for _,enemy in pairs(enemies) do
		if aggro ~= nil then break end
		if enemy:IsHero() and enemy:HasModifier("shadow_0_modifier_poison") then
			aggro = enemy
		end
	end
	
	for _,enemy in pairs(enemies) do
		if aggro ~= nil then break end
		if enemy:HasModifier("shadow_0_modifier_poison") then
			aggro = enemy
		end
	end

	if aggro == nil and self.radius == FIND_UNITS_EVERYWHERE then
		self:Destroy()
		return
	end

	if aggro == nil and self.stop == false then
		--self.parent:MoveToPosition(self.parent:GetOrigin())
		self.stop = true
		return
	else
		self.stop = false
	end

	if self.aggro == nil then
		self.aggro = aggro
		if self.radius == FIND_UNITS_EVERYWHERE then
			self.parent:SetForceAttackTarget(self.aggro)
		else
			self.parent:MoveToTargetToAttack(self.aggro)
		end
		return
	end

	if self.aggro ~= aggro then
		self.aggro = aggro
		if self.radius == FIND_UNITS_EVERYWHERE then
			self.parent:SetForceAttackTarget(self.aggro)
		else
			self.parent:MoveToTargetToAttack(self.aggro)
		end
		return
	end
end

function shadow_3_modifier_illusion:OnIntervalThink()
	-- UP 3.3
	if self.ability:GetRank(3) then
		self.ms = 50
	end
	
	if self.ignore == true then
		self:CheckPoisonedUnits()
	end

	self:CheckInvisibleMode()
end

--------------------------------------------------------------------------------

function shadow_3_modifier_illusion:PlayEfxShadow()
    local particle_cast = "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner.vpcf"
    self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetOrigin() )

	if IsServer() then self.parent:EmitSound("Hero_Magnataur.ReversePolarity.Cast") end
end

function shadow_3_modifier_illusion:PlayEfxControl()
	if self.paticle_ctrl then ParticleManager:DestroyParticle(self.paticle_ctrl, false) end

	local particle_cast = "particles/econ/items/grimstroke/gs_fall20_immortal/gs_fall20_immortal_soul_marker.vpcf"
	self.paticle_ctrl = ParticleManager:CreateParticleForTeam(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent, self.caster:GetTeamNumber())
	ParticleManager:SetParticleControlEnt(self.paticle_ctrl, 3, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.paticle_ctrl, 4, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetOrigin(), true)
	self:AddParticle(self.paticle_ctrl, false, false, -1, false, true)

	if IsServer() then EmitSoundOnLocationForAllies(self.parent:GetOrigin(), "Hero_ElderTitan.AncestralSpirit.Cast", self.caster) end
end

function shadow_3_modifier_illusion:PlayEfxHit(target)
	local effect = ParticleManager:CreateParticle("particles/bioshadow/bioshadow_poison_hit.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(100, 0, 0))
	if IsServer() then target:EmitSound("Hero_Bioshadow.Poison") end
end