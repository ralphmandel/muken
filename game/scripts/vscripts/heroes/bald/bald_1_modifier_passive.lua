bald_1_modifier_passive = class({})
local tempTable = require("libraries/tempTable")

function bald_1_modifier_passive:IsHidden() return false end
function bald_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.build_stack = 0

	if IsServer() then self:SetStackCount(0) end
end

function bald_1_modifier_passive:OnRefresh(kv)
end

function bald_1_modifier_passive:OnRemoved()
	RemoveBonus(self.ability, "_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}

	return funcs
end

function bald_1_modifier_passive:GetModifierProcAttack_BonusDamage_Physical(keys)
end

function bald_1_modifier_passive:GetModifierProcAttack_BonusDamage_Physical(keys)
	if keys.attacker ~= self.parent then return 0 end
	if self.parent:PassivesDisabled() then return 0 end
	if self.ability:IsCooldownReady() == false then return 0 end

	local hit_build = self.ability:GetSpecialValueFor("hit_build")
	local hit_build_refresh = self.ability:GetSpecialValueFor("hit_build_refresh")
	local bash_chance = self.ability:GetSpecialValueFor("bash_chance")
	local bash_duration = self.ability:GetSpecialValueFor("bash_duration")
	local bash_damage = self.ability:GetSpecialValueFor("bash_damage")

	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self:AddMultStack()
	self.build_stack = 0

	if hit_build > 0 then self:StartIntervalThink(hit_build_refresh) end

	if RandomFloat(1, 100) <= bash_chance then
		local total_damage = self.parent:GetAverageTrueAttackDamage(keys.target) + bash_damage
		local total_bash = total_damage * bash_duration * 0.01
		self:PlayEfxImpact(keys.target)

		keys.target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
			duration = CalcStatus(total_bash, self.caster, keys.target)
		})
	
		keys.target:AddNewModifier(self.caster, nil, "modifier_knockback", {
			duration = 0.25,
			knockback_duration = 0.25,
			knockback_distance = total_bash * 50,
			center_x = self.parent:GetAbsOrigin().x + 1,
			center_y = self.parent:GetAbsOrigin().y + 1,
			center_z = self.parent:GetAbsOrigin().z,
			knockback_height = total_bash * 20,
		})

		return bash_damage
	end

	return 0
end

function bald_1_modifier_passive:OnIntervalThink()
	local hit_build = self.ability:GetSpecialValueFor("hit_build")
	self.build_stack = self.build_stack + 1
	
	if self.build_stack + 1 >= hit_build then self:StartIntervalThink(-1) end
end

function bald_1_modifier_passive:OnStackCountChanged(old)
	RemoveBonus(self.ability, "_1_STR", self.parent)

	if self:GetStackCount() > 0 then
		AddBonus(self.ability, "_1_STR", self.parent, self:GetStackCount(), 0, nil)
	end
end

-- UTILS -----------------------------------------------------------

function bald_1_modifier_passive:AddMultStack()
	local duration = self.ability:GetSpecialValueFor("duration")
	local stacks = self.build_stack + 1

	self:SetStackCount(self:GetStackCount() + stacks)

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "bald_1_modifier_passive_stack", {
		duration = duration,
		modifier = this,
		stacks = stacks
	})
end

-- EFFECTS -----------------------------------------------------------

function bald_1_modifier_passive:PlayEfxImpact(target)
	local sound_cast = "Hero_Spirit_Breaker.GreaterBash.Creep"
	if target:IsHero() then sound_cast = "Hero_Spirit_Breaker.GreaterBash" end 

	local particle_cast = "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound(sound_cast) end
end