slayer_1_modifier_effect = class ({})

function slayer_1_modifier_effect:IsHidden()
    return true
end

function slayer_1_modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function slayer_1_modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.a = 0
	self.b = 1
	self.c = 2
	self.d = 3
	self.e = 4
	self.f = 5
	self.r = self.ability:GetSpecialValueFor("radius")

	if IsServer() then
		self:PlayEfxStart()
	end
end

function slayer_1_modifier_effect:OnRefresh(kv)
end

function slayer_1_modifier_effect:OnRemoved(kv)
	if self.effect_a then
		ParticleManager:DestroyParticle(self.effect_a, false)
		self.effect_a = nil
	end

	if self.effect_b then
		ParticleManager:DestroyParticle(self.effect_b, false)
		self.effect_b = nil
	end

	if self.effect_c then
		ParticleManager:DestroyParticle(self.effect_c, false)
		self.effect_c = nil
	end

	if self.effect_d then
		ParticleManager:DestroyParticle(self.effect_d, false)
		self.effect_d = nil
	end

	if self.effect_e then
		ParticleManager:DestroyParticle(self.effect_e, false)
		self.effect_e = nil
	end

	if self.effect_f then
		ParticleManager:DestroyParticle(self.effect_f, false)
		self.effect_f = nil
	end
end

------------------------------------------------------------

function slayer_1_modifier_effect:EffectSpin()
	self.a = self.a + 0.2
	self.b = self.b + 0.2
	self.c = self.c + 0.2
	self.d = self.d + 0.2
	self.e = self.e + 0.2
	self.f = self.f + 0.2

	local origin = self.parent:GetOrigin()

	local point_a = Vector(math.cos(self.a), math.sin(self.a), 0):Normalized() * self.r
	point_a = origin + point_a

	local point_b = Vector(math.cos(self.b), math.sin(self.b), 0):Normalized() * self.r
	point_b = origin + point_b

	local point_c = Vector(math.cos(self.c), math.sin(self.c), 0):Normalized() * self.r
	point_c = origin + point_c

	local point_d = Vector(math.cos(self.d), math.sin(self.d), 0):Normalized() * self.r
	point_d = origin + point_d

	local point_e = Vector(math.cos(self.e), math.sin(self.e), 0):Normalized() * self.r
	point_e = origin + point_e

	local point_f = Vector(math.cos(self.f), math.sin(self.f), 0):Normalized() * self.r
	point_f = origin + point_f

	if self.effect_a and self.effect_b and self.effect_c and self.effect_d and self.effect_e and self.effect_f then
		ParticleManager:SetParticleControl(self.effect_a, 3, point_a)
		ParticleManager:SetParticleControl(self.effect_b, 3, point_b)
		ParticleManager:SetParticleControl(self.effect_c, 3, point_c)
		ParticleManager:SetParticleControl(self.effect_d, 3, point_d)
		ParticleManager:SetParticleControl(self.effect_e, 3, point_e)
		ParticleManager:SetParticleControl(self.effect_f, 3, point_f)

		local flame = 50

		-- if self.parent:HasModifier("slayer_u_modifier_flame") then
		-- 	flame = 50

		-- 	local ult = self.parent:FindAbilityByName("slayer_u__judge")
		-- 	if ult then
		-- 		flame = flame + (ult:GetLevel() * 5)
		-- 	end
		-- end

		ParticleManager:SetParticleControl(self.effect_a, 7, Vector(flame, 0, 0))
		ParticleManager:SetParticleControl(self.effect_b, 7, Vector(flame, 0, 0))
		ParticleManager:SetParticleControl(self.effect_c, 7, Vector(flame, 0, 0))
		ParticleManager:SetParticleControl(self.effect_d, 7, Vector(flame, 0, 0))
		ParticleManager:SetParticleControl(self.effect_e, 7, Vector(flame, 0, 0))
		ParticleManager:SetParticleControl(self.effect_f, 7, Vector(flame, 0, 0))		

		Timers:CreateTimer((0.001), function()
			self:EffectSpin()
		end)
	end
end

-----------------------------------------------------------

function slayer_1_modifier_effect:PlayEfxStart()
	self.effect_a = ParticleManager:CreateParticle("particles/demonslayer/demonslayer__skill1_chain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_a, 0, self.parent:GetOrigin())

	self.effect_b = ParticleManager:CreateParticle("particles/demonslayer/demonslayer__skill1_chain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_b, 0, self.parent:GetOrigin())

	self.effect_c = ParticleManager:CreateParticle("particles/demonslayer/demonslayer__skill1_chain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_c, 0, self.parent:GetOrigin())

	self.effect_d = ParticleManager:CreateParticle("particles/demonslayer/demonslayer__skill1_chain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_d, 0, self.parent:GetOrigin())

	self.effect_e = ParticleManager:CreateParticle("particles/demonslayer/demonslayer__skill1_chain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_e, 0, self.parent:GetOrigin())

	self.effect_f = ParticleManager:CreateParticle("particles/demonslayer/demonslayer__skill1_chain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_f, 0, self.parent:GetOrigin())

	self:EffectSpin()
end