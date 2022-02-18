strider_1_modifier_debuff = class ({})

function strider_1_modifier_debuff:IsHidden()
    return false
end

function strider_1_modifier_debuff:IsPurgable()
    return false
end

-----------------------------------------------------------

function strider_1_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.distance = self.ability:GetSpecialValueFor("distance")
	self.knock = false
	self.time = 0

	self:CreateSpirit()
	self:PlayEfxStart()
end

function strider_1_modifier_debuff:OnRefresh(kv)
end

function strider_1_modifier_debuff:OnRemoved(kv)
	PlayerResource:SetOverrideSelectionEntity(self.parent:GetPlayerID(), nil)
	PlayerResource:SetCameraTarget(self.parent:GetPlayerID(), nil)
	CenterCameraOnUnit(self.parent:GetPlayerID(), self.parent)
	self.time = self:GetElapsedTime() * 0.5
end

function  strider_1_modifier_debuff:OnDestroy()
	if self.parent:IsAlive() then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_disarm", {
			duration = self.ability:CalcStatus(self.time, self.caster, self.parent)
		})
	end
end

------------------------------------------------------------

function strider_1_modifier_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_TAUNTED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_FROZEN] = true
	}

	return state
end

-- function strider_1_modifier_debuff:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
-- 	}

-- 	return funcs
-- end

-- function strider_1_modifier_debuff:GetOverrideAnimation()
-- 	return ACT_SLEEP
-- end

--------------------------------------------------------------------------------

function strider_1_modifier_debuff:CreateSpirit()
	local illu = CreateIllusions(
        self.parent, self.parent,
        {
            outgoing_damage = -100,
            incoming_damage = 0,
            bounty_base = 0,
            bounty_growth = 0,
            duration = 60,
        },
        1, 64, false, false
    )
    self.illu = illu[1]

    PlayerResource:SetOverrideSelectionEntity(self.parent:GetPlayerID(), self.illu)
	PlayerResource:SetCameraTarget(self.parent:GetPlayerID(), self.illu)
	self:StartIntervalThink(FrameTime())
end

function strider_1_modifier_debuff:OnIntervalThink()
	if self == nil then return end
	if self.illu == nil then return end
	if IsValidEntity(self.illu) == false then self:Destroy() return end
	if self.illu:IsAlive() == false then self:Destroy() return end
	
	if self.illu:HasModifier("strider_1_modifier_spirit") == false then
		self.illu:AddNewModifier(self.caster, self.ability, "strider_1_modifier_spirit", {duration = self:GetRemainingTime()})
	end

	if self.illu:HasModifier("strider_1_modifier_knockback") == false then
		if self.knock == false then
			local forward = self.caster:GetForwardVector():Normalized()
			local point = self.parent:GetOrigin() + (forward * self.distance)

			self.illu:AddNewModifier(self.caster, self.ability, "strider_1_modifier_knockback",{
				duration = self.distance * 0.001,
				x = point.x,
				y = point.y,
			})
		end
	else
		self.knock = true
	end
end

--------------------------------------------------------------------------------

function strider_1_modifier_debuff:GetStatusEffectName()
	return "particles/strider/strider__status_effect_seal.vpcf"
end

function strider_1_modifier_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function strider_1_modifier_debuff:PlayEfxStart()
	local particle_cast = "particles/strider/strider_mark__wraith.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, true)
end