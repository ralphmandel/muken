bocuse__modifier_effect = class ({})

function bocuse__modifier_effect:IsHidden()
    return true
end

function bocuse__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function bocuse__modifier_effect:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	Timers:CreateTimer((0.5), function()
		if self.parent then
			if IsValidEntity(self.parent) then
				self.parent:SetModelScale(1.35)
				self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
			end
		end
	end)

	--self:StartIntervalThink(1)
end

function bocuse__modifier_effect:OnRefresh(kv)
end

------------------------------------------------------------

function bocuse__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function bocuse__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self:GetParent() then return end
	if IsServer() then self:GetParent():EmitSound("Hero_Pudge.Attack") end
end

function bocuse__modifier_effect:GetAttackSound(keys)
    return ""
end

-- function bocuse__modifier_effect:OnIntervalThink()
--     print("x", self.parent:GetAbsOrigin().x, "| y", self.parent:GetAbsOrigin().y, "| z", self.parent:GetAbsOrigin().z)
-- end