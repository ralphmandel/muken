mk_root = class({})
LinkLuaModifier("mk_root_modifier", "bosses/mk_root_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)

function mk_root:CalcStatus(duration, caster, target)
    local time = duration
	local base_stats_caster = nil
	local base_stats_target = nil

    if caster ~= nil then
		base_stats_caster = caster:FindAbilityByName("base_stats")
	end

	if target ~= nil then
		base_stats_target = target:FindAbilityByName("base_stats")
	end

	if caster == nil then
		if target ~= nil then
			if base_stats_target then
				local value = base_stats_target.stat_total["RES"] * 0.4
				local calc = (value * 6) / (1 +  (value * 0.06))
				time = time * (1 - (calc * 0.01))
			end
		end
	else
		if target == nil then
			if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
			else
				if base_stats_caster and base_stats_target then
					local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
					if value > 0 then
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 + (calc * 0.01))
					else
						value = -1 * value
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 - (calc * 0.01))
					end
				end
			end
		end
	end

    if time < 0 then time = 0 end
    return time
end

function mk_root:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	local radius_impact = self:GetSpecialValueFor("radius_impact")
	local damage_impact = self:GetSpecialValueFor("damage_impact")

	self:PlayEfxStart(radius_impact)

	local damageTable = {
		--victim = ,
		attacker = caster,
		damage = damage_impact,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self
	}

	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetOrigin(), nil, radius_impact,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,unit in pairs(units) do
		damageTable.victim = unit
		ApplyDamage(damageTable)
	end

	local find = 0
	local heroes = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
	)

	for _,hero in pairs(heroes) do
		hero:AddNewModifier(caster, self, "mk_root_modifier", {
			duration = self:CalcStatus(duration, caster, hero)
		})

		find = find + 1
		if find > 1 then break end
	end

	local mod_ai = caster:FindModifierByName("_boss_modifier__ai")
	if mod_ai == nil then return end
	local units = FindUnitsInRadius(
		caster:GetTeam(), caster:GetAbsOrigin(), nil, mod_ai.aggroRange,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do
		if unit:IsIllusion() == false then
			caster:MoveToTargetToAttack(unit)
			caster:SetAggroTarget(unit)
			break
		end
	end
end

function mk_root:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if not hTarget then return end
	if hTarget:IsInvulnerable() then return end
	local damage = ExtraData.damage
	local caster = self:GetCaster()

	hTarget:Heal(damage, self)
	self:PlayEfxHeal(hTarget)
end

-----------------------------------------------------------

function mk_root:PlayEfxStart(radius_impact)
	local caster = self:GetCaster()
	local particle = "particles/econ/items/centaur/centaur_ti6/centaur_ti6_warstomp.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(effect, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(radius_impact, 0, 0))

	if IsServer() then caster:EmitSound("Hero_EarthShaker.Totem") end
end

function mk_root:PlayEfxHeal(target)
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)

	--if IsServer() then target:EmitSound("Druid.Seed.Heal") end
end