fireball = class({})
LinkLuaModifier("fireball_modifier", "neutrals/fireball_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

function fireball:CalcStatus(duration, caster, target)
    local time = duration
	local caster_int = nil
    local caster_mnd = nil
	local target_res = nil

    if caster ~= nil then
		caster_int = caster:FindModifierByName("_1_INT_modifier")
		caster_mnd = caster:FindModifierByName("_2_MND_modifier")
	end

	if target ~= nil then
		target_res = target:FindModifierByName("_2_RES_modifier")
	end

	if caster == nil then
		if target ~= nil then
			if target_res then time = time * (1 - target_res:GetStatus()) end
		end
	else
		if target == nil then
			if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
			else
				if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
				if target_res then time = time * (1 - target_res:GetStatus()) end
			end
		end
	end

    if time < 0 then time = 0 end
    return time
end

function fireball:OnSpellStart()
    self.caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local projectile_name = "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj.vpcf"
	local projectile_vision = 150
	local projectile_speed = 1200

	-- Create Projectile
	local info = {
		Target = target,
		Source = self.caster,
		Ability = self,	
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bReplaceExisting = false,                         -- Optional
		bProvidesVision = true,                           -- Optional
		iVisionRadius = projectile_vision,				-- Optional
		iVisionTeamNumber = self.caster:GetTeamNumber()        -- Optional
	}

	ProjectileManager:CreateTrackingProjectile(info)
	if IsServer() then self.caster:EmitSound("Hero_Huskar.Burning_Spear.Cast") end
end

function fireball:OnProjectileHit(hTarget, vLocation)

	if hTarget == nil then return end
	if hTarget:IsInvulnerable() or hTarget:IsMagicImmune() then return end
	if hTarget:TriggerSpellAbsorb( self ) then return end
	if self.caster == nil then return end

	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local flame_duration = self:GetSpecialValueFor("flame_duration")
	local fireball_damage = self:GetSpecialValueFor("fireball_damage")

	local damageTable = {
        victim = hTarget,
        attacker = self.caster,
        damage = fireball_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self
    }
	
	ApplyDamage(damageTable)

	if hTarget:IsAlive() then
		hTarget:AddNewModifier(self.caster, self, "fireball_modifier", {
			duration = self:CalcStatus(flame_duration, self.caster, hTarget)
		})
		hTarget:AddNewModifier(self.caster, self, "_modifier_stun", {
			duration = self:CalcStatus(stun_duration, self.caster, hTarget)
		})
	end
end

function fireball:OnOwnerDied()
	local caster = self:GetCaster()
	local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
	self.caster = nil

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		flags,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		enemy:RemoveModifierByName("fireball_modifier")
	end
end