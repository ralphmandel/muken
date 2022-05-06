succubus_2_modifier_heart = class({})

--------------------------------------------------------------------------------

function succubus_2_modifier_heart:IsHidden()
	return false
end

function succubus_2_modifier_heart:IsPurgable()
	return true
end

function succubus_2_modifier_heart:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function succubus_2_modifier_heart:OnCreated( kv )
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.team = self.parent:GetTeam()
	self.parent:SetTeam(self.caster:GetTeam())
	self.owner = self.parent:GetOwner()
	self.parent:SetOwner(self.caster:GetOwner())

	local enemies = FindUnitsInRadius(
            self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, -1,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            0, 1, false
        )

        for _,enemy in pairs(enemies) do
			self.parent:SetForceAttackTarget(enemy)
			self.parent:MoveToTargetToAttack(enemy)
			break
		end
end

function succubus_2_modifier_heart:OnRefresh( kv )
end

function succubus_2_modifier_heart:OnRemoved()
	self.parent:SetForceAttackTarget(nil)
	self.parent:SetTeam(self.team)
	self.parent:SetOwner(self.owner)
end

--------------------------------------------------------------------------------

function succubus_2_modifier_heart:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_TAUNTED] = true,
		
	}

	return state
end

--------------------------------------------------------------------------------

function succubus_2_modifier_heart:GetEffectName()
	return "particles/succubus/succubus_2_heart_debuff_hearts.vpcf"
end

function succubus_2_modifier_heart:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function succubus_2_modifier_heart:GetStatusEffectName()
	return "particles/succubus/succubus_2_heart_debuff_statuseffect.vpcf"
end

function succubus_2_modifier_heart:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

-- function bloodstained_1_modifier_rage:PlayEfxStart()
-- 	if IsServer() then
-- 		self.parent:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
-- 		self.parent:EmitSound("Bloodstained.fury")
-- 		self.parent:EmitSound("Bloodstained.rage")
-- 	end
-- end