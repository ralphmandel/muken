bald_2_modifier_impact = class({})

function bald_2_modifier_impact:IsHidden() return true end
function bald_2_modifier_impact:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_2_modifier_impact:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 2)
		self:StartIntervalThink(0.15)
	end
end

function bald_2_modifier_impact:OnRefresh(kv)
end

function bald_2_modifier_impact:OnRemoved()
	self.ability:SetActivated(true)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_2_modifier_impact:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end

function bald_2_modifier_impact:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING
	}

	return funcs
end

function bald_2_modifier_impact:GetModifierDisableTurning()
	return 1
end

function bald_2_modifier_impact:OnIntervalThink()
	if self.ability.target == nil then return end
	if IsValidEntity(self.ability.target) == false then return end

	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.ability.target:GetOrigin(), nil, self.ability:GetSpecialValueFor("bash_aoe"),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
	)

	for _,enemy in pairs(enemies) do
		if self.ability.target ~= enemy then
			self.ability:ApplyImpact(enemy)
		end
	end			

	if IsServer() then
		self.ability.target:EmitSound("Hero_Bristleback.Attack")
		self.ability:ApplyImpact(self.ability.target)
		self:StartIntervalThink(-1)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------