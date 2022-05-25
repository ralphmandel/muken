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

	self.caster:AddNewModifier(self.caster, self.ability, "genuine_u_modifier_caster", {})
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = slow})
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = vision, miss_chance = 0})

	if IsServer() then self:PlayEfxDebuff() end
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

-----------------------------------------------------------

function genuine_u_modifier_target:PlayEfxDebuff()
	local particle = "particles/econ/items/drow/drow_arcana/drow_arcana_frost_arrow_debuff_v2.vpcf"
	self.effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	self:AddParticle(self.effect_caster, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_DeathProphet.Exorcism") end
end