bloodstained_u_modifier_aura_effect = class({})

function bloodstained_u_modifier_aura_effect:IsHidden() return false end
function bloodstained_u_modifier_aura_effect:IsPurgable() return false end
function bloodstained_u_modifier_aura_effect:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_u_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function bloodstained_u_modifier_aura_effect:OnRefresh(kv)
end

function bloodstained_u_modifier_aura_effect:OnRemoved()
	self:ApplyBloodIllusion()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_u_modifier_aura_effect:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true
	}

	return state
end

function bloodstained_u_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
	}

	return funcs
end

function bloodstained_u_modifier_aura_effect:GetModifierAvoidDamage(keys)
  if keys.attacker:HasModifier(self:GetName()) == false then return 1 end
	return 0
end

-- UTILS -----------------------------------------------------------

function bloodstained_u_modifier_aura_effect:ApplyBloodIllusion()
	if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:IsAlive() == false then return end
	if self.parent:IsIllusion() then return end
	if self.parent:IsHero() == false then return end
	if self.ability:IsActivated() then return end
  if self.parent:HasModifier("bloodstained__modifier_bloodstained") then return end

  AddModifier(self.parent, self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
    duration = self.ability:GetSpecialValueFor("slow_duration"), percent = 100
  }, true)
	
	self:CreateCopy()
end

function bloodstained_u_modifier_aura_effect:CreateCopy()
  if not IsServer() then return end

  local copy_number = self.ability:GetSpecialValueFor("copy_number")
	local hp_stolen = math.floor(self.parent:GetMaxHealth() * self.ability:GetSpecialValueFor("hp_stolen") * 0.01)

	local illu_array = CreateIllusions(self.caster, self.parent, {
		outgoing_damage = -85,
		incoming_damage = -100,
		bounty_base = 0,
		bounty_growth = 0,
		duration = -1
	}, copy_number, 64, false, true)

	for _,illu in pairs(illu_array) do
    AddModifier(illu, self.caster, self.ability,"bloodstained__modifier_copy", {
      duration = self.ability:GetSpecialValueFor("copy_duration"),
      hp_stolen = hp_stolen, target_index = self.parent:GetEntityIndex()
    }, false)

		illu:SetForceAttackTarget(self.parent)

		local loc = self.parent:GetAbsOrigin() + RandomVector(100)
    FindClearSpaceForUnit(illu, loc, true)
		illu:SetForwardVector((self.parent:GetAbsOrigin() - loc):Normalized())
	end
end

-- EFFECTS -----------------------------------------------------------

function bloodstained_u_modifier_aura_effect:GetEffectName()
	return "particles/bloodstained/bloodstained_thirst_owner_smoke_dark.vpcf"
end

function bloodstained_u_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end