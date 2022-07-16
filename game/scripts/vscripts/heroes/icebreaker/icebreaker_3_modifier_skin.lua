icebreaker_3_modifier_skin = class({})

function icebreaker_3_modifier_skin:IsHidden()
	return false
end

function icebreaker_3_modifier_skin:IsPurgable()
    return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_3_modifier_skin:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.damage_reduction = self.ability:GetSpecialValueFor("damage_reduction")
	self.regen = 0

	-- UP 3.11
	if self.ability:GetRank(11) then
		self.regen = 75
	end

	self.ability:SetActivated(false)
	self:PlayEfxStart()
end

function icebreaker_3_modifier_skin:OnRefresh( kv )
end

function icebreaker_3_modifier_skin:OnRemoved()
	self.ability:ResetLayers()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_3_modifier_skin:CheckState()
	local state = {
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_FROZEN] = true,
	}

	return state
end

function icebreaker_3_modifier_skin:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ORDER,
	}
	return funcs
end

function icebreaker_3_modifier_skin:GetModifierConstantHealthRegen()
	return self.regen
end

function icebreaker_3_modifier_skin:GetModifierIncomingPhysicalDamage_Percentage()
	return -self.damage_reduction
end

function icebreaker_3_modifier_skin:OnOrder(params)
	if params.unit ~= self.parent then return end

	if params.order_type == 5 or params.order_type == 6 then
		self:Destroy()
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker_3_modifier_skin:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf"
end

function icebreaker_3_modifier_skin:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_3_modifier_skin:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Ancient_Apparition.ColdFeetCast") end
end