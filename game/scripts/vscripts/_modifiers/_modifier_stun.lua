_modifier_stun = class({})

--------------------------------------------------------------------------------
function _modifier_stun:IsPurgable()
	return true
end

function _modifier_stun:IsStunDebuff()
	return true
end

function _modifier_stun:IsHidden()
	return false
end

function _modifier_stun:GetTexture()
	return "_modifier_stun"
end

function _modifier_stun:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_stun:OnCreated(kv)
	local special = kv.special or 0
	local effect
	local attach

	if special == 0 then
		effect = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_stunned.vpcf"
		attach = PATTACH_OVERHEAD_FOLLOW
	end

	if special == 1 then
		effect = "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf"
		attach = PATTACH_ABSORIGIN_FOLLOW
	end

	self.particle = ParticleManager:CreateParticle(effect, attach, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetOrigin())

	if IsServer() then
		self:GetParent():EmitSound("DOTA_Item.SkullBasher")
		self:SetStackCount(0)
		self:StartIntervalThink(FrameTime())
	end
end

function _modifier_stun:OnRefresh(kv)
	if IsServer() then self:GetParent():EmitSound("DOTA_Item.SkullBasher") end
end

function _modifier_stun:OnRemoved()
	ParticleManager:DestroyParticle(self.particle, false)
end

--------------------------------------------------------------------------------

function _modifier_stun:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true
	}

	return state
end

--------------------------------------------------------------------------------

function _modifier_stun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function _modifier_stun:GetOverrideAnimation(keys)
	return self:GetStackCount()
end

function _modifier_stun:OnIntervalThink()
	if self:GetParent():IsStunned() then
		self:SetStackCount(1509)
	else
		self:SetStackCount(0)
	end
end