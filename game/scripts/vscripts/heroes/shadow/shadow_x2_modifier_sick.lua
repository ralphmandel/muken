shadow_x2_modifier_sick = class ({})

function shadow_x2_modifier_sick:IsHidden()
    return true
end

function shadow_x2_modifier_sick:IsPurgable()
    return false
end

function shadow_x2_modifier_sick:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    -- local illusions = FindUnitsInRadius(
	-- 	self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, FIND_UNITS_EVERYWHERE,
	-- 	DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	-- 	0, 0, false
	-- )

	-- for _,illusion in pairs(illusions) do
    --     illusion:AddNewModifier(self.caster, self.ability, "_modifier_no_bar", {duration = self:GetDuration()})
    -- end
end

function shadow_x2_modifier_sick:OnRefresh(kv)
end