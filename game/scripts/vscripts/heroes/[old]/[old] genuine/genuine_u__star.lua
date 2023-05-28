genuine_u__star = class({})
LinkLuaModifier("genuine_u_modifier_star", "heroes/team_moon/genuine/genuine_u_modifier_star", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function genuine_u__star:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    if BaseHeroMod(caster) then BaseHeroMod(caster):ChangeActivity("") end

    local particle_cast = "particles/genuine/ult_caster/genuine_ult_caster.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(effect_cast)

    return true
  end

  function genuine_u__star:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    if BaseHeroMod(caster) then BaseHeroMod(caster):ChangeActivity("ti6") end
  end

  function genuine_u__star:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if BaseHeroMod(caster) then BaseHeroMod(caster):ChangeActivity("ti6") end
    if target:TriggerSpellAbsorb(self) then return end

    self:PlayEfxStart(caster, target)
    self:PlayEfxStart(target, caster)

    if IsServer() then target:EmitSound("Hero_Terrorblade.DemonZeal.Cast") end

    if target:IsIllusion() then target:ForceKill(false) return end

    target:Purge(true, false, false, false, false)
    caster:AddNewModifier(caster, self, "genuine_u_modifier_star", {duration = self:GetSpecialValueFor("duration")})
    target:AddNewModifier(caster, self, "genuine_u_modifier_star", {duration = self:GetSpecialValueFor("duration")})
  end

  function genuine_u__star:CreateStarfall(target)
		local caster = self:GetCaster()
		local point = target:GetOrigin()
		self:PlayEfxStarfall(target)

		Timers:CreateTimer(self:GetSpecialValueFor("starfall_delay"), function()
			local enemies = FindUnitsInRadius(
				caster:GetTeamNumber(), point, nil,
				self:GetSpecialValueFor("starfall_radius"),
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
			)
		
			for _,enemy in pairs(enemies) do
				if IsServer() then
					enemy:EmitSound("Hero_Mirana.Starstorm.Impact")
					break
				end
			end

			for _,enemy in pairs(enemies) do
				ApplyDamage({
					attacker = caster, victim = enemy,
					damage = self:GetSpecialValueFor("starfall_damage"),
					damage_type = DAMAGE_TYPE_MAGICAL, ability = self
				})
			end		
		end)
	end

-- EFFECTS

  function genuine_u__star:PlayEfxStart(hero_1, hero_2)
    local particle_cast = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, hero_2)
    ParticleManager:SetParticleControlEnt(effect_cast, 0, hero_1, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControlEnt(effect_cast, 1, hero_2, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControl(effect_cast, 60, Vector(125, 0, 175))
    ParticleManager:SetParticleControl(effect_cast, 61, Vector(1, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect_cast)
  end

  function genuine_u__star:PlayEfxStarfall(target)
		local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
		ParticleManager:ReleaseParticleIndex(effect_cast)

		if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Cast") end
	end