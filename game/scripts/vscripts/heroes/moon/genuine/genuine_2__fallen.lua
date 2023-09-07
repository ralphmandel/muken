genuine_2__fallen = class({})
LinkLuaModifier("genuine_2_modifier_fallen", "heroes/moon/genuine/genuine_2_modifier_fallen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear", "_modifiers/_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear_status_efx", "_modifiers/_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_truesight", "_modifiers/_modifier_truesight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "_modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)

-- INIT

  genuine_2__fallen.spawn_origin = {}

-- SPELL START

	function genuine_2__fallen:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local projectile_name = "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave.vpcf"
		local direction = point - caster:GetOrigin()
		direction.z = 0
		direction = direction:Normalized()

    --projectile_name = "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave_wide.vpcf"

		local projectile = ProjectileManager:CreateLinearProjectile({
			Source = caster,
			Ability = self,
			vSpawnOrigin = caster:GetAbsOrigin(),
			
			bDeleteOnHit = false,
			
			iUnitTargetTeam = self:GetAbilityTargetTeam(),
			iUnitTargetFlags = self:GetAbilityTargetFlags(),
			iUnitTargetType = self:GetAbilityTargetType(),
			
			EffectName = projectile_name,
			fDistance = self:GetSpecialValueFor("distance"),
			fStartRadius = self:GetSpecialValueFor("radius"),
			fEndRadius = self:GetSpecialValueFor("radius"),
			vVelocity = direction * self:GetSpecialValueFor("speed"),

			bProvidesVision = true,
			iVisionRadius = self:GetSpecialValueFor("radius"),
			iVisionTeamNumber = caster:GetTeamNumber()
		})

    self.spawn_origin[projectile] = caster:GetAbsOrigin()

		if IsServer() then caster:EmitSound("Hero_DrowRanger.Silence") end
	end

  function genuine_2__fallen:OnProjectileThinkHandle(iProjectileHandle)
    local radius = ProjectileManager:GetLinearProjectileRadius(iProjectileHandle)
    local loc = ProjectileManager:GetLinearProjectileLocation(iProjectileHandle)
    local trees = GridNav:GetAllTreesAroundPoint(loc, radius, true)
		local caster = self:GetCaster()

    if trees then
      for _,tree in pairs(trees) do
        tree:CutDown(caster:GetTeamNumber())
      end      
    end
  end

	function genuine_2__fallen:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
		if not hTarget then self.spawn_origin[iProjectileHandle] = nil return end

		local caster = self:GetCaster()
    if hTarget == caster then return end

    local distance_percent = 1 - ((self.spawn_origin[iProjectileHandle] - vLocation):Length2D() / self:GetSpecialValueFor("distance"))
    if distance_percent < 0 then distance_percent = 0 end

    local min = 0.5 
    local fear_duration = ((self:GetSpecialValueFor("fear_duration") - min) * distance_percent) + min

    AddModifier(hTarget, self, "genuine_2_modifier_fallen", {duration = fear_duration}, true)
	end

-- EFFECTS

