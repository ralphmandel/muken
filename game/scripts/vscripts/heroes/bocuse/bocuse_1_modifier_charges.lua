bocuse_1_modifier_charges = class({})

function bocuse_1_modifier_charges:IsHidden()
	return false
end

function bocuse_1_modifier_charges:IsPurgable()
    return false
end

function bocuse_1_modifier_charges:GetTexture()
	return "bocuse_charges"
end

--------------------------------------------------------------------------------

function bocuse_1_modifier_charges:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.hits = self.ability:GetSpecialValueFor("hits")

	if IsServer() then
		self:SetStackCount(0)
		self.ability:SetActivated(false)
	end
end

function bocuse_1_modifier_charges:OnRefresh( kv )
	-- if self.ability:GetRank(22) then
	-- 	self.hits = self.ability:GetSpecialValueFor("hits") - 1
	-- end
end

function bocuse_1_modifier_charges:OnRemoved()
end

--------------------------------------------------------------------------------

function bocuse_1_modifier_charges:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
	
	return funcs
end


function bocuse_1_modifier_charges:GetModifierProcAttack_Feedback( params )
	local charges = self.ability:GetSpecialValueFor("charges")

	-- up 1.41
    if self.ability:GetRank(41) then
		charges = charges + 4
	end

	if self:GetStackCount() == charges then return end

	self.hits = self.hits - 1

	if self.hits < 1 then
		self:ResetHits()
		self:IncrementStackCount()
		self:ResetHits()
		self:CheckCharges()
		self:StartIntervalThink(10)
	end
end

function bocuse_1_modifier_charges:OnIntervalThink()
	self:ResetHits()

    -- UP 1.11
    if self.ability:GetRank(11) then
		local charges = self.ability:GetSpecialValueFor("charges")

		-- up 1.41
		if self.ability:GetRank(41) then
			charges = charges + 4
		end

		if self:GetStackCount() < charges then
			self:IncrementStackCount()
			self:CheckCharges()
			return
		end
	end

	self:StartIntervalThink(-1)
end

function bocuse_1_modifier_charges:CheckCharges()
	if self:GetStackCount() > 0 then
		self.ability:SetActivated(true)
	else
		self.ability:SetActivated(false)
	end
end

function bocuse_1_modifier_charges:ResetHits()
	self.hits = self.ability:GetSpecialValueFor("hits")

	-- if self.ability:GetRank(22) then
	-- 	self.hits = self.hits - 1
	-- end
end