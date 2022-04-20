druid_3_modifier_passive = class ({})

function druid_3_modifier_passive:IsHidden()
	if self:GetAbility():GetCurrentAbilityCharges() == 0 then return true end
	if self:GetAbility():GetCurrentAbilityCharges() == 1 then return true end
	if self:GetAbility():GetCurrentAbilityCharges() % 3 == 0 then return false end
	return true
end

function druid_3_modifier_passive:IsPurgable()
    return false
end

-----------------------------------------------------------

function druid_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self:SetStackCount(0)
	end
end

function druid_3_modifier_passive:OnRefresh(kv)
	-- UP 3.31
	if self.ability:GetRank(31) then
		Timers:CreateTimer((0.1), function()
			self:CheckCharges()
		end)
	end
end

function druid_3_modifier_passive:OnRemoved(kv)
end

------------------------------------------------------------

function druid_3_modifier_passive:OnIntervalThink(keys)
end

function druid_3_modifier_passive:CheckCharges()
	if self:GetStackCount() > 1 then return end
	if self.parent:HasModifier("druid_3_modifier_charges") then return end

	-- UP 3.31
	if self.ability:GetRank(31) then
		local duration = 0

		if self.ability:IsCooldownReady() then
			if self:GetStackCount() == 0 then
				self:SetStackCount(1)
				return
			end
			duration = self.ability:GetEffectiveCooldown(self.ability:GetLevel())
		else
			duration = self.ability:GetCooldownTimeRemaining()
		end

		self.parent:AddNewModifier(self.caster, self.ability, "druid_3_modifier_charges", {
			duration = duration
		})
	end
end

function druid_3_modifier_passive:OnStackCountChanged(old)
	if self:GetStackCount() > 0 then self.ability:EndCooldown() end
	self:CheckCharges()
end