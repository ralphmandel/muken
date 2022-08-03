striker_u_modifier_autocast = class({})

function striker_u_modifier_autocast:IsHidden()
	return true
end

function striker_u_modifier_autocast:IsPurgable()
	return false
end

function striker_u_modifier_autocast:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_u_modifier_autocast:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.max_mana = 0
end

function striker_u_modifier_autocast:OnRefresh(kv)
	-- UP 7.12
	if self.ability:GetRank(12) then
		self.max_mana = 100
	end

	local void = self.caster:FindAbilityByName("_void")
	if void then void:SetLevel(1) end
end

function striker_u_modifier_autocast:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_u_modifier_autocast:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function striker_u_modifier_autocast:OnOrder(keys)
	if keys.order_type ~= 20 or keys.unit ~= self.parent then return end
	self.ability:ToggleAutoCast()
	local void = self.caster:FindAbilityByName("_void")
	if void then void:SetLevel(1) end
	self.ability:ToggleAutoCast()
end

function striker_u_modifier_autocast:GetModifierManaBonus()
	if self:GetAbility():GetAutoCastState() then
		return self.max_mana
	end

	return 0
end

function striker_u_modifier_autocast:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end

	-- UP 7.21
	if self.ability:GetRank(21) then
		self:PerformAutoCast()
	end
end

function striker_u_modifier_autocast:OnAttackLanded(keys)
	if keys.attacker == self.parent then self:PerformAutoCast() end

	-- UP 7.22
	if self.ability:GetRank(22) then
		self:BurnMana(keys.attacker, keys.target)
	end
end

-- UTILS -----------------------------------------------------------

function striker_u_modifier_autocast:BurnMana(attacker, target)
	if self.ability:GetAutoCastState() == false then return end
	if attacker:GetTeamNumber() ~= self.parent:GetTeamNumber() then return end
	if attacker ~= self.parent and attacker:IsIllusion() == false then return end
	if attacker:IsSilenced() then return end

	local mana = 5
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then mana = mana * (base_stats:GetSpellAmp() + 1) end

	if mana >= 1 then
		target:ReduceMana(mana)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, mana, self.caster)
	end
end

function striker_u_modifier_autocast:PerformAutoCast()
	if self.ability:GetAutoCastState() == false then return end
	if self.parent:IsIllusion() then return end

	-- UP 7.21
	if self.ability:GetRank(21) == false 
	and self.parent:IsSilenced() then
		return
	end

	if self:CastShield() or self:CastPortal() or self:CastHammer()
	or self:CastDoppel() or self:CastEinSof() then
		self:PlayEfxAutoCast()
	end
end

function striker_u_modifier_autocast:CheckAbility(pAbilityName)
	local ability = self.parent:FindAbilityByName(pAbilityName)
	if ability == nil then return end
	if ability:IsTrained() == false then return end

	local autocast_manacost = self.ability:GetSpecialValueFor("autocast_manacost")
	local cd_mult = 0.5

	-- UP 7.11
	if self.ability:GetRank(11) then
		cd_mult = cd_mult + 0.2
	end
	
	self.manacost = ability:GetManaCost(ability:GetLevel()) * autocast_manacost * 0.01
	if self.parent:GetMana() < self.manacost then return end

	local chance_cooldown = self.ability:GetSpecialValueFor("chance_cooldown")
	if ability:IsCooldownReady() == false then chance_cooldown = chance_cooldown * cd_mult end

	local chance = (1 / ability:GetEffectiveCooldown(ability:GetLevel())) * chance_cooldown
	if RandomFloat(1, 100) > chance then return end

	return ability
end

function striker_u_modifier_autocast:CastShield()
	local shield = self:CheckAbility("striker_2__shield")
	if shield == nil then return end

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
		shield:GetCastRange(self.parent:GetOrigin(), nil),
		shield:GetAbilityTargetTeam(), shield:GetAbilityTargetType(),
		shield:GetAbilityTargetFlags(), 0, false
	)

    for _,unit in pairs(units) do
		if unit:HasModifier("striker_2_modifier_shield") == false then
			self.parent:SpendMana(self.manacost, shield)
			return shield:PerformAbility(unit)
		end
	end
end

function striker_u_modifier_autocast:CastPortal()
	local portal = self:CheckAbility("striker_3__portal")
	if portal == nil then return end

	local range = portal:GetCastRange(self.parent:GetOrigin(), nil)
	local loc = self.parent:GetAbsOrigin() + RandomVector(RandomInt(0, range))

	self.parent:SpendMana(self.manacost, portal)
	return portal:PerformAbility(loc)
end

function striker_u_modifier_autocast:CastHammer()
	local hammer = self:CheckAbility("striker_4__hammer")
	if hammer == nil then return end
	
	local flags = hammer:GetAbilityTargetFlags()

	-- UP 4.21
	if hammer:GetRank(21) then
		flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
		hammer:GetCastRange(self.parent:GetOrigin(), nil),
		hammer:GetAbilityTargetTeam(), hammer:GetAbilityTargetType(),
		flags, 0, false
	)

    for _,unit in pairs(units) do
		if unit:IsHero() then
			self.parent:SpendMana(self.manacost, hammer)
			return hammer:PerformAbility(unit)
		end
	end

	for _,unit in pairs(units) do
		self.parent:SpendMana(self.manacost, hammer)
		return hammer:PerformAbility(unit)
	end
end

function striker_u_modifier_autocast:CastDoppel()
	local doppel = self:CheckAbility("striker_5__clone")
	if doppel == nil then return end

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
		doppel:GetCastRange(self.parent:GetOrigin(), nil),
		doppel:GetAbilityTargetTeam(), doppel:GetAbilityTargetType(),
		doppel:GetAbilityTargetFlags(), 0, false
	)

    for _,unit in pairs(units) do
		if unit:HasModifier("striker_5_modifier_hero") == false
		and unit ~= self.parent then
			self.parent:SpendMana(self.manacost, doppel)
			return doppel:PerformAbility(unit)
		end
	end

	for _,unit in pairs(units) do
		if unit ~= self.parent then
			self.parent:SpendMana(self.manacost, doppel)
			return doppel:PerformAbility(unit)
		end
	end
end

function striker_u_modifier_autocast:CastEinSof()
	local einsof = self:CheckAbility("striker_6__sof")
	if einsof == nil then return end
	if einsof:IsActivated() then
		einsof.autocast = true
		self.parent:SpendMana(self.manacost, einsof)
		return einsof:PerformAbility()
	end
end

-- EFFECTS -----------------------------------------------------------

function striker_u_modifier_autocast:PlayEfxAutoCast()
	local string_1 = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_javelin_tgt_v2.vpcf"
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle_1, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle_1, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle_1)

	--if IsServer() then self.parent:EmitSound("Hero_Striker.Autocast") end
end