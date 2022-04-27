item_branch_green = class({})

function item_branch_green:Spawn()
	self:SetCombineLocked(true)
end

function item_branch_green:OnSpellStart()
	if self:IsCombineLocked() then
		self:SetCombineLocked(false)
	else
		self:SetCombineLocked(true)
	end
end