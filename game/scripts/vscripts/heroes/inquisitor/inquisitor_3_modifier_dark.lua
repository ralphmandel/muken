inquisitor_3_modifier_dark = class({})

--------------------------------------------------------------------------------

function inquisitor_3_modifier_dark:IsHidden()
	return false
end

function inquisitor_3_modifier_dark:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function inquisitor_3_modifier_dark:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.reduction = self.ability:GetSpecialValueFor("reduction")
	self.start = true

	PlayerResource:SetCameraTarget(self.parent:GetPlayerID(), self.parent)

	if self.ability.target then
		if IsValidEntity(self.ability.target) then
			if self.ability.target:IsMagicImmune() == false then
				self.ability.target:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
					duration = 0.5,
					percent = 100,
				})
			end
		end
	end

	self:PlayEfxStart()
	self:StartIntervalThink(0.2)
end

function inquisitor_3_modifier_dark:OnRefresh( kv )
	self.start = true

	if self.ability.target then
		if IsValidEntity(self.ability.target) then
			if self.ability.target:IsMagicImmune() == false then
				self.ability.target:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
					duration = 0.5,
					percent = 100,
				})
			end
		end
	end

	self:StartIntervalThink(-1)
	self:StartIntervalThink(0.2)
end

function inquisitor_3_modifier_dark:OnRemoved()
	if self.particle ~= nil then ParticleManager:DestroyParticle(self.particle, false) end
	self.parent:RemoveModifierByName("inquisitor_3_modifier_speed")
	self.ability:RemoveBonus("_1_AGI", self.parent)
	PlayerResource:SetCameraTarget(self.parent:GetPlayerID(), nil)

	if self.ability.target then
		if IsValidEntity(self.ability.target) then
			local mod = self.ability.target:FindAllModifiersByName("_modifier_movespeed_debuff")
			for _,modifier in pairs(mod) do
				if modifier:GetAbility() == self.ability then modifier:Destroy() end
			end
		end
	end
end

--------------------------------------------------------------------------------

function inquisitor_3_modifier_dark:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_CANNOT_MISS] = self.start
	}

	return state
end

function inquisitor_3_modifier_dark:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACKED
	}
	
	return funcs
end

function inquisitor_3_modifier_dark:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end
	self:StartIntervalThink(-1)

	if self.ability.target == nil then self.ability:ReloadTarget() return end
	if IsValidEntity(self.ability.target) == false then self.ability:ReloadTarget() return end
	if self.ability.target ~= keys.target then self.ability:ReloadTarget() return end
	if self.start == true then self.ability:ReloadTarget() return end
	if RandomInt(1, 100) <= 20 then self.ability:ReloadTarget() return end
	self:StartIntervalThink(0.2)
end

function inquisitor_3_modifier_dark:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
	self:StartIntervalThink(-1)

	if keys.target:GetTeam() == self.parent:GetTeam() then
		self:Destroy()
		self.ability:ReloadTarget()
		return
	end

	if self.ability.target == nil then self.ability:ReloadTarget() return end
	if IsValidEntity(self.ability.target) == false then self.ability:ReloadTarget() return end
	if self.ability.target ~= keys.target then self.ability:ReloadTarget() return end
	self.parent:MoveToTargetToAttack(keys.target)

	if self.start == true then
		self:PlayEfxSonic()
	end

	self.start = false

	if RandomInt(1, 100) <= 20 then self.ability:ReloadTarget() return end
	self:StartIntervalThink(0.2)
end

function inquisitor_3_modifier_dark:GetModifierDamageOutgoing_Percentage(keys)
	if keys.attacker ~= self.parent then return 0 end
	return -self.reduction
end

function inquisitor_3_modifier_dark:GetModifierAttackRangeBonus()
    return 75
end

function inquisitor_3_modifier_dark:OnIntervalThink()
	if self.parent:IsAttacking() then self:StartIntervalThink(0.1) return end
	if self.parent:IsStunned() then self:StartIntervalThink(0.1) return end
	if self.parent:IsOutOfGame() then self:StartIntervalThink(0.1) return end
	if self.parent:IsNightmared() then self:StartIntervalThink(0.1) return end

	if self.parent:IsDisarmed() then
		self:Destroy()
		self.ability:ReloadTarget()
		return
	end

	self:StartIntervalThink(-1)
	self.ability:ReloadTarget()
end

-----------------------------------------------------------------------------

function inquisitor_3_modifier_dark:PlayEfxStart()
	if self.particle ~= nil then ParticleManager:DestroyParticle(self.particle, false) end
	self.particle = ParticleManager:CreateParticle("particles/inquisitor/inquisitor_dark_sonic.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetOrigin())
end

function inquisitor_3_modifier_dark:PlayEfxSonic()
	local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn_v2.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Hero_Centaur.DoubleEdge") end
end

function inquisitor_3_modifier_dark:GetStatusEffectName()
	return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
	--return "particles/status_fx/status_effect_phantom_assassin_fall20_active_blur.vpcf"
end

function inquisitor_3_modifier_dark:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end