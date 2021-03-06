bocuse_u_modifier_autocast = class ({})

function bocuse_u_modifier_autocast:IsHidden()
    return true
end

function bocuse_u_modifier_autocast:IsPurgable()
    return false
end

-----------------------------------------------------------

function bocuse_u_modifier_autocast:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function bocuse_u_modifier_autocast:OnRefresh(kv)
end

------------------------------------------------------------

function bocuse_u_modifier_autocast:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function bocuse_u_modifier_autocast:OnAttackLanded(keys)
    if not (keys.attacker == self.parent) then return end
    if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
    if self.parent:PassivesDisabled() then return end

    local chance = 10
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

    if RandomFloat(1, 100) > chance then return end

    -- UP 4.41
    if self.ability:GetRank(41) then
        self.parent:AddNewModifier(self.caster, self.ability, "bocuse_u_modifier_mise", {
            duration = self.ability:CalcStatus(1.5, self.caster, self.parent),
            reset = 1
        })
    end
end