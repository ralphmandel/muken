striker_3_modifier_debuff = class({})

function striker_3_modifier_debuff:IsHidden()
	return false
end

function striker_3_modifier_debuff:IsPurgable()
	return true
end

function striker_3_modifier_debuff:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_3_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.ticks = self.ability:GetSpecialValueFor("max_ticks")
	self.amount = self.ability:GetSpecialValueFor("init_amount")
	self.amount_reduction = self.ability:GetSpecialValueFor("amount_reduction")
	self.tick_interval = self.ability:GetSpecialValueFor("tick_interval")

	if IsServer() then
		self:ApplyTick()
		self:PlayEfxStart()
	end
end

function striker_3_modifier_debuff:OnRefresh(kv)
	if IsServer() then
		self:ModifyStack(0, true)
		self:PlayEfxStart()
	end
end

function striker_3_modifier_debuff:OnRemoved()
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end
end

-- API FUNCTIONS -----------------------------------------------------------

-- function striker_3_modifier_debuff:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_STUNNED] = true
-- 	}

-- 	return state
-- end

function striker_3_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function striker_3_modifier_debuff:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end
	if keys.damage > 0 then self:ModifyStack(-1, false) end
end

function striker_3_modifier_debuff:OnIntervalThink()
	if IsServer() then self:ApplyTick() end
end

function striker_3_modifier_debuff:OnStackCountChanged(old)
	if self:GetStackCount() < 1 then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function striker_3_modifier_debuff:ApplyTick()
	local damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = self.amount,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	}
	ApplyDamage(damageTable)

	self:ModifyStack(-1, true)

	if self.particle then ParticleManager:SetParticleControl(self.particle, 1, self.parent:GetAbsOrigin()) end
	if IsServer() then self:StartIntervalThink(self.tick_interval) end
end

function striker_3_modifier_debuff:ModifyStack(value, bModifyAmount)
	if value == 0 and bModifyAmount then
		self.ticks = self.ability:GetSpecialValueFor("max_ticks")
		self.amount = self.amount + self.ability:GetSpecialValueFor("init_amount")
	end

	self.ticks = self.ticks + value
	if bModifyAmount then self.amount = self.amount * (100 - self.amount_reduction) * 0.01 end

	if IsServer() then self:SetStackCount(self.ticks) end
end

-- EFFECTS -----------------------------------------------------------

function striker_3_modifier_debuff:PlayEfxStart()
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end

	local string = "particles/econ/events/fall_2021/blink_dagger_fall_2021_end.vpcf"
    local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())

	local string_2 = "particles/econ/events/fall_2021/radiance_fall_2021.vpcf"
	self.particle = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, self.parent:GetAbsOrigin())
	self:AddParticle(self.particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Abaddon.DeathCoil.Target") end
end