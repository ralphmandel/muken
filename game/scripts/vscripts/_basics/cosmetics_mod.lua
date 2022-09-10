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
	self.ambient_table = {}

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
	local particle = ParticleManager:CreateParticle(ambient, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_POINT_FOLLOW, attach, Vector(0,0,0), true)
	self:AddParticle(particle, false, false, -1, false, false)

	table.insert(self.ambient_table, {[ambient] = particle})
end

function cosmetics_mod:StopAmbientEfx(ambient, bDestroyImmediately)
	for i = #self.ambient_table, 1, -1 do
		for string, particle in pairs(self.ambient_table[i]) do
			if ambient == string or ambient == nil then
				ParticleManager:DestroyParticle(particle, bDestroyImmediately)
				ParticleManager:ReleaseParticleIndex(particle)

				if ambient then
					table.remove(self.ambient_table, i)
					break
				end
			end
		end
	end

	if ambient == nil then self.ambient_table = {} end
end