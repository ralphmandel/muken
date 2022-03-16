inquisitor_3_modifier_blow = class({})

--------------------------------------------------------------------------------

function inquisitor_3_modifier_blow:IsHidden()
	return false
end

function inquisitor_3_modifier_blow:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function inquisitor_3_modifier_blow:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.reduction =  self.ability:GetSpecialValueFor("reduction")
	self.hits = self.ability:GetSpecialValueFor("hits")
	self.autocast = kv.autocast
	self.start = true
	self.invulnerable = false

	-- UP 3.3
	if self.ability:GetRank(3) then
		self.hits = self.ability:GetSpecialValueFor("hits") + 1
	end

	if self.ability.target then
		if IsValidEntity(self.ability.target) then
			if self.ability.target:IsMagicImmune() == false then
				self.ability.target:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
					duration = self.hits * 0.15,
					percent = 100,
				})
			end
		end
	end

    -- UP 3.5
    if self.ability:GetRank(5)
	and self.autocast == 0 then
		self:PlayEfxInvulnerable()
		self.invulnerable = true
	end

	if IsServer() then
		self:SetStackCount(self.hits)
		self:StartIntervalThink(0.2)
	end
end

function inquisitor_3_modifier_blow:OnRefresh( kv )
end

function inquisitor_3_modifier_blow:OnRemoved()
	if self.particle ~= nil then ParticleManager:DestroyParticle(self.particle, false) end
	self.parent:RemoveModifierByName("inquisitor_3_modifier_speed")
	self.ability:RemoveBonus("_1_AGI", self.parent)

	if self.ability.target then
		if IsValidEntity(self.ability.target) then
			local mod = self.ability.target:FindAllModifiersByName("_modifier_movespeed_debuff")
			for _,modifier in pairs(mod) do
				if modifier:GetAbility() == self.ability then modifier:Destroy() end
			end
		end
	end
end

--------------------------------------------------------------------------------

function inquisitor_3_modifier_blow:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_MISS] = self.start,
		[MODIFIER_STATE_INVULNERABLE] = self.invulnerable
	}

	return state
end

function inquisitor_3_modifier_blow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACKED
	}
	
	return funcs
end

function inquisitor_3_modifier_blow:GetModifierOverrideAttackDamage(keys)
	if keys.attacker ~= self.parent then return 0 end
	if self.start == false then return 0 end

	-- UP 3.2
	if self.ability:GetRank(2) then
		return 1
	end
end

function inquisitor_3_modifier_blow:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end
	if self.ability.target == nil then self:Destroy() return end
	if IsValidEntity(self.ability.target) == false then self:Destroy() return end
	if self.ability.target ~= keys.target then self:Destroy() return end
	if self.start == true then self:Destroy() return end

	self.hits = self.hits - 1
	if self.hits < 1 then self:Destroy() return end
	if IsServer() then self:SetStackCount(self.hits) end
end

function inquisitor_3_modifier_blow:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeam() == self.parent:GetTeam() then self:Destroy() return end
	if self.ability.target == nil then self:Destroy() return end
	if IsValidEntity(self.ability.target) == false then self:Destroy() return end
	if self.ability.target ~= keys.target then self:Destroy() return end
	self.parent:MoveToTargetToAttack(keys.target)

	if self.start == true then
		-- UP 3.1
		if self.ability:GetRank(1) then
			local knockbackProperties =
			{
				duration = 0.25,
				knockback_duration = 0.25,
				knockback_distance = 100,
				center_x = self.parent:GetAbsOrigin().x + 1,
				center_y = self.parent:GetAbsOrigin().y + 1,
				center_z = self.parent:GetAbsOrigin().z,
				knockback_height = 15,
			}

			keys.target:AddNewModifier(self.caster, nil, "modifier_knockback", knockbackProperties)
			if IsServer() then keys.target:EmitSound("Hero_Spirit_Breaker.Charge.Impact") end
		end

		-- UP 3.2
		if self.ability:GetRank(2) then
			self:CastAftershake(keys.target)
		end

		self:PlayEfxSonic()
	end

    -- UP 3.4
    if self.ability:GetRank(4) then
		local heal = self.parent:GetAttackDamage() * 0.5
		if heal > 0 then self.parent:Heal(heal, nil) end
		self:PlayEfxLifesteal()
	end

	self.start = false
	self.hits = self.hits - 1
	if self.hits < 1 then self:Destroy() return end
	if IsServer() then self:SetStackCount(self.hits) end
end

function inquisitor_3_modifier_blow:GetModifierDamageOutgoing_Percentage(keys)
	if keys.attacker ~= self.parent then return 0 end
	return -self.reduction
end

function inquisitor_3_modifier_blow:GetModifierAttackRangeBonus()
    return 150
end

function inquisitor_3_modifier_blow:OnIntervalThink()
	if self.parent:IsAttacking() then self:StartIntervalThink(0.1) return end
	self:Destroy()
end

function inquisitor_3_modifier_blow:CastAftershake(target)
	local radius = 300
	local crit = 1

	local str_mod = self.parent:FindModifierByName("_1_STR_modifier")
	if str_mod then
		if str_mod:HasCritical() then
			crit = str_mod:GetCriticalDamage()
		end
	end

	local damageTable = {
		victim = nil,
		attacker = self.parent,
		damage = self.parent:GetAttackDamage() * crit,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self.ability
	}

	local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),	-- int, your team number
        self.parent:GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
		if IsServer() then enemy:EmitSound("Hero_Juggernaut.BladeDance") end
    end

    GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), radius, true)
	self:PlayEfxShake(radius)
end

-----------------------------------------------------------------------------

function inquisitor_3_modifier_blow:PlayEfxSonic()
	local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn_v2.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Hero_Centaur.DoubleEdge") end
end

function inquisitor_3_modifier_blow:PlayEfxShake(radius)
	local particle_cast = "particles/econ/items/centaur/centaur_ti6_gold/centaur_ti6_warstomp_gold.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, 0, 0))

	if IsServer() then self.parent:EmitSound("Hero_EarthShaker.Totem") end
end

function inquisitor_3_modifier_blow:PlayEfxLifesteal()
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function inquisitor_3_modifier_blow:PlayEfxInvulnerable()
	-- Invulnerable
	local particle = "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf"
	if self.particle ~= nil then ParticleManager:DestroyParticle(self.particle, false) end
	self.particle = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetOrigin())
end