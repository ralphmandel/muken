icebreaker_x1_modifier_skin = class({})

function icebreaker_x1_modifier_skin:IsHidden()
	return false
end

function icebreaker_x1_modifier_skin:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker_x1_modifier_skin:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.reduction = self.ability:GetSpecialValueFor("reduction")
	self.regen = self.ability:GetSpecialValueFor("regen")

	self:PlayEfxStart()
end

function icebreaker_x1_modifier_skin:OnRefresh( kv )
    
end

function icebreaker_x1_modifier_skin:OnRemoved()
end

-----------------------------------------------------------

function icebreaker_x1_modifier_skin:CheckState()
	local state = {
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_FROZEN] = true,
	}

	return state
end

function icebreaker_x1_modifier_skin:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ORDER,
	}
	return funcs
end

function icebreaker_x1_modifier_skin:GetModifierConstantHealthRegen()
	return self.regen
end

function icebreaker_x1_modifier_skin:GetModifierIncomingPhysicalDamage_Percentage()
	return -self.reduction
end

function icebreaker_x1_modifier_skin:OnOrder(params)
	if params.unit ~= self.parent then return end

	if params.order_type == 5 or params.order_type == 6 then
		self:Destroy()
	end
end

------------------------------------------------------------------

function icebreaker_x1_modifier_skin:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf"
end

function icebreaker_x1_modifier_skin:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_x1_modifier_skin:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Ancient_Apparition.ColdFeetCast") end
end