dasdingo_4_modifier_tribal = class({})

function dasdingo_4_modifier_tribal:IsHidden()
	return false
end

function dasdingo_4_modifier_tribal:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function dasdingo_4_modifier_tribal:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.atk_range = self.ability:GetSpecialValueFor("atk_range")

	self.parent:StartGesture(ACT_IDLE)
	self:PlayEfxRegen()
end

function dasdingo_4_modifier_tribal:OnRefresh( kv )
end

function dasdingo_4_modifier_tribal:OnRemoved()
	if IsValidEntity(self.parent) then
		if self.parent:IsAlive() then
			self.parent:Kill(self.ability, nil)
		else
			self.ability:RemoveTribal(self.parent)
		end
	end
end

--------------------------------------------------------------------------------

function dasdingo_4_modifier_tribal:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function dasdingo_4_modifier_tribal:GetModifierAttackRangeBonus()
	return self.atk_range
end

function dasdingo_4_modifier_tribal:GetModifierBaseDamageOutgoing_Percentage()
	return -50
end

function dasdingo_4_modifier_tribal:GetModifierProcAttack_Feedback(keys)
	if self.parent:PassivesDisabled() then return end

	-- UP 4.41
	if self.ability:GetRank(41) then
		CreateModifierThinker(
			self.parent, self.ability, "dasdingo_4_modifier_bounce", {},
			keys.target:GetOrigin(), self.parent:GetTeamNumber(), false
		)
	end
end

function dasdingo_4_modifier_tribal:OnAttack(keys)
	if keys.attacker == self.parent then
		if self.ability.sound == nil then
			if IsServer() then self.parent:EmitSound("Hero_WitchDoctor_Ward.Attack") end
		end
	end
end

function dasdingo_4_modifier_tribal:OnAttackLanded(keys)
	if keys.attacker == self.parent then
		if IsServer() then keys.target:EmitSound("Hero_WitchDoctor_Ward.ProjectileImpact") end
	end
end

function dasdingo_4_modifier_tribal:OnTakeDamage(keys)
    if keys.unit ~= self.parent then return end

	-- UP 4.21
	if self.ability:GetRank(21)
	and self.parent:PassivesDisabled() == false then
		if IsServer() then
			local units = FindUnitsInRadius(
				self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 1200,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				0, 0, false
			)
		
			for _,unit in pairs(units) do
				unit:EmitSound("hero_viper.CorrosiveSkin")
				unit:AddNewModifier(self.caster, self.ability, "dasdingo_4_modifier_poison", {
					duration = CalcStatus(4, self.caster, unit)
				})
			end
		end
	end
end

--------------------------------------------------------------------------------

function dasdingo_4_modifier_tribal:GetEffectName()
	return "particles/econ/items/witch_doctor/wd_2021_cache/wd_2021_cache_death_ward.vpcf"
end

function dasdingo_4_modifier_tribal:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function dasdingo_4_modifier_tribal:PlayEfxRegen()
	local string = "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_hero_heal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, false)
end

function dasdingo_4_modifier_tribal:PopupDamage(damage, color, target)
	local digits = 1
	if damage < 10 then digits = 2 end
	if damage > 9 and damage < 100 then digits = 3 end
	if damage > 99 and damage < 1000 then digits = 4 end
	if damage > 999 then digits = 5 end

	local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 4))
	ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
	ParticleManager:SetParticleControl(pidx, 3, color)
end