striker_u_modifier_autocast = class({})

function striker_u_modifier_autocast:IsHidden() return true end
function striker_u_modifier_autocast:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_u_modifier_autocast:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function striker_u_modifier_autocast:OnRefresh(kv)
end

function striker_u_modifier_autocast:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_u_modifier_autocast:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function striker_u_modifier_autocast:OnOrder(keys)
	if keys.order_type == 20 and keys.unit == self.parent then
		self.ability:OnAutoCastChange(false)
	end
end

function striker_u_modifier_autocast:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.ability:GetAutoCastState() == false then return end
	if self.parent:IsIllusion() then return end
	if self.parent:PassivesDisabled() then return end

	if self:CastShield() or self:CastPortal() or self:CastHammer() or self:CastEinSof() then
		self:PlayEfxAutoCast()
	end
end

-- UTILS -----------------------------------------------------------

function striker_u_modifier_autocast:CheckAbility(pAbilityName)
	local ability = self.parent:FindAbilityByName(pAbilityName)
	if ability == nil then return end
	if ability:IsTrained() == false then return end
	if ability:IsCooldownReady() == false then return end

	local autocast_manacost = ability:GetSpecialValueFor("autocast_manacost")	
	local manacost = ability:GetManaCost(ability:GetLevel()) * autocast_manacost * 0.01
	if self.parent:GetMana() < manacost then return end

	local chance_sof = self:CheckSof("striker_5_modifier_sof")
	if chance_sof == 1 then chance_sof = self:CheckSof("striker_5_modifier_return") end

	local chance = (100 / ability:GetCooldown(ability:GetLevel())) * chance_sof
	if RandomFloat(1, 100) > chance then return end

	return {ability = ability, manacost = manacost}
end

function striker_u_modifier_autocast:CheckSof(string)
	local mod = self.parent:FindModifierByNameAndCaster(string, self.caster)
	if mod then return (100 / (100 + mod.swap)) end

	return 1
end

function striker_u_modifier_autocast:CastShield()
	local shield = self:CheckAbility("striker_2__shield")
	if shield == nil then return end

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
		shield.ability:GetCastRange(self.parent:GetOrigin(), nil),
		shield.ability:GetAbilityTargetTeam(), shield.ability:GetAbilityTargetType(),
		shield.ability:GetAbilityTargetFlags(), 0, false
	)

  for _,unit in pairs(units) do
		if unit:HasModifier("striker_2_modifier_shield") == false then
			self.parent:SpendMana(shield.manacost, shield.ability)
			return shield.ability:PerformAbility(unit)
		end
	end
end

function striker_u_modifier_autocast:CastPortal()
	local portal = self:CheckAbility("striker_3__portal")
	if portal == nil then return end

	local range = portal.ability:GetCastRange(self.parent:GetOrigin(), nil)
	local loc = self.parent:GetAbsOrigin() + RandomVector(RandomInt(0, range))

	self.parent:SpendMana(portal.manacost, portal.ability)
	return portal.ability:PerformAbility(loc)
end

function striker_u_modifier_autocast:CastHammer()
	local hammer = self:CheckAbility("striker_4__hammer")
	if hammer == nil then return end
	
	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
		hammer.ability:GetCastRange(self.parent:GetOrigin(), nil),
		hammer.ability:GetAbilityTargetTeam(), hammer.ability:GetAbilityTargetType(),
		hammer.ability:GetAbilityTargetFlags(), 0, false
	)

  for _,unit in pairs(units) do
		if unit:IsHero() then
			self.parent:SpendMana(hammer.manacost, hammer.ability)
			return hammer.ability:PerformAbility(unit)
		end
	end

	for _,unit in pairs(units) do
		self.parent:SpendMana(hammer.manacost, hammer.ability)
		return hammer.ability:PerformAbility(unit)
	end
end

function striker_u_modifier_autocast:CastEinSof()
	local einsof = self:CheckAbility("striker_5__sof")
	if einsof == nil then return end

	if einsof.ability:IsActivated() then
		einsof.ability.autocast = true
		self.parent:SpendMana(einsof.manacost, einsof.ability)
		return einsof.ability:PerformAbility()
	end
end

-- EFFECTS -----------------------------------------------------------

function striker_u_modifier_autocast:PlayEfxAutoCast()
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Dawnbreaker.Converge.Cast") end
end