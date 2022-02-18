inquisitor_u_modifier_autocast = class({})

--------------------------------------------------------------------------------

function inquisitor_u_modifier_autocast:IsHidden()
	return false
end

function inquisitor_u_modifier_autocast:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function inquisitor_u_modifier_autocast:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.chance_value = self.ability:GetSpecialValueFor("chance_value")
	self.manacost_reduction = self.ability:GetSpecialValueFor("manacost_reduction")
	self.cooldown_increased = self.ability:GetSpecialValueFor("cooldown_increased") * 0.01
	self.cast = false

	self.tOldSpells = {}
end

function inquisitor_u_modifier_autocast:OnRefresh( kv )
	-- UP 4.2
	if self.ability:GetRank(2) then
		self.cooldown_increased = (self.ability:GetSpecialValueFor("cooldown_increased") - 25) * 0.01
	end

	-- UP 4.3
	if self.ability:GetRank(3) then
		self.manacost_reduction = self.ability:GetSpecialValueFor("manacost_reduction") + 20
	end
end

function inquisitor_u_modifier_autocast:OnDestroy( kv )
end

--------------------------------------------------------------------------------

function inquisitor_u_modifier_autocast:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	
	return funcs
end

function inquisitor_u_modifier_autocast:OnOrder(keys)
	if keys.order_type ~= 20 or keys.unit ~= self.parent then return end
	if self.ability:GetAutoCastState() then
		self:StopEfxCast()
	else
		self:PlayEfxCast()
	end
end

function inquisitor_u_modifier_autocast:OnStateChanged( keys )
    -- if self.parent:PassivesDisabled() and self.ability:GetAutoCastState() then
	-- 	self:StopEfxCast()
    -- end
    -- if self.parent:PassivesDisabled() == false and self.ability:GetAutoCastState() then
	-- 	self:PlayEfxCast()
    -- end
end

function inquisitor_u_modifier_autocast:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.ability:GetAutoCastState() == false then return end
	if self.parent:PassivesDisabled() then return end

	self:DarkCast_Sonicblow(keys.target)
	self:TryCast_Shield()
	self:TryCast_Portal()
	self:TryCast_Sonicblow(keys.target)
	self:TryCast_Hammer()
	self:TryCast_Redemp()
	
	if self.cast == true then
		self:PlayEfxCast()
		self.cast = false

		-- UP 4.1
		if self.ability:GetRank(1) then
			local stats = {
				[1] = "_1_STR",
				[2] = "_1_AGI",
				[3] = "_1_INT",
				[4] = "_1_CON",
				[5] = "_2_DEX",
				[6] = "_2_DEF",
				[7] = "_2_RES",
				[8] = "_2_REC",
				[9] = "_2_LCK",
				[10] = "_2_MND",
			}

			local att = self.parent:FindAbilityByName(stats[RandomInt(1, 10)])
			if att then att:BonusPts(self.caster, self.ability, 1, 0, 60) end
		end
	end
end

--BASIC CAST
	function inquisitor_u_modifier_autocast:TryCast_Shield()
		-- Skill learn check
		local skill = self.caster:FindAbilityByName("inquisitor_1__shield")
		if skill == nil then return end
		if skill:IsTrained() == false then return end
		
		-- Manacost check
		local manacost = skill:GetManaCost(skill:GetLevel()) - (skill:GetManaCost(skill:GetLevel()) * self.manacost_reduction * 0.01)
		if manacost > self.parent:GetMana() then return end

		-- Chance check
		local cooldown = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()))
		local chance = 10000 / (cooldown * self.chance_value)
		if RandomInt(1, 10000) > chance then return end

		-- Autocast Ability
		local allies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.parent:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			skill:GetCastRange(self.parent:GetOrigin(), nil),	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			skill:GetAbilityTargetType(),	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		local shield_apply = false
		for _,ally in pairs(allies) do
			if shield_apply == false
			and ally:IsIllusion() == false then
				self.parent:SetCursorCastTarget(ally)
				skill:EnableAutoCast()
				skill:OnSpellStart()
				shield_apply = true
			end
		end

		if shield_apply == true then
			local new_cd = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()) * self.cooldown_increased)
			skill:EndCooldown()
			skill:StartCooldown(new_cd)
			self.parent:SpendMana(manacost, self.ability)
			self.cast = true
		end
	end

	function inquisitor_u_modifier_autocast:TryCast_Portal()
		-- Skill learn check
		local skill = self.caster:FindAbilityByName("inquisitor_2__portal")
		if skill == nil then return end
		if skill:IsTrained() == false then return end
		
		-- Manacost check
		local manacost = skill:GetManaCost(skill:GetLevel()) - (skill:GetManaCost(skill:GetLevel()) * self.manacost_reduction * 0.01)
		if manacost > self.parent:GetMana() then return end

		-- Chance check
		local cooldown = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()))
		local chance = 10000 / (cooldown * self.chance_value)
		if RandomInt(1, 10000) > chance then return end

		skill:EnableAutoCast()
		skill:OnSpellStart()
		
		local new_cd = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()) * self.cooldown_increased)
		skill:EndCooldown()
		skill:StartCooldown(new_cd)
		self.parent:SpendMana(manacost, self.ability)
		self.cast = true
	end

	function inquisitor_u_modifier_autocast:TryCast_Sonicblow(target)
		if self.parent:HasModifier("inquisitor_3_modifier_dark") then return end

		-- Skill learn check
		local skill = self.caster:FindAbilityByName("inquisitor_3__blow")
		if skill == nil then return end
		if skill:IsTrained() == false then return end
		
		-- Manacost check
		local manacost = skill:GetManaCost(skill:GetLevel()) - (skill:GetManaCost(skill:GetLevel()) * self.manacost_reduction * 0.01)
		if manacost > self.parent:GetMana() then return end

		-- Chance check
		local cooldown = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()))
		local chance = 10000 / (cooldown * self.chance_value)
		if RandomInt(1, 10000) > chance then return end

		-- Autocast Ability
		self.parent:SetCursorCastTarget(target)
		skill:EnableAutoCast()
		skill:OnSpellStart()

		local new_cd = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()) * self.cooldown_increased)
		skill:EndCooldown()
		skill:StartCooldown(new_cd)
		self.parent:SpendMana(manacost, self.ability)
		self.cast = true
	end

	function inquisitor_u_modifier_autocast:Calculate( a, b)
		if a < 0 then
			if b > 0 then
				b = -b
			end
		elseif b < 0 then
			b = -b
		end
		local result = a - math.floor(b/4)

		return result
	end

