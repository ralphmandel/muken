flea_u_modifier_passive = class({})

function flea_u_modifier_passive:IsHidden()
	return true
end

function flea_u_modifier_passive:IsPurgable()
	return false
end

function flea_u_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_u_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.enemies = {}
end

function flea_u_modifier_passive:OnRefresh(kv)
end

function flea_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_u_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:IsHero() == false then return end
	if keys.attacker:IsAlive() == false or keys.target:IsAlive() == false then return end
	if self.parent:PassivesDisabled() then return end
	if self.ability:IsCooldownReady() == false then return end

	local max_stack = self.ability:GetSpecialValueFor("max_stack")
	local target_duration = self.ability:GetSpecialValueFor("target_duration")
	local caster_duration = self.ability:GetSpecialValueFor("caster_duration")

	local target_mod = keys.target:FindModifierByNameAndCaster("flea_u_modifier_target", self.caster)
	if target_mod then if target_mod:GetStackCount() >= max_stack then return end end

	self.caster:AddNewModifier(self.caster, self.ability, "flea_u_modifier_caster", {
		duration = caster_duration
	})

	keys.target:AddNewModifier(self.caster, self.ability, "flea_u_modifier_target", {
		duration = target_duration
	})

	self:AddTarget(keys.target)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))

	if IsServer() then self:PlayEfxHit(keys.target) end
end

-- UTILS -----------------------------------------------------------

function flea_u_modifier_passive:AddTarget(target)
	for _,enemy in pairs(self.enemies) do
		if enemy then
			if IsValidEntity(enemy) then
				if target == enemy then
					return
				end
			end
		end
	end

	table.insert(self.enemies, target)
end

function flea_u_modifier_passive:RemoveAllTargets()
	for _,enemy in pairs(self.enemies) do
		if enemy then
			if IsValidEntity(enemy) then
				enemy:RemoveModifierByNameAndCaster("flea_u_modifier_target", self.caster)
			end
		end
	end

	self.enemies = {}
end

-- EFFECTS -----------------------------------------------------------

function flea_u_modifier_passive:PlayEfxHit(target)
	local particle_cast = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin() + Vector(0, 0, 64))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_BountyHunter.Jinada") end
end