bocuse_4_modifier_mirepoix = class ({})

function bocuse_4_modifier_mirepoix:IsHidden() return false end
function bocuse_4_modifier_mirepoix:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_4_modifier_mirepoix:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  local bkb_duration = self.ability:GetSpecialValueFor("special_bkb_duration")
	self.init_model_scale = self.ability:GetSpecialValueFor("init_model_scale")
	self.atk_range = self.ability:GetSpecialValueFor("atk_range")
  self.range = 0

	self.ability:EndCooldown()
	self.ability:SetActivated(false)

  AddBonus(self.ability, "_1_AGI", self.parent, self.ability:GetSpecialValueFor("agi"), 0, nil)
  AddBonus(self.ability, "_2_RES", self.parent, self.ability:GetSpecialValueFor("res"), 0, nil)

  if bkb_duration > 0 then
    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_bkb", {
      duration = bkb_duration
    })
  end

	if IsServer() then
		self.parent:StartGesture(ACT_DOTA_TELEPORT_END)
		self:StartIntervalThink(FrameTime())
		self:PlayEfxStart()
	end
end

function bocuse_4_modifier_mirepoix:OnRefresh(kv)
end

function bocuse_4_modifier_mirepoix:OnRemoved()
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)

  RemoveBonus(self.ability, "_1_AGI", self.parent)
  RemoveBonus(self.ability, "_2_RES", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_bkb", self.ability)

	if self.parent:IsAlive() then
		self.parent:AddNewModifier(self.caster, self.ability, "bocuse_4_modifier_end", {
			duration = 2,
			range = self.range
		})
	else
		self.parent:SetModelScale(self.init_model_scale)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_4_modifier_mirepoix:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
    MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK,
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	
	return funcs
end

function bocuse_4_modifier_mirepoix:GetModifierAttackRangeBonus()
  return self.range
end

function bocuse_4_modifier_mirepoix:GetModifierPhysical_ConstantBlock()
  return self:GetAbility():GetSpecialValueFor("special_block")
end

function bocuse_4_modifier_mirepoix:GetModifierMagical_ConstantBlock()
  return self:GetAbility():GetSpecialValueFor("special_block")
end

function bocuse_4_modifier_mirepoix:GetModifierConstantHealthRegen()
  return self:GetAbility():GetSpecialValueFor("special_hp_regen")
end


function bocuse_4_modifier_mirepoix:OnIntervalThink()
	self.range = self.range + 2
	local model_scale = self.init_model_scale * (1 + (self.range * 0.003125))
	self.parent:SetModelScale(model_scale)
	self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
	if self.range >= self.atk_range then
		self:StartIntervalThink(-1)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

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