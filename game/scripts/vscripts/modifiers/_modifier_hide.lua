_modifier_hide = class({})

function _modifier_hide:IsPurgable()
	return false
end

function _modifier_hide:IsHidden()
	return false
end

function _modifier_hide:GetTexture()
	return "shadow_potion"
end

function _modifier_hide:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-------------------------------------------------------------------

function _modifier_hide:OnCreated(kv)
	
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.invi = false

	self:StartIntervalThink(1)
end

function _modifier_hide:OnRemoved()
end

-------------------------------------------------------------------

function _modifier_hide:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = self.invi,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
	}

	return state
end

function _modifier_hide:DeclareFunctions()

    local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
    }

    return funcs
end

function _modifier_hide:GetModifierInvisibilityLevel()
	return 2
end



function _modifier_hide:OnIntervalThink()
	if self.invi == false then self.invi = true return end

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		500,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		self:Destroy()
		return
	end

	self:StartIntervalThink(0.5)
end

--------------------------------------------------------------------------------

function _modifier_hide:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf"
end

function _modifier_hide:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end