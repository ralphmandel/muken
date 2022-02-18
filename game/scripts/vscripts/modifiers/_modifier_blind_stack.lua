_modifier_blind_stack = class({})

--------------------------------------------------------------------------------
function _modifier_blind_stack:IsPurgable()
	return true
end

function _modifier_blind_stack:IsHidden()
	return false
end

function _modifier_blind_stack:IsDebuff()
	return true
end

function _modifier_blind_stack:GetTexture()
	return "_modifier_blind"
end

--------------------------------------------------------------------------------

function _modifier_blind_stack:OnCreated( kv )
	self.parent = self:GetParent()
	self:Check()
end

function _modifier_blind_stack:OnRefresh( kv )
	self:Check()
end

--------------------------------------------------------------------------------
function _modifier_blind_stack:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
	}
	return funcs
end

function _modifier_blind_stack:GetBonusVisionPercentage()
	return -self:GetStackCount()
end

function _modifier_blind_stack:Check()
	local total = 0
	local mods =  self.parent:FindAllModifiersByName("_modifier_blind")
	for _,mod in pairs(mods) do
		total = total + ((1 - total) * mod:GetPercent() * 0.01)
	end
	total = total*100
	if total == 0 then self:Destroy() return end
	self:SetStackCount(total)
end