_modifier_petrified = class({})

--------------------------------------------------------------------------------
function _modifier_petrified:IsPurgable()
	return true
end

function _modifier_petrified:IsStunDebuff()
	return true
end

function _modifier_petrified:IsDebuff()
	return true
end

function _modifier_petrified:IsHidden()
	return false
end

function _modifier_petrified:GetTexture()
	return "_modifier_petrified"
end

function _modifier_petrified:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function _modifier_petrified:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

--------------------------------------------------------------------------------

function _modifier_petrified:OnCreated(kv)
	local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self:GetCaster(), self:GetAbility(), "_modifier_petrified_status_efx", true) end

	if IsServer() then
		self:PlayEfxStart()
		self:StartIntervalThink(FrameTime())
	end
end

function _modifier_petrified:OnRefresh(kv)
	if IsServer() then self:GetParent():EmitSound("Hero_Medusa.StoneGaze.Stun") end
end

function _modifier_petrified:OnRemoved()
	local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self:GetCaster(), self:GetAbility(), "_modifier_petrified_status_efx", false) end
end

--------------------------------------------------------------------------------

function _modifier_petrified:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true
	}

	return state
end

--------------------------------------------------------------------------------

function _modifier_petrified:OnIntervalThink()
	if self:GetParent():IsStunned() == false
	or self:GetParent():IsFrozen() == false then
		self:Destroy()
	end

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-----------------------------------------------------------

function _modifier_petrified:GetStatusEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end
function _modifier_petrified:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function _modifier_petrified:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff_stoned.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector( 0,0,0 ), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self:GetParent():EmitSound("Hero_Medusa.StoneGaze.Stun") end
end