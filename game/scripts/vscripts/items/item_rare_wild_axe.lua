item_rare_wild_axe = class({})
LinkLuaModifier("item_rare_wild_axe_mod_passive", "items/item_rare_wild_axe_mod_passive", LUA_MODIFIER_MOTION_NONE)

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