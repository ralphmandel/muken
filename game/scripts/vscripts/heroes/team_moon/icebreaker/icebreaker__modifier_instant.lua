icebreaker__modifier_instant = class({})

function icebreaker__modifier_instant:IsHidden() return true end
function icebreaker__modifier_instant:IsPurgable() return false end
function icebreaker__modifier_instant:GetPriority() return MODIFIER_PRIORITY_HIGH end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_instant:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  AddStatusEfx(self.ability, "icebreaker__modifier_instant_status_efx", self.caster, self.parent)
  self:PlayEfxStart()
end

function icebreaker__modifier_instant:OnRefresh( kv )
end

function icebreaker__modifier_instant:OnRemoved( kv )
  RemoveStatusEfx(self.ability, "icebreaker__modifier_instant_status_efx", self.caster, self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__modifier_instant:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_INVISIBLE] = false
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker__modifier_instant:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf"
end

function icebreaker__modifier_instant:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function icebreaker__modifier_instant:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Icebreaker.Paralyse") end
	if IsServer() then self.parent:EmitSound("Hero_DrowRanger.Marksmanship.Target") end
end