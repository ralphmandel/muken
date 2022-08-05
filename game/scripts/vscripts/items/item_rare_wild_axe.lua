item_rare_wild_axe = class({})
LinkLuaModifier("item_rare_wild_axe_mod_passive", "items/item_rare_wild_axe_mod_passive", LUA_MODIFIER_MOTION_NONE)

function item_rare_wild_axe:CalcStatus(duration, caster, target)
	if caster == nil or target == nil then return end
	if IsValidEntity(caster) == false or IsValidEntity(target) == false then return end
	local base_stats = caster:FindAbilityByName("base_stats")

	if caster:GetTeamNumber() == target:GetTeamNumber() then
		if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
	else
		if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
		duration = duration * (1 - target:GetStatusResistance())
	end
	
	return duration
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