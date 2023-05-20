_modifier_petrified = class({})

--------------------------------------------------------------------------------

function _modifier_petrified:IsPurgable()
	return false
end

function _modifier_petrified:IsHidden()
	return false
end

function _modifier_petrified:GetTexture()
	return "_modifier_petrified"
end

function _modifier_petrified:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function _modifier_petrified:GetPriority()
  return MODIFIER_PRIORITY_HIGH
end

--------------------------------------------------------------------------------

function _modifier_petrified:OnCreated(kv)
  AddStatusEfx(self:GetAbility(), "_modifier_petrified_status_efx", self:GetCaster(), self:GetParent())
  
  local special = kv.special or 0

	if IsServer() then self:PlayEfxStart(special) end
end

function _modifier_petrified:OnRefresh(kv)
end

function _modifier_petrified:OnRemoved()
  RemoveStatusEfx(self:GetAbility(), "_modifier_petrified_status_efx", self:GetCaster(), self:GetParent())
end

--------------------------------------------------------------------------------

function _modifier_petrified:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true
	}

	return state
end

function _modifier_petrified:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK
	}
	return funcs
end

function _modifier_petrified:GetDisableHealing()
  return 1
end

function _modifier_petrified:GetModifierHPRegenAmplify_Percentage()
  return -99999
end

function _modifier_petrified:GetModifierPhysical_ConstantBlock(keys)
  if keys.attacker == self:GetParent() then
    return keys.damage * 0.5
  end

  if IsServer() then self:GetParent():EmitSound("Generic.Petrified.Block") end

	return keys.damage * 0.5
end

function _modifier_petrified:GetModifierMagical_ConstantBlock(keys)
	if keys.damage_flags == DOTA_DAMAGE_FLAG_BYPASSES_BLOCK then return 0 end
  if IsServer() then self:GetParent():EmitSound("Generic.Petrified.Block") end

	return keys.damage * 0.5
end

--------------------------------------------------------------------------------

function _modifier_petrified:GetStatusEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
  --return "particles/status_fx/status_effect_statue.vpcf"
end

function _modifier_petrified:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function _modifier_petrified:PlayEfxStart(special)
	local particle_cast = "particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff_stoned.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector( 0,0,0 ), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

  if special == 0 then
	  if IsServer() then self:GetParent():EmitSound("Hero_Medusa.StoneGaze.Stun") end
  end
end