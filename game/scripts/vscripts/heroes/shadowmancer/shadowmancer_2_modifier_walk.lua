shadowmancer_2_modifier_walk = class({})

function shadowmancer_2_modifier_walk:IsHidden()
	return true
end

function shadowmancer_2_modifier_walk:IsPurgable()
	return true
end

function shadowmancer_2_modifier_walk:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_2_modifier_walk:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local delay = self.ability:GetSpecialValueFor("delay")
	local ms = self.ability:GetSpecialValueFor("ms")

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = ms})

	if IsServer() then
		self:StartIntervalThink(delay)
		self:PlayEfxStart()
	end
end

function shadowmancer_2_modifier_walk:OnRefresh(kv)
end

function shadowmancer_2_modifier_walk:OnRemoved()
	if IsServer() then self.parent:EmitSound("Hero_PhantomAssassin.Blur.Break") end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("shadowmancer_2_modifier_invisibility")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_2_modifier_walk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function shadowmancer_2_modifier_walk:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end

	self:Destroy()
end

function shadowmancer_2_modifier_walk:OnIntervalThink()
	self.parent:AddNewModifier(self.caster, self.ability, "shadowmancer_2_modifier_invisibility", {})

	if IsServer() then self:StartIntervalThink(-1) end
end


-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function shadowmancer_2_modifier_walk:GetEffectName()
	return "particles/shadowmancer/blur/shadowmancer_blur_ambient.vpcf"
end

function shadowmancer_2_modifier_walk:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function shadowmancer_2_modifier_walk:PlayEfxStart()
	local particle = "particles/shadowmancer/blur/shadowmancer_blur_start.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)

	if IsServer() then self.parent:EmitSound("Hero_PhantomAssassin.Blur") end
end