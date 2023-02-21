bocuse_5_modifier_roux_aura_effect = class ({})

function bocuse_5_modifier_roux_aura_effect:IsHidden() return true end
function bocuse_5_modifier_roux_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_5_modifier_roux_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		percent = self.ability:GetSpecialValueFor("slow")
	})

	if IsServer() then
    self.parent:EmitSound("Hero_Bristleback.ViscousGoo.Target")
		self:StartIntervalThink(self.ability:GetSpecialValueFor("root_interval"))
	end
end

function bocuse_5_modifier_roux_aura_effect:OnRefresh(kv)
end

function bocuse_5_modifier_roux_aura_effect:OnRemoved(kv)
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_5_modifier_roux_aura_effect:OnIntervalThink()
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {
		duration = CalcStatus(self.ability:GetSpecialValueFor("root_duration"), self.caster, self.parent), effect = 3
	})
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bocuse_5_modifier_roux_aura_effect:GetEffectName()
	return "particles/bocuse/bocuse_roux_debuff.vpcf"
end

function bocuse_5_modifier_roux_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end