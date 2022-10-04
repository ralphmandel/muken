genuine_u_modifier_target = class({})

function genuine_u_modifier_target:IsHidden()
	return false
end

function genuine_u_modifier_target:IsPurgable()
	return false
end

function genuine_u_modifier_target:IsDebuff()
	return true
end

-----------------------------------------------------------

function genuine_u_modifier_target:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.passives_break = false

	local vision = self.ability:GetSpecialValueFor("vision")

	-- UP 6.42
	if self.ability:GetRank(42) then
		vision = vision + 25
		self.ability:ApplyDarkness(self.parent, vision, self:GetDuration())
	else
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = vision, miss_chance = 0})
	end

	-- UP 6.11
	if self.ability:GetRank(11) then
		self.ability:AddBonus("_2_RES", self.parent, -15, 0, nil)
	end

	-- UP 6.22
	if self.ability:GetRank(22) then
		self.passives_break = true
	end

	self.caster:AddNewModifier(self.caster, self.ability, "genuine_u_modifier_caster", {})

	if IsServer() then
		self:StartIntervalThink(2)
		self:PlayEfxDebuff()
		self:PlayEfxSpecial()
	end
end

function genuine_u_modifier_target:OnRefresh(kv)
end

function genuine_u_modifier_target:OnRemoved(kv)
	self.caster:RemoveModifierByNameAndCaster("genuine_u_modifier_caster", self.caster)
	self.ability:RemoveBonus("_2_RES", self.parent)

	if IsServer() then self.parent:StopSound("Hero_DeathProphet.Exorcism") end

	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

function genuine_u_modifier_target:OnDestroy(kv)
	self.caster:RemoveModifierByNameAndCaster("genuine_u_modifier_caster", self.caster)
	if IsServer() then self.parent:StopSound("Hero_DeathProphet.Exorcism") end
end

----------------------------------------------------------

function genuine_u_modifier_target:CheckState()
	local state = {}

	if self.passives_break == true then
		local state = {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
	end

	return state
end

function genuine_u_modifier_target:OnIntervalThink()
	self:PlayEfxSpecial()

	-- UP 6.41
	if self.ability:GetRank(41) then
		self.ability:CreateStarfall(self.parent)
	end
end

-----------------------------------------------------------

function genuine_u_modifier_target:PlayEfxDebuff()
	local particle = "particles/genuine/genuine_ultimate.vpcf"
	self.effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	self:AddParticle(self.effect_caster, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_DeathProphet.Exorcism") end
end

function genuine_u_modifier_target:PlayEfxSpecial()
	local particle_cast = "particles/genuine/ult_deny/genuine_deny_v2.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end