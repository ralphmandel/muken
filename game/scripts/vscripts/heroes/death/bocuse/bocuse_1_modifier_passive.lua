bocuse_1_modifier_passive = class({})

function bocuse_1_modifier_passive:IsHidden() return true end
function bocuse_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function bocuse_1_modifier_passive:OnRefresh(kv)
end

function bocuse_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bocuse_1_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end

  local bleeding = keys.target:FindModifierByNameAndCaster("_modifier_bleeding", self.caster)
	local bleeding_duration = CalcStatus(self.ability:GetSpecialValueFor("bleeding_duration"), self.caster, keys.target)
	local chance = self.ability:GetSpecialValueFor("special_bleeding_chance")

  if self.parent:HasModifier("bocuse_1_modifier_julienne") then chance = 100 end

	if RandomFloat(0, 100) < chance then
    if bleeding then
      bleeding:SetDuration(bleeding_duration, true)
    else
      AddModifier(keys.target, self.caster, self.ability, "_modifier_bleeding", {
        duration = bleeding_duration
      }, false)
    end
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------