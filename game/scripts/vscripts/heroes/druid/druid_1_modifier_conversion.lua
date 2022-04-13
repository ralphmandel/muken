druid_1_modifier_conversion = class ({})

function druid_1_modifier_conversion:IsHidden()
    return false
end

function druid_1_modifier_conversion:IsPurgable()
    return false
end

-----------------------------------------------------------

function druid_1_modifier_conversion:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.death_impact = false
	self.bonus_damage = 0
	self.extra_hp = kv.extra_hp

	-- UP 1.21
	if self.ability:GetRank(21) then
		self.death_impact = true
	end

	-- UP 1.31
	if self.ability:GetRank(31) then
		self.bonus_damage = 25
		self.parent:SetModelScale(self.parent:GetModelScale() * 1.25)

		local void = self.caster:FindAbilityByName("_void")
		if void then void:SetLevel(1) end
	end

	-- if IsServer() then
	-- 	self:SetStackCount(kv.bonus_hp)
	-- end

	self.parent:SetTeam(self.caster:GetTeamNumber())
	self.parent:SetOwner(self.caster)
	self.parent:SetControllableByPlayer(self.caster:GetPlayerOwnerID(), true)
	self.parent:Heal(9999, self.ability)
	self:PlayEfxStart()
end

function druid_1_modifier_conversion:OnRefresh(kv)
end

function druid_1_modifier_conversion:OnRemoved(kv)
	if IsValidEntity(self.parent) then
        if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
		if self.parent:IsAlive() then
			self.parent:ForceKill(false)
		else
			self:DoExplosion(self.death_impact)
		end
	end
end

------------------------------------------------------------

function druid_1_modifier_conversion:CheckState()
	local state = {
		[MODIFIER_STATE_DOMINATED] = true
	}

	return state
end

function druid_1_modifier_conversion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
	}

	return funcs
end

function druid_1_modifier_conversion:GetModifierPreAttack_BonusDamage(keys)
	return self.bonus_damage
end

function druid_1_modifier_conversion:GetModifierExtraHealthBonus()
    return self.extra_hp
end

function druid_1_modifier_conversion:DoExplosion(bool)
	if bool == false then return end
	local radius = 350
	local slow_percent = 100
	local slow_duration = 2

	self:PlayEfxBlast()

	local damageTable = {
		damage = 125 + (self.parent:GetLevel() * 25),
		attacker = self.caster,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,	0, false
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
			percent = slow_percent,
			duration = self.ability:CalcStatus(slow_duration, self.caster, enemy)
		})

		damageTable.victim = enemy
		ApplyDamage(damageTable)
	end
end

--------------------------------------------------------------------------------

function druid_1_modifier_conversion:PlayEfxStart()
	self.effect_cast = ParticleManager:CreateParticle("particles/druid/druid_skill1_convert.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	self:AddParticle(self.effect_cast, false, false, -1, false, false)
end

function druid_1_modifier_conversion:PlayEfxBlast()
    local particle_cast = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
end