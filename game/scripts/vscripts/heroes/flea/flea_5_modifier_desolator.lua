flea_5_modifier_desolator = class({})

function flea_5_modifier_desolator:IsHidden()
	return false
end

function flea_5_modifier_desolator:IsPurgable()
	return true
end

function flea_5_modifier_desolator:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_5_modifier_desolator:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart() end
end

function flea_5_modifier_desolator:OnRefresh(kv)
end

function flea_5_modifier_desolator:OnRemoved()
	self.ability:RemoveBonus("_2_DEF", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_5_modifier_desolator:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function flea_5_modifier_desolator:OnTakeDamage(keys)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_5_modifier_desolator:GetEffectName()
	return "particles/items3_fx/star_emblem.vpcf"
end

function flea_5_modifier_desolator:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function flea_5_modifier_desolator:PlayEfxStart()
	local string_1 = "particles/items_fx/abyssal_blink_end.vpcf"
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle_1, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle_1)

	if IsServer() then self.parent:EmitSound("DOTA_Item.AbyssalBlade.Activate") end
end