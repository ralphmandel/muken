shadow_3_modifier_walk = class({})

function shadow_3_modifier_walk:IsPurgable()
	return false
end

function shadow_3_modifier_walk:IsHidden()
	return false
end

-------------------------------------------------------------------

function shadow_3_modifier_walk:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if self.parent:IsIllusion() then return end

	self.shadow_duration = self.ability:GetSpecialValueFor("shadow_duration")
	self.distance = self.ability:GetSpecialValueFor("distance")

	self.location = self.parent:GetOrigin()
	self:StartIntervalThink(0.2)
end

function shadow_3_modifier_walk:OnRefresh(kv)
	if self.parent:IsIllusion() then return end

	-- UP 3.1
	if self.ability:GetRank(1) then
		self.distance = self.ability:GetSpecialValueFor("distance") - 100
	end
end

function shadow_3_modifier_walk:OnRemoved()
end

-------------------------------------------------------------------

function shadow_3_modifier_walk:DeclareFunctions()

    local funcs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE
    }
 
    return funcs
end

function shadow_3_modifier_walk:GetModifierAvoidDamage(keys)
	if self.parent:IsIllusion() then return end
	local avoid_chance = self.ability:GetSpecialValueFor("avoid_chance") * 10

	if RandomInt(1, 1000) <= avoid_chance
	and self.parent:PassivesDisabled() == false
	and keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then

		-- UP 3.6
		if self.ability:GetRank(6)
		and keys.attacker:HasModifier("shadow_0_modifier_poison") then
			self:CreateShadow(keys.attacker, true, 5)
		end

		return 1
	end
end

function shadow_3_modifier_walk:CreateShadow(target, special, duration)
	local cursor = target:GetOrigin()
    local illu = CreateIllusions(
		self.parent, self.parent, {
            outgoing_damage = -100,
            incoming_damage = 300,
            bounty_base = 0,
			bounty_growth = 0,
            duration = self.ability:CalcStatus(duration, self.caster, nil),
        }, 1, 64, false, false
    )

    illu = illu[1]
	illu:AddNewModifier(self.caster, self.ability, "shadow_3_modifier_illusion", {ignore_order = 1, aspd = 100})

	if self.parent:HasModifier("shadow_1_modifier_weapon") then
		local weapon = self.parent:FindAbilityByName("shadow_1__weapon")
		if weapon then illu:AddNewModifier(self.caster, weapon, "shadow_1_modifier_weapon", {}) end
	end

	if special == true then
		local area = 200
		local quarter = RandomInt(1, 4)
		local variable = RandomInt(0, area)
		local random_x
		local random_y

		if quarter == 1 then random_x = -area random_y = variable end
		if quarter == 2 then random_x = variable random_y = area end
		if quarter == 3 then random_x = area random_y = -variable end
		if quarter == 4 then random_x = -variable random_y = -area end

		local x = self:Calculate( random_x, random_y)
		local y = self:Calculate( random_y, random_x)

		cursor.x = cursor.x + x
		cursor.y = cursor.y + y
	end

	FindClearSpaceForUnit( illu, cursor, true )
end

function shadow_3_modifier_walk:Calculate( a, b)
    if a < 0 then
        if b > 0 then b = -b end
    else
		if b < 0 then b = -b end
    end

    return a - math.floor(b/4)
end

--------------------------------------------------------------------------------

function shadow_3_modifier_walk:OnIntervalThink()
	if self.parent:PassivesDisabled() then return end

	local distance = (self.parent:GetOrigin() - self.location):Length2D()
	if distance > self.distance then
		self.location = self.parent:GetOrigin()

		-- UP 3.7
		local second_shadow = self.caster:FindAbilityByName("shadow_3__second_shadow")
		if second_shadow then
			if second_shadow:IsTrained() then
				self.shadow_duration = self.ability:GetSpecialValueFor("shadow_duration") + second_shadow:GetSpecialValueFor("time")
			end
		end

		self:CreateShadow(self.parent, false, self.shadow_duration)

		-- UP 3.5
		if self.ability:GetRank(5)
		and RandomInt(1, 100) <= 25 then
			self.parent:AddNewModifier(self.caster, self.ability, "shadow_3_modifier_invisible", {
				duration = self.ability:CalcStatus(7, self.caster, self.parent)
			})
		end
	end
end

function shadow_3_modifier_walk:SetLocation(vecLoc)
	self.location = vecLoc
end