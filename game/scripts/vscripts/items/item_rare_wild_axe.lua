item_rare_wild_axe = class({})

function item_rare_wild_axe:CalcStatus(duration, caster, target)
	local time = duration
	local caster_int = nil
	local caster_mnd = nil
	local target_res = nil

	if caster ~= nil then
		caster_int = caster:FindModifierByName("_1_INT_modifier")
		caster_mnd = caster:FindModifierByName("_2_MND_modifier")
	end

	if target ~= nil then
		target_res = target:FindModifierByName("_2_RES_modifier")
	end

	if caster == nil then
		if target ~= nil then
			if target_res then time = time * (1 - target_res:GetStatus()) end
		end
	else
		if target == nil then
			if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
			else
				if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
				if target_res then time = time * (1 - target_res:GetStatus()) end
			end
		end
	end

	if time < 0 then time = 0 end
	return time
end

function item_rare_wild_axe:AddBonus(string, target, const, percent, time)
	local att = target:FindAbilityByName(string)
	if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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
		[2] = "item_branch_yellow",
		[3] = "item_branch_red",
		[4] = "item_branch_green"
	}

	local chance = self:GetSpecialValueFor("chance")
	if RandomInt(1, 100) <= chance then
		local item = CreateItem(branches[RandomInt(1, 4)], nil, nil)
		local pos = tree:GetAbsOrigin()
		local drop = CreateItemOnPositionSync(pos, item)
		local pos_launch = pos + RandomVector(RandomFloat(150,200))
		item:LaunchLoot(false, 100, 0.5, pos_launch)
	end

	tree:CutDownRegrowAfter(120, caster:GetTeamNumber())
end