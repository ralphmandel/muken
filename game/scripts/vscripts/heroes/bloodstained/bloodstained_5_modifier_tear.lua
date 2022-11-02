bloodstained_5_modifier_tear = class({})

function bloodstained_5_modifier_tear:IsHidden()
	return true
end

function bloodstained_5_modifier_tear:IsPurgable()
	return false
end

function bloodstained_5_modifier_tear:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_5_modifier_tear:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	local time = 0

	self.tick = self.ability:GetSpecialValueFor("tick")
	self.blood_duration = self.ability:GetSpecialValueFor("blood_duration")

	-- UP 5.22
	if self.ability:GetRank(22) then
		self.ability:AddBonus("_2_LCK", self.parent, 5, 0, nil)	
	end

	-- UP 5.41
	if self.ability:GetRank(41) then
		self.blood_duration = self.blood_duration + 10
		time = self.blood_duration

		self.start = true
		ApplyDamage({
			attacker = self.caster, victim = self.parent, ability = self.ability,
			damage = 500, damage_type = DAMAGE_TYPE_PURE,
			damage_flags = 	DOTA_DAMAGE_FLAG_NON_LETHAL
		})
	end

	if IsServer() then
		self:PlayEfxStart(self.ability:GetAOERadius(), time)
		self:StartIntervalThink(self.tick)
	end
end

function bloodstained_5_modifier_tear:OnRefresh(kv)
end

function bloodstained_5_modifier_tear:OnRemoved()
	if self.particle then ParticleManager:DestroyParticle(self.particle, true) end
	self.ability:RemoveBonus("_2_LCK", self.parent)
	self:PullBlood()

	if IsServer() then self.parent:StopSound("Hero_Boodseeker.Bloodmist") end
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_5_modifier_tear:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bloodstained_5_modifier_tear:OnTakeDamage(keys)
	if CalcDistanceBetweenEntityOBB(self.parent, keys.unit) <= self.ability:GetAOERadius() then
		self:CreateBlood(keys.unit, keys.damage, keys.unit:GetAbsOrigin())

		-- UP 5.22
		if self.ability:GetRank(22) then
			self:ApplyHaemorrhage(keys)
		end
	end
end

function bloodstained_5_modifier_tear:OnIntervalThink()
	local hp_lost = self.ability:GetSpecialValueFor("hp_lost")

	-- UP 5.11
	if self.ability:GetRank(11) then
		hp_lost = hp_lost + 0.5
	end

	local damage = self.parent:GetMaxHealth() * hp_lost * 0.01

	local damage_result = ApplyDamage({
		attacker = self.caster, victim = self.parent, ability = self.ability,
		damage = damage, damage_type = DAMAGE_TYPE_PURE,
		damage_flags = 	DOTA_DAMAGE_FLAG_NON_LETHAL
	})

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,enemy in pairs(enemies) do
		ApplyDamage({
			attacker = self.caster, victim = enemy, ability = self.ability,
			damage = damage, damage_type = self.ability:GetAbilityDamageType(),
			damage_flags = 	DOTA_DAMAGE_FLAG_NON_LETHAL
		})
	end

	if IsServer() then self:StartIntervalThink(self.tick) end
end

-- UTILS -----------------------------------------------------------

function bloodstained_5_modifier_tear:ApplyHaemorrhage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	
	local base_stats_target = keys.attacker:FindAbilityByName("base_stats")
	if base_stats_target == nil then return end
	if base_stats_target.has_crit ~= true then return end

	local point = (self.parent:GetAbsOrigin() - keys.unit:GetAbsOrigin()):Normalized()
	self:CreateBlood(keys.unit, keys.damage, keys.unit:GetAbsOrigin() - (point * 175))
	self:CreateBlood(keys.unit, keys.damage, keys.unit:GetAbsOrigin() - (point * 350))
	self:PlayEfxHaemorrhage(self.parent, keys.unit)
end

function bloodstained_5_modifier_tear:CreateBlood(target, damage, origin)
	if self.start then damage = damage * 5 end
	local point = origin + RandomVector(RandomInt(0, 75))

	local blood_thinker = CreateModifierThinker(
		self.caster, self.ability, "bloodstained_5_modifier_blood",
		{duration = self.blood_duration, damage = damage},
		point, self.parent:GetTeamNumber(), false
	)

	if self.start then self.start = nil return end
	self:PlayEfxStartBlood(blood_thinker, point, damage)
end

function bloodstained_5_modifier_tear:PullBlood()
	local total_blood = 0
	local thinkers = Entities:FindAllByClassname("npc_dota_thinker")

	for _,blood in pairs(thinkers) do
		if blood:GetOwner() == self.caster then
			total_blood = total_blood + self:ProcessBlood(blood)
			self:PlayEfxPull(blood)
			blood:Destroy()
		end
	end

    local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then total_blood = total_blood * base_stats:GetHealPower() end

	if total_blood >= 1 then
		self.parent:Heal(total_blood, self.ability)
		self:PlayEfxHeal()
	end
end

function bloodstained_5_modifier_tear:ProcessBlood(blood)
	local mod = blood:FindModifierByName("bloodstained_5_modifier_blood")
	if mod == nil then return 0 end
	return mod.damage
end

-- EFFECTS -----------------------------------------------------------

function bloodstained_5_modifier_tear:PlayEfxStart(radius, time)
	local string_1 = "particles/bloodstained/tear/bloodstained_tear_initial.vpcf"
	self.particle = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.particle, 10, Vector(time, 0, 0))
	self:AddParticle(self.particle, false, false, -1, false, false)

	local string_2 = "particles/units/heroes/hero_bloodseeker/bloodseeker_scepter_blood_mist_aoe.vpcf"
	local particle_2 = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle_2, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle_2, 1, Vector(radius, radius, radius))
	self:AddParticle(particle_2, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Boodseeker.Bloodmist") end
end

function bloodstained_5_modifier_tear:PlayEfxStartBlood(blood_thinker, point, damage)
	local blood_mod = blood_thinker:FindModifierByNameAndCaster("bloodstained_5_modifier_blood", self.caster)
	local blood_percent = self.ability:GetSpecialValueFor("blood_percent") * 0.01
	local amount = math.floor(damage * blood_percent * 0.6)

	local particle_cast = "particles/bloodstained/bloodstained_x2_blood.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, blood_thinker)
    ParticleManager:SetParticleControl(effect_cast, 1, point)
    ParticleManager:SetParticleControl(effect_cast, 5, Vector(amount, amount, point.z))

	if blood_mod then blood_mod:AddParticle(effect_cast, false, false, -1, false, false) end
end

function bloodstained_5_modifier_tear:PlayEfxPull(blood)
	local particle_cast = "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, blood:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 2, self.parent:GetOrigin())
end

function bloodstained_5_modifier_tear:PlayEfxHeal()
	local particle_cast = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)

	local particle_cast_2 = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
	local effect = ParticleManager:CreateParticle(particle_cast_2, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(500, 0, 0))

	if IsServer() then self.parent:EmitSound("Hero_Undying.SoulRip.Cast") end
end

function bloodstained_5_modifier_tear:PlayEfxHaemorrhage(attacker, target)
	local particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(effect_cast, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControlOrientation(effect_cast, 1, attacker:GetForwardVector() * (-1), attacker:GetRightVector(), attacker:GetUpVector())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_PhantomAssassin.CoupDeGrace.Arcana") end
end