bloodstained_2_modifier_bloodsteal = class({})

function bloodstained_2_modifier_bloodsteal:IsHidden()
	return false
end

function bloodstained_2_modifier_bloodsteal:IsPurgable()
    return false
end

function bloodstained_2_modifier_bloodsteal:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.extra_life = 0

    self.lifesteal_base = self:GetAbility():GetSpecialValueFor("lifesteal_base") * 0.01
    self.lifesteal_bonus = self:GetAbility():GetSpecialValueFor("lifesteal_bonus") * 0.01

	if IsServer() then
		self:SetStackCount(self.extra_life)
		self:StartIntervalThink(0.2)
		local void = self.parent:FindAbilityByName("_void")
		if void ~= nil then void:SetLevel(1) end
	end
end

function bloodstained_2_modifier_bloodsteal:OnRefresh( kv )
	-- UP 2.21
	if self.ability:GetRank(21) then
		self.lifesteal_base = (self:GetAbility():GetSpecialValueFor("lifesteal_base") + 5) * 0.01
		self.lifesteal_bonus = (self:GetAbility():GetSpecialValueFor("lifesteal_bonus") - 5) * 0.01
	end

	local mod = self.parent:FindAllModifiersByName("base_stats_mod_crit_bonus")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	-- UP 2.41
	if self.ability:GetRank(41) then
		self.parent:AddNewModifier(self.caster, self.ability, "base_stats_mod_crit_bonus", {crit_damage = -20})
	end
end

function bloodstained_2_modifier_bloodsteal:OnRemoved()
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_2_LCK", self.parent)
end

--------------------------------------------------------------------------------------------------------------------------

function bloodstained_2_modifier_bloodsteal:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH
    }    
    return funcs
end

function bloodstained_2_modifier_bloodsteal:GetModifierHealthBonus()
    return self:GetStackCount()
end

function bloodstained_2_modifier_bloodsteal:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end

	local original_health = self.parent:GetMaxHealth() - self:GetStackCount()
	local current_health = self.parent:GetHealth()
	local diff = self.parent:GetHealth() - original_health
	self.extra_life = diff
	if self.extra_life < 0 then self.extra_life = 0 end

	if IsServer() then
		self:SetStackCount(self.extra_life)
		local void = self.parent:FindAbilityByName("_void")
		if void ~= nil then void:SetLevel(1) end
		self.parent:SetHealth(current_health)
	end
end

function bloodstained_2_modifier_bloodsteal:GetModifierPreAttack(keys)
	if self.parent:PassivesDisabled() then return end
	self.ability:RemoveBonus("_1_AGI", self.parent)

	local agi_bonus = self.ability:GetSpecialValueFor("agi_bonus")
	local agi_total = math.ceil(agi_bonus * (100 - self.parent:GetHealthPercent()) * 0.01)

	if agi_total > 0 then
		self.ability:AddBonus("_1_AGI", self.parent, agi_total, 0, nil)
	end		
end

function bloodstained_2_modifier_bloodsteal:OnAttacked(keys)
	if keys.attacker:IsIllusion() then return end
	if keys.attacker:IsHero() == false then return end
	if keys.attacker:GetTeamNumber() ~= self.parent:GetTeamNumber() then return end
	if keys.attacker ~= self.parent then
		if keys.attacker:HasModifier("bloodstained_u_modifier_status") == false then
			return
		end
	end

	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	-- UP 2.41
	if self.ability:GetRank(41)
	and keys.attacker == self.parent then
		local base_stats = keys.attacker:FindAbilityByName("base_stats")
		if base_stats then
			if base_stats.has_crit then
				local heal = keys.attacker:GetMaxHealth() * 0.02
				if heal > 0 then keys.attacker:Heal(heal, self.ability) end			
			end
		end
	end

	-- UP 2.21
	if self.ability:GetRank(21) == false then
		if self.parent:PassivesDisabled() then return end
	end

	local lifesteal = self.lifesteal_bonus * (100 - keys.attacker:GetHealthPercent()) * 0.01
	lifesteal = keys.original_damage * (self.lifesteal_base + lifesteal)

	-- UP 2.21
	if self.ability:GetRank(21)
	and keys.attacker == self.parent then
		if self.parent:GetHealthPercent() == 100 then
			local original_health = self.parent:GetMaxHealth() - self:GetStackCount()
			self.extra_life = self.extra_life + lifesteal
			if self.extra_life > (original_health * 0.25) then
				self.extra_life = original_health * 0.25
			end

			if IsServer() then
				self:SetStackCount(self.extra_life)
				local void = self.parent:FindAbilityByName("_void")
				if void ~= nil then void:SetLevel(1) end
			end
		end
	end

	keys.attacker:Heal(lifesteal, nil)
	self:PlayEfxHeal(keys.attacker, keys.target)
end

function bloodstained_2_modifier_bloodsteal:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.target:IsMagicImmune() then return end
	if self.parent:PassivesDisabled() then return end

	-- UP 2.42
	if self.ability:GetRank(42) then
		if RandomInt(1, 100) <= 17 then
			keys.target:AddNewModifier(self.caster, self.ability, "bloodstained_0_modifier_bleeding", {
				duration = self.ability:CalcStatus(5, self.caster, keys.target)
			})
		end
	end
end

function bloodstained_2_modifier_bloodsteal:OnDeath(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end

	-- UP 2.11
	if self.ability:GetRank(11) then
		local heal = self.parent:GetMaxHealth() * 0.1
		if keys.unit:IsHero() then heal = heal * 2 end

		self.parent:Heal(heal, self.ability)
		self:PlayEfxKillHeal(keys.unit)
	end
end

function bloodstained_2_modifier_bloodsteal:OnIntervalThink()
	-- UP 2.12
	if self.ability:GetRank(12) then
		local enemies = FindUnitsInRadius(
			self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, FIND_UNITS_EVERYWHERE,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
			0, 0, false
		)

		for _,enemy in pairs(enemies) do
			if enemy:GetHealthPercent() <= 20
			and enemy:IsInvisible() == false then
				enemy:AddNewModifier(self.caster, self.ability, "bloodstained_2_modifier_track", {duration = 0.5})
			end
		end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	-- UP 2.13
	if self.ability:GetRank(13)
	and self.parent:PassivesDisabled() == false then
		local percent = math.ceil((100 - self.parent:GetHealthPercent()) * 0.5)
		if percent > 0 then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {
				percent = percent
			})
		end
	end

	self.ability:RemoveBonus("_2_LCK", self.parent)

	-- UP 2.41
	if self.ability:GetRank(41)
	and self.parent:PassivesDisabled() == false then
		local luck = math.ceil((100 - self.parent:GetHealthPercent()) * 0.5)
		if luck > 0 then
			self.ability:AddBonus("_2_LCK", self.parent, luck, 0, nil)
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------

function bloodstained_2_modifier_bloodsteal:PlayEfxHeal(attacker, target)
	local particle_cast = "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	local particle_cast2 = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf"
    local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, attacker)
end

function bloodstained_2_modifier_bloodsteal:PlayEfxKillHeal(target)
	local particle_cast = "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self.parent:GetOrigin())

	local particle_cast2 = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf"
    local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
end