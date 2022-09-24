ancient_3_modifier_avatar = class ({})

function ancient_3_modifier_avatar:IsHidden()
    return false
end

function ancient_3_modifier_avatar:IsPurgable()
    return true
end

function ancient_3_modifier_avatar:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_3_modifier_avatar:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:PlayExStart() end
end

function ancient_3_modifier_avatar:OnRefresh(kv)
	if IsServer() then self:PlayExStart() end
end

function ancient_3_modifier_avatar:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_3_modifier_avatar:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_3_modifier_avatar:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function ancient_3_modifier_avatar:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function ancient_3_modifier_avatar:PlayExStart()
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end

	local particle_cast = "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 5, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Omniknight.GuardianAngel") end
end