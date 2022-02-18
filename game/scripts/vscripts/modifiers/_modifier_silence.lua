_modifier_silence = class({})

--------------------------------------------------------------------------------
function _modifier_silence:IsHidden()
	return false
end

function _modifier_silence:IsPurgable()
	return true
end

function _modifier_silence:IsDebuff()
	return true
end

function _modifier_silence:GetTexture()
	return "_modifier_silence"
end

function _modifier_silence:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_silence:OnCreated( kv )
	self.parent = self:GetParent()

	if IsServer() then
		local str = kv.special or 1

		local path = nil
		if str == 1 then
			path = "particles/basics/silence.vpcf"
		elseif str == 2 then
			path = "particles/basics/silence__red.vpcf"
		end
		
		self:PlayEfxStart(path)
	end
end

function _modifier_silence:OnRemoved( kv )
	if self.effect then ParticleManager:DestroyParticle(self.effect, false) end
end

--------------------------------------------------------------------------------

function _modifier_silence:CheckState()
	local state = {
	[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

-- function _modifier_silence:GetEffectName()
-- 	return "particles/econ/items/drow/drow_arcana/drow_arcana_silenced.vpcf"
-- end

-- function _modifier_silence:GetEffectAttachType()
-- 	return PATTACH_OVERHEAD_FOLLOW
-- end

function _modifier_silence:PlayEfxStart(path)
	if path == nil then return end

    self.effect = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect, 0, self.parent:GetOrigin())
	
	-- buff particle
	self:AddParticle(
		self.effect,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		true -- bOverheadEffect
    )
end