ancient_5_modifier_buff = class({})

function ancient_5_modifier_buff:IsHidden()
	return false
end

function ancient_5_modifier_buff:IsPurgable()
	return true
end

function ancient_5_modifier_buff:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_5_modifier_buff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.tick = 0.2
	self.decrease = true

	local iDesiredHealthValue = self.parent:GetHealth() + kv.extra_health
	self.parent:ModifyHealth(iDesiredHealthValue, self.ability, false, 0)

	-- UP 5.12
	if self.ability:GetRank(12) then
		self.decrease = false
	end

	if IsServer() then
		self.extra_health = kv.extra_health
		self:SetStackCount(kv.extra_health)
		self:StartIntervalThink(self.tick)
		self:PlayEfxStart()
	end
end

function ancient_5_modifier_buff:OnRefresh(kv)
end

function ancient_5_modifier_buff:OnRemoved()
	if self:GetStackCount() > 0 then
		local iDesiredHealthValue = self.parent:GetHealth() - self:GetStackCount()
		self.parent:ModifyHealth(iDesiredHealthValue, self.ability, true, 0)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_5_modifier_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function ancient_5_modifier_buff:GetModifierExtraHealthBonus()
	if IsServer() then
		return self:GetStackCount()
	end
end

function ancient_5_modifier_buff:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end

	self:SetStackCount(self:GetStackCount() - math.floor(keys.damage))
end

function ancient_5_modifier_buff:OnIntervalThink()
	if IsServer() then
		self:DecrementStackCount()

		if self.decrease then
			local iDesiredHealthValue = self.parent:GetHealth() - 1
			self.parent:ModifyHealth(iDesiredHealthValue, self.ability, true, 0)
		end

		self:StartIntervalThink(self.tick)
	end
end

function ancient_5_modifier_buff:OnStackCountChanged(old)
	if self:GetStackCount() <= 0 then self:Destroy() end

	local void = self:GetCaster():FindAbilityByName("_void")
	if void then void:SetLevel(1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_5_modifier_buff:GetEffectName()
	return "particles/units/heroes/hero_chen/chen_divine_favor_buff.vpcf"
end

function ancient_5_modifier_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function ancient_5_modifier_buff:PlayEfxStart()
	local string = "particles/units/heroes/hero_chen/chen_penitence.vpcf"
	local pfx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(pfx, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)
end