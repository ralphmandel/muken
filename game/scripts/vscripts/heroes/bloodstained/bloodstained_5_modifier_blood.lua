bloodstained_5_modifier_blood = class({})

function bloodstained_5_modifier_blood:IsHidden()
	return true
end

function bloodstained_5_modifier_blood:IsPurgable()
	return false
end

function bloodstained_5_modifier_blood:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_5_modifier_blood:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local blood_percent = self.ability:GetSpecialValueFor("blood_percent") * 0.01
	self.damage = math.ceil(kv.damage * blood_percent)

	if IsServer() then self:PlayEfxStart() end
end

function bloodstained_5_modifier_blood:OnRefresh(kv)
end

function bloodstained_5_modifier_blood:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_5_modifier_blood:PlayEfxStart()
	local amount = self.damage * 0.6
	local particle_cast = "particles/bloodstained/bloodstained_x2_blood.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 5, Vector(amount, amount, self.parent:GetAbsOrigin().z))
	self:AddParticle(effect_cast, false, false, -1, false, false)
end