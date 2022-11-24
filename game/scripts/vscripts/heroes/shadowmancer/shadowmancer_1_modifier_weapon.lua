shadowmancer_1_modifier_weapon = class({})

function shadowmancer_1_modifier_weapon:IsHidden()
	return true
end

function shadowmancer_1_modifier_weapon:IsPurgable()
	return false
end

function shadowmancer_1_modifier_weapon:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_1_modifier_weapon:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart() end
end

function shadowmancer_1_modifier_weapon:OnRefresh(kv)
	if IsServer() then self:PlayEfxStart() end
end

function shadowmancer_1_modifier_weapon:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_1_modifier_weapon:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function shadowmancer_1_modifier_weapon:OnAttackLanded(keys)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function shadowmancer_1_modifier_weapon:PlayEfxStart()
	if self.efx then ParticleManager:DestroyParticle(self.efx, false) end

	local string = "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf"
	self.efx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.efx, 0, self.parent:GetOrigin())
	self:AddParticle(self.efx, false, false, -1, false, false)

	--if IsServer() then self.parent:EmitSound("") end
end