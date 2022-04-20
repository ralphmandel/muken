druid_u_modifier_aura_effect = class({})

function druid_u_modifier_aura_effect:IsHidden()
	return false
end

function druid_u_modifier_aura_effect:IsPurgable()
	return false
end

-----------------------------------------------------------

function druid_u_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if self.caster == self.parent then return end

	local seed_speed = self.ability:GetSpecialValueFor("seed_speed")
	self.hp_lost = self.ability:GetSpecialValueFor("hp_lost")
	self.seed_max = self.ability:GetSpecialValueFor("seed_max")

	-- UP 4.32
	if self.ability:GetRank(32) then
		self.hp_lost = self.hp_lost + 50
		self.seed_max = self.seed_max + 5
	end

	self.info = {
		--Target = target,
		Source = self.parent,
		Ability = self.ability,	
		EffectName = "particles/druid/druid_ult_projectile.vpcf",
		iMoveSpeed = seed_speed,
		bReplaceExisting = false,
		bProvidesVision = true,
		iVisionRadius = 100,
		iVisionTeamNumber = self.caster:GetTeamNumber()
	}

	if IsServer() then
		self:SetStackCount(self.hp_lost)
	end
end

function druid_u_modifier_aura_effect:OnRefresh(kv)
end

function druid_u_modifier_aura_effect:OnRemoved(kv)
end

-----------------------------------------------------------

function druid_u_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end

function druid_u_modifier_aura_effect:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end

	self:SetStackCount(self:GetStackCount() - keys.damage)
end

function druid_u_modifier_aura_effect:GetModifierConstantHealthRegen()
	if self:GetCaster() == self:GetParent() then
		return (100 - self:GetCaster():GetHealthPercent()) * 0.01 * self:GetAbility().regeneration
	end
    return (100 - self:GetCaster():GetHealthPercent()) * 0.005 * self:GetAbility().regeneration
end

function druid_u_modifier_aura_effect:CreateSeed()
	local rand = RandomInt(1, self.seed_max)
	local count = 1
	local allies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, -1,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,ally in pairs(allies) do
		if count == 1 then
			self.info.Target = self.caster
		else
			if ally:HasModifier("druid_u_modifier_aura_effect") 
			and self.caster ~= ally
			and self.parent ~= ally then
				self.info.Target = ally
			end
		end

		if self.info.Target ~= nil then
			self.info.ExtraData = {damage = 0, source = self.info.Target:entindex()}
			ProjectileManager:CreateTrackingProjectile(self.info)
			count = count + 1
		end

		self.info.Target = nil
		if count > rand then break end
	end

	if IsServer() then self.parent:EmitSound("Item.Brooch.Target.Melee") end
end

function druid_u_modifier_aura_effect:OnStackCountChanged(iStackCount)
	if self.caster == self.parent then return end
	if self:GetStackCount() < 1 then
		self:SetStackCount(self.hp_lost)
		self:CreateSeed()
	end
end

-----------------------------------------------------------

function druid_u_modifier_aura_effect:GetEffectName()
	return "particles/druid/druid_seed_buff.vpcf"
end

function druid_u_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end