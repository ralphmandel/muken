item_legend_serluc_mod_berserk = class({})

function item_legend_serluc_mod_berserk:IsHidden()
    return true
end

function item_legend_serluc_mod_berserk:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_legend_serluc_mod_berserk:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	--self.ability:EndCooldown()
	--self.ability:SetActivated(false)

	local agi = self.ability:GetSpecialValueFor("agi")
	local ms = self.ability:GetSpecialValueFor("ms")
	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = ms})

	self:StartIntervalThink(FrameTime())
	self:PlayEfxBuff()
end

function item_legend_serluc_mod_berserk:OnRefresh( kv )
end

function item_legend_serluc_mod_berserk:OnRemoved( kv )
	self.parent:SetForceAttackTarget(nil)
	self.ability:RemoveBonus("_1_AGI", self.parent)

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	--self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	--self.ability:SetActivated(true)
end
---------------------------------------------------------------------------------------------------

function item_legend_serluc_mod_berserk:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true
	}

	return state
end

function item_legend_serluc_mod_berserk:OnIntervalThink()
	if self.target == nil then self:FindNewTarget(true) return end
	if IsValidEntity(self.target) == false then self:FindNewTarget(true) return end
	if self.target:IsBaseNPC() == false then self:FindNewTarget(true) return end
	if self.target:IsAlive() == false or self.target:IsOutOfGame()
		or self.target:IsInvisible() then self:FindNewTarget(true) return end
	if self.target:IsHero() == false then self:FindNewTarget(false) return end
	if CalcDistanceBetweenEntityOBB(self.parent, self.target) > 500 then self:FindNewTarget(true) end
end

function item_legend_serluc_mod_berserk:FindNewTarget(bUnits)
	local heroes = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 500,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false
	)

	for _,hero in pairs(heroes) do
		self.target = hero
		self.parent:MoveToTargetToAttack(self.target)
		self.parent:SetForceAttackTarget(self.target)
		return
	end

	if bUnits == true then
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, FIND_UNITS_EVERYWHERE,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
		)

		for _,enemy in pairs(enemies) do
			self.target = enemy
			self.parent:MoveToTargetToAttack(self.target)
			self.parent:SetForceAttackTarget(self.target)
			return
		end
	end
end

-- function item_legend_serluc_mod_berserk:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
-- 	}

-- 	return funcs
-- end

-- function item_legend_serluc_mod_berserk:GetModifierTotalDamageOutgoing_Percentage(keys)
-- end

--------------------------------------------------------------------------------------------------

function item_legend_serluc_mod_berserk:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf"
end

function item_legend_serluc_mod_berserk:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

function item_legend_serluc_mod_berserk:GetStatusEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf"
	--return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function item_legend_serluc_mod_berserk:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function item_legend_serluc_mod_berserk:PlayEfxBuff()
	local particle_cast = "particles/items/item_fx_serluc_berserk.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)

	self:AddParticle(effect_cast, false, false, -1, false, false)
end