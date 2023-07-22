bocuse_4_modifier_mirepoix = class ({})

function bocuse_4_modifier_mirepoix:IsHidden() return false end
function bocuse_4_modifier_mirepoix:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_4_modifier_mirepoix:OnCreated(kv)
  if not IsServer() then return end

  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.max_barrier = self.parent:GetMaxHealth() * self.ability:GetSpecialValueFor("max_barrier") * 0.01
  self.barrier = self.max_barrier
  self:SetHasCustomTransmitterData(true)

	self.init_model_scale = self.ability:GetSpecialValueFor("init_model_scale")
	self.atk_range = self.ability:GetSpecialValueFor("atk_range")
  self.range = 0

	self.ability:EndCooldown()
	self.ability:SetActivated(false)

  AddBonus(self.ability, "AGI", self.parent, self.ability:GetSpecialValueFor("special_agi"), 0, nil)
  AddStatusEfx(self.ability, "bocuse_4_modifier_mirepoix_status_efx", self.caster, self.parent)

  self.parent:StartGesture(ACT_DOTA_TELEPORT_END)
  self:StartIntervalThink(0.1)
  self:PlayEfxStart()
end

function bocuse_4_modifier_mirepoix:OnRefresh(kv)
end

function bocuse_4_modifier_mirepoix:OnRemoved()
  if not IsServer() then return end

	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)

  RemoveBonus(self.ability, "AGI", self.parent)
  RemoveStatusEfx(self.ability, "bocuse_4_modifier_mirepoix_status_efx", self.caster, self.parent)

	if self.parent:IsAlive() then
    AddModifier(self.parent, self.caster, self.ability, "bocuse_4_modifier_end", {duration = 2, range = self.range}, false)
	else
		self.parent:SetModelScale(self.init_model_scale)
	end
end

function bocuse_4_modifier_mirepoix:AddCustomTransmitterData()
  return {
    barrier = self.barrier,
  }
end

function bocuse_4_modifier_mirepoix:HandleCustomTransmitterData(data)
  self.barrier = data.barrier
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_4_modifier_mirepoix:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
	}
	
	return funcs
end

function bocuse_4_modifier_mirepoix:GetModifierAttackRangeBonus()
  return self.range
end

function bocuse_4_modifier_mirepoix:GetModifierIncomingDamageConstant(keys)  
  if not IsServer() then return self.barrier end

  local damage = keys.damage * self.ability:GetSpecialValueFor("barrier_absorption") * 0.01

  self.barrier = self.barrier - damage
  if self.barrier < 0 then self:Destroy() end

  return -damage
end

function bocuse_4_modifier_mirepoix:OnIntervalThink()
  if not IsServer() then return end

  local interval = 0.2

	if self.range < self.atk_range then
    self.range = self.range + 4
    local model_scale = self.init_model_scale * (1 + (self.range * 0.003125))
    self.parent:SetModelScale(model_scale)
    self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
	end

  local barrier_regen = self.max_barrier * self.ability:GetSpecialValueFor("barrier_regen") * interval * 0.01
  if self.barrier < self.max_barrier then self.barrier = self.barrier + barrier_regen end
  self:SendBuffRefreshToClients()
  self:StartIntervalThink(0.2)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bocuse_4_modifier_mirepoix:GetStatusEffectName()
  return "particles/status_fx/status_effect_shield_rune.vpcf"
end

function bocuse_4_modifier_mirepoix:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function bocuse_4_modifier_mirepoix:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end

function bocuse_4_modifier_mirepoix:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bocuse_4_modifier_mirepoix:PlayEfxStart()
	local paticle = "particles/econ/items/wisp/wisp_relocate_teleport_ti7_out.vpcf"
	local effect_cast = ParticleManager:CreateParticle(paticle, PATTACH_POINT_FOLLOW, self.parent)

	if IsServer() then self.parent:EmitSound("DOTA_Item.BlackKingBar.Activate") end
end