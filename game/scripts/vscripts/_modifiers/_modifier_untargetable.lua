_modifier_untargetable = class({})

--------------------------------------------------------------------------------
function _modifier_untargetable:IsPurgable()
	return true
end

function _modifier_untargetable:IsHidden()
	return true
end

function _modifier_untargetable:GetTexture()
	return "_modifier_untargetable"
end

function _modifier_untargetable:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_untargetable:OnCreated( kv )
	if IsServer() then self:PlayEfxStart() end
end

--------------------------------------------------------------------------------

function _modifier_untargetable:CheckState()
	local state = {
		[MODIFIER_STATE_UNTARGETABLE] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function _modifier_untargetable:PlayEfxStart()
	local caster = self:GetCaster()
	local string = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_luminosity_attack_buff.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetOrigin())
	self:AddParticle(particle, false, false, -1, false, false)

	if IsServer() then caster:EmitSound("Hero_Chen.HolyPersuasionEnemy") end
end
