item_branch_red = class({})

function item_branch_red:Spawn()
	self:SetCombineLocked(true)
end

function item_branch_red:OnSpellStart()
	if self:IsCombineLocked() then
		self:SetCombineLocked(false)
	else
		self:SetCombineLocked(true)
	end
end