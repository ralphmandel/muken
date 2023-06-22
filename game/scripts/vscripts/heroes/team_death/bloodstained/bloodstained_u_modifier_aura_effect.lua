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
  if self.parent:HasModifier("bloodstained_u_modifier_slow") then return end

  AddModifier(self.parent, self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
    duration = self.ability:GetSpecialValueFor("slow_duration"), percent = 100
  }, true)
	
	self:CreateCopy()
end

function bloodstained_u_modifier_aura_effect:CreateCopy()
  local copy_number = self.ability:GetSpecialValueFor("copy_number")
	local total_hp_stolen = self.parent:GetMaxHealth() * self.ability:GetSpecialValueFor("hp_stolen") * copy_number * 0.01
	if total_hp_stolen > self.parent:GetHealth() then total_hp_stolen = self.parent:GetHealth() end

	local illu_array = CreateIllusions(self.caster, self.parent, {
		outgoing_damage = -65,
		incoming_damage = 500,
		bounty_base = 0,
		bounty_growth = 0,
		duration = -1
	}, copy_number, 64, false, true)

	for _,illu in pairs(illu_array) do
    local mod = AddModifier(illu, self.caster, self.ability,"bloodstained_u_modifier_copy", {
      duration = self.ability:GetSpecialValueFor("copy_duration"), hp = math.floor(total_hp_stolen / copy_number)
    }, false)

		mod.target = self.parent
    mod.slow_mod = AddModifier(self.parent, self.caster, self.ability, "bloodstained_u_modifier_slow", {}, false)
    mod.target_mod = AddModifier(self.parent, self.caster, self.ability, "bloodstained__modifier_target_hp", {
      hp = math.floor(total_hp_stolen / copy_number)
    }, false)


		self:PlayEfxTarget(self.parent, mod)
		illu:SetForceAttackTarget(self.parent)

		local loc = self.parent:GetAbsOrigin() + RandomVector(100)
		illu:SetAbsOrigin(loc)
		illu:SetForwardVector((self.parent:GetAbsOrigin() - loc):Normalized())
		FindClearSpaceForUnit(illu, loc, true)
	end
end

-- EFFECTS -----------------------------------------------------------

function bloodstained_u_modifier_aura_effect:GetEffectName()
	return "particles/bloodstained/bloodstained_thirst_owner_smoke_dark.vpcf"
end

function bloodstained_u_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bloodstained_u_modifier_aura_effect:PlayEfxTarget(target, mod)
	if target == nil then return end
	local string = "particles/bloodstained/bloodstained_u_track1.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(particle, 3, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	if mod then mod:AddParticle(particle, false, false, -1, false, true) end

	if IsServer() then target:EmitSound("Hero_LifeStealer.OpenWounds") end
end