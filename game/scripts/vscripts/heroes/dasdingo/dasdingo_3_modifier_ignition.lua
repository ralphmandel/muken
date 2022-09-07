dasdingo_3_modifier_ignition = class({})

function dasdingo_3_modifier_ignition:IsHidden()
	return true
end

function dasdingo_3_modifier_ignition:IsPurgable()
	return false
end

function dasdingo_3_modifier_ignition:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_ignition:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local intervals = 0.4
	local fire_damage = 20 * intervals

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = fire_damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self.ability
	}

	if IsServer() then
		self:StartIntervalThink(intervals)
		self.parent:EmitSound("Dasdingo.Ignite.Loop")
	end
end

function dasdingo_3_modifier_ignition:OnRefresh(kv)
	if IsServer() then
		self.parent:StopSound("Dasdingo.Ignite.Loop")
		self.parent:EmitSound("Dasdingo.Ignite.Loop")
	end
end

function dasdingo_3_modifier_ignition:OnRemoved()
	if IsServer() then self.parent:StopSound("Dasdingo.Ignite.Loop") end
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_ignition:CheckState()
	local state = {
		[MODIFIER_STATE_MUTED] = true,
	}

	return state
end

function dasdingo_3_modifier_ignition:OnIntervalThink()
	ApplyDamage(self.damageTable)
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_ignition:GetEffectName()
	return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf"
end

function dasdingo_3_modifier_ignition:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end