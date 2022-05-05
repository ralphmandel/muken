item_branch_red = class({})

function item_branch_red:OnSpellStart()
	local caster = self:GetCaster()

	if self:IsCombineLocked() then
		self:SetCombineLocked(false)
		for i = 0, 8, 1 do
			local item_slot = caster:GetItemInSlot(i)
			if self:CanCombine(item_slot, "item_branch_green", "item_recipe_potion_heal") then return end
			if self:CanCombine(item_slot, "item_branch_blue", "item_recipe_potion_recover") then return end
			if self:CanCombine(item_slot, "item_branch_yellow", "item_recipe_potion_strenght") then return end
		end
	else
		self:SetCombineLocked(true)
	end

	self:StartCooldown(1)
end

function item_branch_red:CanCombine(item, branch_string, recipe_string)
	local caster = self:GetCaster()
	
	if item then
		if item:GetName() == branch_string
		and item:IsCombineLocked() == false then
			caster:AddItemByName(recipe_string)
			return true
		end
	end

	return false
end