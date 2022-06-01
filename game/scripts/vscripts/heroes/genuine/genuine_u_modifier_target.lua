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

	local slow = self.ability:GetSpecialValueFor("slow")
	local vision = self.ability:GetSpecialValueFor("vision")
	self.shared_vision = false

	-- UP 4.12
	if self.ability:GetRank(12) then
		slow = slow + 30
	end

	-- UP 4.13
	if self.ability:GetRank(13) then
		self.shared_vision = true
	end
	
	-- UP 4.42
	if self.ability:GetRank(42) then
		self.parent:Purge(true, false, false, false, false)
	end

	self.caster:AddNewModifier(self.caster, self.ability, "genuine_u_modifier_caster", {})
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = slow})
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = vision, miss_chance = 0})

	if IsServer() then
		self:StartIntervalThink(1.5)
		self:PlayEfxDebuff()
		self:PlayEfxSpecial()
	end
end

function genuine_u_modifier_target:OnRefresh(kv)
end

function genuine_u_modifier_target:OnRemoved(kv)
	self.caster:RemoveModifierByName("genuine_u_modifier_caster")
	if IsServer() then self.parent:StopSound("Hero_DeathProphet.Exorcism") end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

function genuine_u_modifier_target:OnDestroy(kv)
	self.caster:RemoveModifierByName("genuine_u_modifier_caster")
	if IsServer() then self.parent:StopSound("Hero_DeathProphet.Exorcism") end
end

----------------------------------------------------------

function genuine_u_modifier_target:CheckState()
	local state = {}

	if self.shared_vision then
		state = {[MODIFIER_STATE_PROVIDES_VISION] = true}
	end

	return state
end

function genuine_u_modifier_target:OnIntervalThink()
	self:PlayEfxSpecial()

	-- UP 4.31
	if self.ability:GetRank(31) then
		self.ability:CreateStarfall(self.parent)
	end

	-- UP 4.42
	if self.ability:GetRank(42) then
		self.parent:Purge(true, false, false, false, false)
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