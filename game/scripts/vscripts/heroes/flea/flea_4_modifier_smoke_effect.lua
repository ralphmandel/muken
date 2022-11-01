flea_4_modifier_smoke_effect = class({})

function flea_4_modifier_smoke_effect:IsHidden()
	return true
end

function flea_4_modifier_smoke_effect:IsPurgable()
	return false
end

function flea_4_modifier_smoke_effect:IsDebuff()
	return (self:GetCaster() ~= self:GetParent())
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_4_modifier_smoke_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.tick = 0

	if IsServer() then
		if self.parent == self.caster then
			self:PlayEfxStart()			
		end

		self:OnIntervalThink()
	end
end

function flea_4_modifier_smoke_effect:OnRefresh(kv)
end

function flea_4_modifier_smoke_effect:OnRemoved()
	if self.parent == self.caster then
		self:StopEfxStart()
	else
		self:RemoveDebuff()
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_4_modifier_smoke_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_4_modifier_smoke_effect:OnAttackLanded(keys)
	if self.parent ~= self.caster then return end
	if keys.attacker ~= self.parent then return end

	local mod = self.parent:FindAllModifiersByName("_modifier_invisible")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_invisible", {
		duration = 1, delay = 0, spell_break = 1, attack_break = 0
	})

	self.parent:MoveToTargetToAttack(keys.target)
end

function flea_4_modifier_smoke_effect:OnIntervalThink()
	if self.caster == self.parent then
		ParticleManager:SetParticleControl(self.effect_cast, 1, self.parent:GetOrigin())
		if IsServer() then self:StartIntervalThink(FrameTime()) end
	else
		self:ApplyDebuff()
		local interval = self.ability:GetSpecialValueFor("interval")
		if IsServer() then self:StartIntervalThink(interval) end
	end
end

-- UTILS -----------------------------------------------------------

function flea_4_modifier_smoke_effect:ApplyDebuff()
	local debuff_init = self.ability:GetSpecialValueFor("debuff_init")
	local debuff_decrease = self.ability:GetSpecialValueFor("debuff_decrease")
	local percent = debuff_init - (debuff_decrease * self.tick)
	if percent <= 0 then return end

	self.tick = self.tick + 1

	self:RemoveDebuff()	
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = percent})
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = percent})
end

function flea_4_modifier_smoke_effect:RemoveDebuff()
	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- EFFECTS -----------------------------------------------------------

function flea_4_modifier_smoke_effect:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_slark/slark_shadow_dance.vpcf"
	local effect_cast = ParticleManager:CreateParticleForTeam(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent, self.parent:GetTeamNumber())
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_eyeR", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 4, self.parent, PATTACH_POINT_FOLLOW, "attach_eyeL", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	local particle_cast_2 = "particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf"
	local effect_cast_1 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_WORLDORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast_1, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast_1, 1, self.parent:GetOrigin())
	self:AddParticle(effect_cast_1, false, false, -1, false, false)

	self.effect_cast = effect_cast_1
	self.parent:StartGesture(ACT_DOTA_SHADOW_DANCE_STATUE)

	if IsServer() then self.parent:EmitSound("Hero_Slark.ShadowDance") end
end

function flea_4_modifier_smoke_effect:StopEfxStart()
	self.parent:FadeGesture(ACT_DOTA_SHADOW_DANCE_STATUE)
	if IsServer() then self.parent:StopSound("Hero_Slark.ShadowDance") end
end