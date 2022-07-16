genuine_u_modifier_caster = class({})

function genuine_u_modifier_caster:IsHidden()
	return false
end

function genuine_u_modifier_caster:IsPurgable()
	return false
end

-----------------------------------------------------------

function genuine_u_modifier_caster:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function genuine_u_modifier_caster:OnRefresh(kv)
end

function genuine_u_modifier_caster:OnRemoved(kv)
	local passive = self.caster:FindModifierByName("genuine_u_modifier_passive")
	if passive then passive:StopEfxBuff() end
end

-----------------------------------------------------------

function genuine_u_modifier_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_HERO_KILLED
	}
	
	return funcs
end

function genuine_u_modifier_caster:GetModifierOverrideAttackDamage(keys)
	if keys.target == nil then return 0 end
	if keys.target:IsBaseNPC() == false then return 0 end
	if keys.target:HasModifier("genuine_u_modifier_target") then return 0 end
	return 1
end

function genuine_u_modifier_caster:GetAbsoluteNoDamagePhysical(keys)
	if keys.attacker == nil then return 0 end
	if keys.attacker:IsBaseNPC() == false then return 0 end
	if keys.attacker:HasModifier("genuine_u_modifier_target") then return 0 end
	return 1
end

function genuine_u_modifier_caster:GetAbsoluteNoDamageMagical(keys)
	if keys.attacker == nil then return 0 end
	if keys.attacker:IsBaseNPC() == false then return 0 end
	if keys.attacker:HasModifier("genuine_u_modifier_target") then return 0 end
	return 1
end

function genuine_u_modifier_caster:GetAbsoluteNoDamagePure(keys)
	if keys.attacker == nil then return 0 end
	if keys.attacker:IsBaseNPC() == false then return 0 end
	if keys.attacker:HasModifier("genuine_u_modifier_target") then return 0 end
	return 1
end

function genuine_u_modifier_caster:OnHeroKilled(keys)
	if keys.target == nil then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.target:HasModifier("genuine_u_modifier_target") == false then return end

	-- UP 7.21
	if self.ability:GetRank(21) then
		self.ability:EndCooldown()
	end
end