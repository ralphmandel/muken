genuine_3_modifier_morning = class({})

function genuine_3_modifier_morning:IsHidden() return false end
function genuine_3_modifier_morning:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_3_modifier_morning:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.ability:EndCooldown()
	self.ability:SetActivated(false)

	if IsServer() then
		self:ApplyBuffs()
		self:StartIntervalThink(0.1)
	end
end

function genuine_3_modifier_morning:OnRefresh(kv)
	if IsServer() then
		self:ApplyBuffs()
		self:StartIntervalThink(0.1)
	end
end

function genuine_3_modifier_morning:OnRemoved()
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)
	self.parent:FindModifierByName(self.ability:GetIntrinsicModifierName()):StopEfxBuff()

	RemoveBonus(self.ability, "_1_INT", self.parent)
	RemoveBonus(self.ability, "_1_AGI", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_3_modifier_morning:CheckState()
	local state = {
		[MODIFIER_STATE_FORCED_FLYING_VISION] = GameRules:IsDaytime() == false or GameRules:IsTemporaryNight()
	}

	return state
end

function genuine_3_modifier_morning:OnIntervalThink()
	if GameRules:IsDaytime() == false or GameRules:IsTemporaryNight() then
		local enemies = FindUnitsInRadius(
			self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, -1,
			self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
			self.ability:GetAbilityTargetFlags(), 0, false
		)

		for _,enemy in pairs(enemies) do
			local chance = self.ability:GetSpecialValueFor("chance")
			if self.parent:CanEntityBeSeenByMyTeam(enemy) then
				if enemy:IsHero() and enemy:IsIllusion() == false then
					chance = self.ability:GetSpecialValueFor("hero_chance")
				end
				if RandomFloat(0, 100) < chance then
					self.ability:CreateStarfall(enemy)
				end
			end
		end
	end
	
	if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

function genuine_3_modifier_morning:ApplyBuffs()
	GameRules:BeginTemporaryNight(self:GetDuration() * self.ability:GetSpecialValueFor("force_night_time") * 0.01)

	if self.ability:GetSpecialValueFor("special_purge") == 1 then
		self.parent:Purge(false, true, false, false, false)
	end

	RemoveBonus(self.ability, "_1_INT", self.parent)
	RemoveBonus(self.ability, "_1_AGI", self.parent)
	AddBonus(self.ability, "_1_INT", self.parent, self.ability:GetSpecialValueFor("int"), 0, nil)
	AddBonus(self.ability, "_1_AGI", self.parent, self.ability:GetSpecialValueFor("special_agi"), 0, nil)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)

	local ms = self.ability:GetSpecialValueFor("special_ms")
	if ms > 0 then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = ms})
	end
end

-- EFFECTS -----------------------------------------------------------