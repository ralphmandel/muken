bocuse_3_modifier_sauce = class ({})

function bocuse_3_modifier_sauce:IsHidden()
    return true
end

function bocuse_3_modifier_sauce:IsPurgable()
    return false
end

-----------------------------------------------------------

function bocuse_3_modifier_sauce:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function bocuse_3_modifier_sauce:OnRefresh(kv)
end

------------------------------------------------------------

function bocuse_3_modifier_sauce:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function bocuse_3_modifier_sauce:OnTakeDamage(keys)
    if keys.attacker == nil then return end
    if keys.attacker:IsBaseNPC() == false then return end
    if not (keys.attacker == self.parent) then return end
    if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
    if keys.attacker:PassivesDisabled() then return end
    if not (keys.damage_type == DAMAGE_TYPE_PHYSICAL) then return end
    if keys.damage_flags == DOTA_DAMAGE_FLAG_HPLOSS then return end

    local chance = self.ability:GetSpecialValueFor("chance")

	-- UP 3.31
	if self.ability:GetRank(31) then
        chance = chance + 10
	end

	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

    if keys.inflictor then
        if keys.inflictor:GetAbilityName() == "bocuse_1__julienne" then
            chance = 100
        end
    end

	if RandomFloat(1, 100) <= chance then
		keys.unit:AddNewModifier(self.caster, self.ability, "bocuse_3_modifier_mark", {})
	end
end