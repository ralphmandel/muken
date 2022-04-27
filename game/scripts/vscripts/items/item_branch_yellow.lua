item_branch_yellow = class({})

function item_branch_yellow:Spawn()
	self:SetCombineLocked(true)
end

function item_branch_yellow:OnSpellStart()
	if self:IsCombineLocked() then
		self:SetCombineLocked(false)
	else
		self:SetCombineLocked(true)
	end
end