_modifier_invisible = class({})

-- Classifications
function _modifier_invisible:IsHidden()
	return false
end

function _modifier_invisible:IsPurgable()
	return true
end

function _modifier_invisible:GetTexture()
	return "_modifier_invisible"
end

function _modifier_invisible:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_invisible:OnCreated( kv )
	local delay = kv.delay or 0
	local spell_break = kv.spell_break or 0
	local attack_break = kv.attack_break or 1

	self.delay = false
  self.hidden = false
	self.spell_break = (spell_break == 1)
	self.attack_break = (attack_break == 1)

	if IsServer() then
		if delay == 0 then
			self.hidden = true
		else
			self:StartIntervalThink(delay)
		end

		local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
		if cosmetics then
			for i = 1, #cosmetics.cosmetic, 1 do
				local invi_cosmetic = cosmetics.cosmetic[i]:AddNewModifier(
					self:GetParent(), self:GetAbility(), "_modifier_invisible_cosmetics", {}
				)
			end
		end
	end
end

function _modifier_invisible:OnRefresh( kv )

end

function _modifier_invisible:OnDestroy( kv )
	local cosmetics = self:GetParent():FindAbilityByName("cosmetics")
	if cosmetics then
		for i = 1, #cosmetics.cosmetic, 1 do
      RemoveAllModifiersByNameAndAbility(cosmetics.cosmetic[i], "_modifier_invisible_cosmetics", self:GetAbility())
		end
	end
end

-------------------------------------------------------------

function _modifier_invisible:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = self.hidden,
	}

	return state
end

function _modifier_invisible:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ABILITY_START
	}

	return funcs
end

function _modifier_invisible:GetModifierInvisibilityLevel()
	return 1
end

function _modifier_invisible:GetModifierProcAttack_Feedback(keys)
    if IsServer() then
        if keys.attacker == self:GetParent() and self.attack_break then
			self:Destroy()
        end
    end
end

function _modifier_invisible:OnAbilityStart(keys)
	if keys.unit == self:GetParent() and self.spell_break then self:Destroy() end
end

function _modifier_invisible:OnIntervalThink()
	if self.delay == false then
		self.delay = true
		self:PlayEffects()
		self:StartIntervalThink(0.2)
	else
		self.hidden = true
		self:StartIntervalThink(-1)
	end
end

--------------------------------------------------------------------------------

-- function _modifier_invisible:GetEffectName()
-- 	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf"
-- end

-- function _modifier_invisible:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

function _modifier_invisible:PlayEffects()
	local particle_cast = "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_missile_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end