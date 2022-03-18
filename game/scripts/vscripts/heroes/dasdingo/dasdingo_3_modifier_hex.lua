dasdingo_3_modifier_hex = class({})

function dasdingo_3_modifier_hex:IsHidden()
	return false
end

function dasdingo_3_modifier_hex:IsDebuff()
	return true
end

function dasdingo_3_modifier_hex:IsHexDebuff()
	return true
end

function dasdingo_3_modifier_hex:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_hex:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.ms_limit = self:GetAbility():GetSpecialValueFor("ms_limit")
	self.model = "models/props_gameplay/pig.vmdl"

    if self.parent:IsIllusion() then
        self.parent:Kill(self.ability, self.caster)
    end

	-- UP 3.11
	if self.ability:GetRank(11) then
		self:StartIntervalThink(0.1)
	end

	-- UP 3.12
	if self.ability:GetRank(12) then
		self.ms_limit = 100
	end

	if IsServer() then
		self:PlayEfxStart(true)
	end
end

function dasdingo_3_modifier_hex:OnRefresh(kv)
	self.ms_limit = self:GetAbility():GetSpecialValueFor("ms_limit")

	if IsServer() then
		self:PlayEfxStart(true)
	end
end

function dasdingo_3_modifier_hex:OnRemoved()
	if IsServer() then
		self:PlayEfxStart(false)
	end
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_hex:CheckState()
	local state = {
		[MODIFIER_STATE_HEXED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true
	}

	return state
end

function dasdingo_3_modifier_hex:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}

	return funcs
end

function dasdingo_3_modifier_hex:GetModifierMoveSpeed_Limit()
	return self.ms_limit
end

function dasdingo_3_modifier_hex:GetModifierModelChange()
	return self.model
end

function dasdingo_3_modifier_hex:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function dasdingo_3_modifier_hex:OnIntervalThink()
	if self.parent:IsMoving() then
		self.parent:ReduceMana(6)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, self.parent, -6, self.caster)
	end
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_hex:PlayEfxStart(bStart)
	if bStart then
		if IsServer() then self.parent:EmitSound("Item.PigPole.Target") end
    else
        if IsServer() then
            self.parent:StopSound("Item.PigPole.Target")
            self.parent:EmitSound("Hero_Dasdingo.Out")
        end
    end
end