shaman_5_modifier_passive = class({})

function shaman_5_modifier_passive:IsHidden() return true end
function shaman_5_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function shaman_5_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.efx_enabled = false

  if IsServer() then self:PlayEfxStart() end
end

function shaman_5_modifier_passive:OnRefresh(kv)
end

function shaman_5_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function shaman_5_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_PROJECTILE_NAME,
    MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function shaman_5_modifier_passive:GetModifierProjectileName(keys)
  if self:GetParent():PassivesDisabled() == false then
    return "particles/econ/items/shadow_fiend/sf_desolation/sf_base_attack_desolation_fire_arcana.vpcf"
  end
end

function shaman_5_modifier_passive:OnStateChanged(keys)
  if keys.unit ~= self.parent then return end

  if IsServer() then
    if self.parent:PassivesDisabled() then
      self:StopEfxStart()
    else
      self:PlayEfxStart()
    end
  end
end

function shaman_5_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
  if self.parent:PassivesDisabled() then return end
  if keys.target:HasModifier("shaman_5_modifier_ignition") then return end

  AddModifier(keys.target, self.caster, self.ability, "shaman_5_modifier_fire", {
    duration = self.ability:GetSpecialValueFor("fire_duration")
  }, true)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function shaman_5_modifier_passive:PlayEfxStart()
  if self.efx_enabled == true then return end
  local model_name = "models/items/shadowshaman/shaman_charmer_of_firesnake_off_hand/shaman_charmer_of_firesnake_off_hand.vmdl"
  local particle_name = "particles/econ/items/shadow_shaman/shadow_shaman_charmer_firesnake/shadow_shaman_charmer_firesnake_offhand.vpcf"
  ApplyParticleOnCosmetic(self.parent, model_name, particle_name, "")
  self.efx_enabled = true
end

function shaman_5_modifier_passive:StopEfxStart()
  if self.efx_enabled == false then return end
  local model_name = "models/items/shadowshaman/shaman_charmer_of_firesnake_off_hand/shaman_charmer_of_firesnake_off_hand.vmdl"
  local particle_name = "particles/econ/items/shadow_shaman/shadow_shaman_charmer_firesnake/shadow_shaman_charmer_firesnake_offhand.vpcf"
  DestroyParticleOnCosmetic(self.parent, model_name, particle_name, false)
  self.efx_enabled = false
end