--DARK CAST
	function inquisitor_u_modifier_autocast:DarkCast_Sonicblow(target)
		if self.parent:HasModifier("inquisitor_3_modifier_dark") then return end
		local skill = self.caster:FindAbilityByName("inquisitor_3__blow")
		if skill == nil then return end
		if skill:IsTrained() == false then return end
		if target:IsHero() == false then return end
		if target:IsIllusion() then return end
		if self.parent:GetMana() < 150 then return end
		if RandomInt(1, 100) > 1 then return end

		-- UP 4.4
		if self.ability:GetRank(4) then
			self.parent:SpendMana(150, self.ability)
			self.parent:SetCursorCastTarget(target)
			skill:OnSpellDark()
		end
	end

--EXTRAS CAST
	function inquisitor_u_modifier_autocast:TryCast_Hammer()
		-- Skill learn check
		local skill = self.caster:FindAbilityByName("inquisitor_x1__hammer")
		if skill == nil then return end
		if skill:IsTrained() == false then return end
		
		-- Manacost check
		local manacost = skill:GetManaCost(skill:GetLevel()) - (skill:GetManaCost(skill:GetLevel()) * self.manacost_reduction * 0.01)
		if manacost > self.parent:GetMana() then return end

		-- Chance check
		local cooldown = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()))
		local chance = 10000 / (cooldown * self.chance_value)
		if RandomInt(1, 10000) > chance then return end

		-- Autocast Ability
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.parent:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			skill:GetCastRange(self.parent:GetOrigin(), nil),	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			skill:GetAbilityTargetType(),	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		local hammer_apply = false
		for _,enemy in pairs(enemies) do
			if hammer_apply == false
			and enemy:HasModifier("inquisitor_x1_modifier_hammer") == false then
				self.parent:SetCursorCastTarget(enemy)
				skill:OnSpellStart()
				hammer_apply = true
			end
		end

		if hammer_apply == true then
			local new_cd = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()) * self.cooldown_increased)
			skill:EndCooldown()
			skill:StartCooldown(new_cd)
			self.parent:SpendMana(manacost, self.ability)
			self.cast = true
		end
	end

	function inquisitor_u_modifier_autocast:TryCast_Redemp()
		-- Skill learn check
		local skill = self.caster:FindAbilityByName("inquisitor_x2__redemption")
		if skill == nil then return end
		if skill:IsTrained() == false then return end
		
		-- Manacost check
		local manacost = skill:GetManaCost(skill:GetLevel()) - (skill:GetManaCost(skill:GetLevel()) * self.manacost_reduction * 0.01)
		if manacost > self.parent:GetMana() then return end

		-- Chance check
		local cooldown = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()))
		local chance = 10000 / (cooldown * self.chance_value)
		if RandomInt(1, 10000) > chance then return end

		local cap = skill:GetSpecialValueFor("health")

		-- Autocast Ability
		local allies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.parent:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			skill:GetCastRange(self.parent:GetOrigin(), nil),	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			skill:GetAbilityTargetType(),	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		local redemp_apply = false
		for _,ally in pairs(allies) do
			if redemp_apply == false
			and ally:IsIllusion() == false
			and ally:GetHealthPercent() <= cap then
				self.parent:SetCursorCastTarget(ally)
				skill:OnSpellStart()
				redemp_apply = true
			end
		end

		if redemp_apply == true then
			local new_cd = skill:GetCooldownTimeRemaining() + (skill:GetEffectiveCooldown(skill:GetLevel()) * self.cooldown_increased)
			skill:EndCooldown()
			skill:StartCooldown(new_cd)
			self.parent:SpendMana(manacost, self.ability)
			self.cast = true
		end
	end

-----------------------------------------------------------------------------

function inquisitor_u_modifier_autocast:PlayEfxCast()
	local particle = "particles/units/heroes/hero_centaur/centaur_return_buff.vpcf"
	if self.particle ~= nil then ParticleManager:DestroyParticle(self.particle, false) end
	self.particle = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.particle, 0, self.parent:GetOrigin() )
end

function inquisitor_u_modifier_autocast:StopEfxCast()
	if self.particle ~= nil then ParticleManager:DestroyParticle(self.particle, false) end
end