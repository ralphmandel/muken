bocuse_5_modifier_roux_aura_effect = class ({})

function bocuse_5_modifier_roux_aura_effect:IsHidden() return true end
function bocuse_5_modifier_roux_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_5_modifier_roux_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  AddModifier(self.parent, self.caster, self.ability, "_modifier_movespeed_debuff", {
    percent = self.ability:GetSpecialValueFor("slow")
  }, false)

	AddBonus(self.ability, "AGI", self.parent, self.ability:GetSpecialValueFor("special_agi"), 0, nil)

	if IsServer() then
    self.parent:EmitSound("Hero_Bristleback.ViscousGoo.Target")
		self:StartIntervalThink(self.ability:GetSpecialValueFor("root_interval"))
	end
end

function bocuse_5_modifier_roux_aura_effect:OnRefresh(kv)
end

function bocuse_5_modifier_roux_aura_effect:OnRemoved(kv)
	RemoveBonus(self.ability, "AGI", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_5_modifier_roux_aura_effect:OnIntervalThink()
  AddModifier(self.parent, self.caster, self.ability, "bocuse_5_modifier_root", {
    duration = self.ability:GetSpecialValueFor("root_duration")
  }, true)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bocuse_5_modifier_roux_aura_effect:GetEffectName()
	return "particles/bocuse/bocuse_roux_debuff.vpcf"
end

function bocuse_5_modifier_roux_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end