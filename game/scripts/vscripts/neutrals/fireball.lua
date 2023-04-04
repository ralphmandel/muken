fireball = class({})
LinkLuaModifier("fireball_modifier", "neutrals/fireball_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

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
	

	hTarget:AddNewModifier(self.caster, self, "fireball_modifier", {
		duration = CalcStatus(flame_duration, self.caster, hTarget)
	})

	hTarget:AddNewModifier(self.caster, self, "_modifier_stun", {
		duration = CalcStatus(stun_duration, self.caster, hTarget)
	})

	ApplyDamage(damageTable)
end