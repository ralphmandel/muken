item_branch_blue = class({})

function item_branch_blue:Spawn()
	self:SetCombineLocked(true)
end

function item_branch_blue:OnSpellStart()
	if self:IsCombineLocked() then
		self:SetCombineLocked(false)
	else
		self:SetCombineLocked(true)
	end
end