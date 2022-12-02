bald_u_modifier_vitality = class({})

function bald_u_modifier_vitality:IsHidden() return false end
function bald_u_modifier_vitality:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_u_modifier_vitality:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local con = self.ability:GetSpecialValueFor("con")

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bald_u_modifier_vitality_status_efx", true) end

	if IsServer() then self:SetStackCount(con) end
end

function bald_u_modifier_vitality:OnRefresh(kv)
	local con = self.ability:GetSpecialValueFor("con")

	if IsServer() then self:SetStackCount(con) end
end

function bald_u_modifier_vitality:OnRemoved()
	self.ability:RemoveBonus("_1_CON", self.parent)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bald_u_modifier_vitality_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_u_modifier_vitality:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bald_u_modifier_vitality:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
end

function bald_u_modifier_vitality:OnIntervalThink()
	if IsServer() then
		self.parent:EmitSound("Hero_OgreMagi.Bloodlust.Target.FP")
		self:DecrementStackCount()
	end
end

function bald_u_modifier_vitality:OnStackCountChanged(old)
	self.ability:RemoveBonus("_1_CON", self.parent)

	if self:GetStackCount() > 0 then
		self.ability:AddBonus("_1_CON", self.parent, self:GetStackCount(), 0, nil)
	else
		self:Destroy()
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_u_modifier_vitality:GetStatusEffectName()
    return "particles/bald/bald_vitality/bald_vitality_status_efx.vpcf"
end

function bald_u_modifier_vitality:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function bald_u_modifier_vitality:GetEffectName()
	return "particles/bald/bald_vitality/bald_vitality_buff.vpcf"
end

function bald_u_modifier_vitality:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end