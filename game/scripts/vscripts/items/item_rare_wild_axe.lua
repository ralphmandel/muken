item_rare_wild_axe = class({})
LinkLuaModifier("item_rare_wild_axe_mod_passive", "items/item_rare_wild_axe_mod_passive", LUA_MODIFIER_MOTION_NONE)

function item_rare_wild_axe:CalcStatus(duration, caster, target)
    local time = duration
	local base_stats_caster = nil
	local base_stats_target = nil

    if caster ~= nil then
		base_stats_caster = caster:FindAbilityByName("base_stats")
	end

	if target ~= nil then
		base_stats_target = target:FindAbilityByName("base_stats")
	end

	if caster == nil then
		if target ~= nil then
			if base_stats_target then
				local value = base_stats_target.stat_total["RES"] * 0.4
				local calc = (value * 6) / (1 +  (value * 0.06))
				time = time * (1 - (calc * 0.01))
			end
		end
	else
		if target == nil then
			if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
			else
				if base_stats_caster and base_stats_target then
					local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
					if value > 0 then
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 + (calc * 0.01))
					else
						value = -1 * value
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 - (calc * 0.01))
					end
				end
			end
		end
	end

    if time < 0 then time = 0 end
    return time
end

function item_rare_wild_axe:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function item_rare_wild_axe:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function item_rare_wild_axe:GetIntrinsicModifierName()
	return "item_rare_wild_axe_mod_passive"
end

function item_rare_wild_axe:OnSpellStart()
	local caster = self:GetCaster()
	local tree = self:GetCursorTarget()

	local branches = {
		[1] = "item_branch_blue",
		[2] = "item_branch_red",
		[3] = "item_branch_green"
	}

	local chance = self:GetSpecialValueFor("chance")
	if RandomInt(1, 100) <= chance then
		local item = CreateItem(branches[RandomInt(1, 3)], nil, nil)
		local pos = tree:GetAbsOrigin()
		local drop = CreateItemOnPositionSync(pos, item)
		local pos_launch = pos + RandomVector(RandomFloat(150,200))
		item:LaunchLoot(false, 100, 0.5, pos_launch)
	end

	tree:CutDownRegrowAfter(120, caster:GetTeamNumber())
end