_modifier_cosmetics = class({})

--------------------------------------------------------------------------------
function _modifier_cosmetics:IsPurgable()
	return false
end

function _modifier_cosmetics:IsHidden()
	return true
end

function _modifier_cosmetics:IsDebuff()
	return false
end

function _modifier_cosmetics:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_cosmetics:OnCreated( kv )
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.invi = false
	self.model = kv.model
	self.parent:SetOriginalModel(self.model)

	Timers:CreateTimer((0.2), function()
		self.parent:FollowEntity(self.caster, true)
	end)
end

function _modifier_cosmetics:OnRefresh( kv )
end

function _modifier_cosmetics:OnRemoved()
	UTIL_Remove(self.parent)
end

--------------------------------------------------------------------------------

function _modifier_cosmetics:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVISIBLE] = self.invi
	}

	return state
end

function _modifier_cosmetics:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_DEATH

	}

	return funcs
end

function _modifier_cosmetics:GetModifierModelChange()
	return self.model
end

function _modifier_cosmetics:OnStateChanged(keys)
	if keys.unit ~= self.caster then return end
	
	if self.caster:IsInvisible() then
		self.invi = true
	else
		self.invi = false
	end

	if self.caster:IsHexed()
	or self.caster:IsOutOfGame() then
		self.parent:AddNoDraw()
	else
		self.parent:RemoveNoDraw()
	end
end

function _modifier_cosmetics:OnDeath(keys)
	if keys.unit == self.caster
	and keys.unit:IsIllusion() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------

function _modifier_cosmetics:PlayEfxAmbient(ambient, attach)
	if self.index == nil then self.index = 0 end
	if self.ambient == nil then self.ambient = {} end
	if self.particle == nil then self.particle = {} end
	self.index = self.index + 1
	self.ambient[self.index] = ambient

	self.particle[self.index] = ParticleManager:CreateParticle(ambient, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle[self.index], 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(self.particle[self.index], 0, self.parent, PATTACH_POINT_FOLLOW, attach, Vector(0,0,0), true)
	self:AddParticle(self.particle[self.index], false, false, -1, false, false)
end

function _modifier_cosmetics:ResetAmbientEfx()
	if self.index == nil then return end
	if self.ambient == nil then return end
	if self.particle == nil then return end
	
	self.particle[self.index] = ParticleManager:CreateParticle(ambient, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle[self.index], 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(self.particle[self.index], 0, self.parent, PATTACH_POINT_FOLLOW, attach, Vector(0,0,0), true)
	self:AddParticle(self.particle[self.index], false, false, -1, false, false)
end