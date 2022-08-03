cosmetics_mod = class({})

--------------------------------------------------------------------------------
function cosmetics_mod:IsPurgable()
	return false
end

function cosmetics_mod:IsHidden()
	return true
end

function cosmetics_mod:IsDebuff()
	return false
end

function cosmetics_mod:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function cosmetics_mod:OnCreated( kv )
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.no_draw = 0
	self.invi = false
	self.model = kv.model
	self.parent:SetOriginalModel(self.model)

	--Timers:CreateTimer((0.2), function()
		self.parent:FollowEntity(self.caster, true)
	--end)
end

function cosmetics_mod:OnRefresh( kv )
end

function cosmetics_mod:OnRemoved()
	self.parent:AddNoDraw()
	self.parent:ForceKill(false)
end

--------------------------------------------------------------------------------

function cosmetics_mod:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVISIBLE] = self.invi
	}

	return state
end

function cosmetics_mod:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_DEATH

	}

	return funcs
end

function cosmetics_mod:GetModifierModelChange()
	return self.model
end

function cosmetics_mod:OnStateChanged(keys)
	if keys.unit ~= self.caster then return end
	
	if self.caster:IsInvisible() then
		self.invi = true
	else
		self.invi = false
	end
end

function cosmetics_mod:OnDeath(keys)
	if keys.unit == self.caster
	and keys.unit:IsIllusion() then
		self:Destroy()
	end
end

function cosmetics_mod:ChangeHidden(stack)
	self.no_draw = self.no_draw + stack

	if self.no_draw > 0 then
		self.parent:AddNoDraw()
	else
		self.parent:RemoveNoDraw()
	end
end

--------------------------------------------------------------------------------

function cosmetics_mod:PlayEfxAmbient(ambient, attach)
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

function cosmetics_mod:StopAmbientEfx(ambient, bDestroyImmediately)
	if self.index == nil then return end
	if self.ambient == nil then return end
	if self.particle == nil then return end
	
	for i = 1, self.index, 1 do
		if ambient == self.ambient[i] or ambient == nil then
			if self.particle[i] then
				ParticleManager:DestroyParticle(self.particle[i], bDestroyImmediately)
				ParticleManager:ReleaseParticleIndex(self.particle[i])
			end
		end
	end

	if ambient == nil then
		self.index = nil
		self.ambient = nil
		self.particle = nil
	end
end