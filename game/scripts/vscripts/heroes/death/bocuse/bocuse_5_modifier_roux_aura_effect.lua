bocuse_5_modifier_roux_aura_effect = class ({})

function bocuse_5_modifier_roux_aura_effect:IsHidden() return true end
function bocuse_5_modifier_roux_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_5_modifier_roux_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.radius = self.ability:GetAOERadius()

  AddBonus(self.ability, "AGI", self.parent, self.ability:GetSpecialValueFor("special_agi"), 0, nil)
  AddModifier(self.parent, self.ability, "_modifier_movespeed_debuff", {percent = self.ability:GetSpecialValueFor("slow")}, false)

  self:ApplyPull()

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
  local root = AddModifier(self.parent, self.ability, "bocuse_5_modifier_root", {
    duration = self.ability:GetSpecialValueFor("root_duration")
  }, true)

  root:SetEndCallback(function(interrupted)
    if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("root_interval")) end
  end)

  if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

function bocuse_5_modifier_roux_aura_effect:ApplyPull()
  local target = nil
  local distance = 9999

  local thinkers = Entities:FindAllByClassnameWithin("npc_dota_thinker", self.parent:GetOrigin(), self.radius + 50)
  for _, mod_thinker in pairs(thinkers) do
    local modifier = mod_thinker:FindModifierByNameAndCaster("bocuse_5_modifier_roux", self.ability:GetCaster())
    local dist_diff = CalcDistanceBetweenEntityOBB(self.parent, mod_thinker)
    if modifier then
      if dist_diff < distance then
        target = mod_thinker
        distance = dist_diff
      end
    end
  end

  if target then
    local loc = target:GetOrigin()
    local duration = distance / (self.radius * 1.5)
    AddModifier(self.parent, self.ability, "_modifier_pull", {duration = duration, x = loc.x, y = loc.y}, false)
  end
end


-- EFFECTS -----------------------------------------------------------

function bocuse_5_modifier_roux_aura_effect:GetEffectName()
	return "particles/bocuse/bocuse_roux_debuff.vpcf"
end

function bocuse_5_modifier_roux_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end