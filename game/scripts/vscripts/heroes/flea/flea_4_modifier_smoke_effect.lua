flea_4_modifier_smoke_effect = class({})

function flea_4_modifier_smoke_effect:IsHidden()
	return true
end

function flea_4_modifier_smoke_effect:IsPurgable()
	return false
end

function flea_4_modifier_smoke_effect:IsDebuff()
	return (self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber())
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_4_modifier_smoke_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
			self.parent:RemoveModifierByNameAndCaster("flea_4_modifier_invi", self.caster)
			self:PlayEfxStart()
			self:OnIntervalThink()
		else
			self:ApplyDebuff()
		end
	end
end

function flea_4_modifier_smoke_effect:OnRefresh(kv)
end

function flea_4_modifier_smoke_effect:OnRemoved()
	self:StopEfxStart()
	self:RemoveDebuff()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_4_modifier_smoke_effect:CheckState()
	local state = {}

	if self:GetAbility():GetCurrentAbilityCharges() % 2 == 0
	and self:GetCaster() == self:GetParent() then
		state = {
			[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
		}
	end

	return state
end

function flea_4_modifier_smoke_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_4_modifier_smoke_effect:OnAttackLanded(keys)
	if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end
	if keys.attacker ~= self.parent then return end

	self.parent:AddNewModifier(self.caster, self.ability, "flea_4_modifier_hidden", {duration = 1})
	self.parent:MoveToTargetToAttack(keys.target)
end

function flea_4_modifier_smoke_effect:OnIntervalThink()
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
		if self.effect_cast then ParticleManager:SetParticleControl(self.effect_cast, 1, self.parent:GetOrigin()) end
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

	-- UP 4.11
	if self.ability:GetRank(11) then
		debuff_init = debuff_init + 15
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = debuff_init})
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = debuff_init})
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
	--self.parent:StartGesture(ACT_DOTA_SHADOW_DANCE_STATUE)

	if IsServer() then self.parent:EmitSound("DOTA_Item.InvisibilitySword.Activate") end
end

function flea_4_modifier_smoke_effect:StopEfxStart()
	--self.parent:FadeGesture(ACT_DOTA_SHADOW_DANCE_STATUE)
end