bloodmage_0_modifier_sacrifice = class ({})
local tempTable = require("libraries/tempTable")

function bloodmage_0_modifier_sacrifice:IsHidden()
    return false
end

function bloodmage_0_modifier_sacrifice:IsPurgable()
    return false
end

-----------------------------------------------------------

function bloodmage_0_modifier_sacrifice:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.hp_percent = self.ability:GetSpecialValueFor("hp_percent") * 0.01
	self.stack_percent = self.ability:GetSpecialValueFor("stack_percent") * 0.01
	self.converted_health = 0
	if IsServer() then
		self:SetStackCount(0)
	end

	Timers:CreateTimer((0.2), function()
		self.parent:SetMana(0)
	end)
end

function bloodmage_0_modifier_sacrifice:OnRefresh(kv)
	self.hp_percent = self.ability:GetSpecialValueFor("hp_percent") * 0.01
	self.stack_percent = self.ability:GetSpecialValueFor("stack_percent") * 0.01
end

function bloodmage_0_modifier_sacrifice:OnRemoved(kv)
end

------------------------------------------------------------

function bloodmage_0_modifier_sacrifice:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_MANA_GAINED
	}

	return funcs
end

function bloodmage_0_modifier_sacrifice:GetModifierHealthBonus(keys)
    return -self.converted_health
end

function bloodmage_0_modifier_sacrifice:OnManaGained(keys)
    if keys.unit ~= self.parent then return end
	if keys.gain > 0 then
		keys.unit:SetMana(keys.unit:GetMana() - keys.gain)
	end
end

function bloodmage_0_modifier_sacrifice:AddStack()
	local stack_duration = self.ability:GetSpecialValueFor("stack_duration")
	if IsServer() then
        -- add stack modifier
		local this = tempTable:AddATValue( self )
		self.parent:AddNewModifier(
			self.caster, -- player source
			self.ability, -- ability source
			"bloodmage_0_modifier_sacrifice_stack", -- modifier name
			{
				duration = self.ability:CalcStatus(stack_duration, self.caster, self.parent),
				modifier = this,
			} -- kv
		)
		self:IncrementStackCount()
	end
end

function bloodmage_0_modifier_sacrifice:IncrementBP()
	local current_bp = self.parent:GetMana()
	local max_bp = self.parent:GetMaxMana()
    local current_max_hp = self.parent:GetMaxHealth()
	local total_percent = self.hp_percent + (self.stack_percent * self:GetStackCount())
	local converted_amount = math.floor(current_max_hp * total_percent)
	if converted_amount < 1 then return end
	if converted_amount + current_bp > max_bp then converted_amount = max_bp - current_bp end

	self.converted_health = self.converted_health + converted_amount
	self.parent:SetMana(current_bp + converted_amount)

	if self.parent:GetMana() == max_bp then self.ability:SetActivated(false) end

	-- REFRESH HP MAX ON PANORAMA
	local void = self.parent:FindAbilityByName("_void")
	if void then void:SetLevel(1) end
end

function bloodmage_0_modifier_sacrifice:DecrementBP(amount)
	local current_bp = self.parent:GetMana()
	local max_bp = self.parent:GetMaxMana()
    local current_max_hp = self.parent:GetMaxHealth()

	amount = math.floor(amount)
	if amount > current_bp or amount < 1 then return end

	self.converted_health = self.converted_health - amount
	self.parent:SetMana(current_bp - amount)

	self.ability:SetActivated(true)

	-- REFRESH HP MAX ON PANORAMA
	local void = self.parent:FindAbilityByName("_void")
	if void then void:SetLevel(1) end
end