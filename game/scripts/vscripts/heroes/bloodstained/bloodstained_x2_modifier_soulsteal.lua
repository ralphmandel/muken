bloodstained_x2_modifier_soulsteal = class({})

function bloodstained_x2_modifier_soulsteal:IsHidden()
    return true 
end

function bloodstained_x2_modifier_soulsteal:IsPurgable()
    return false 
end

---------------------------------------------------------------------------------------------------

function bloodstained_x2_modifier_soulsteal:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	
	self.range = self.ability:GetSpecialValueFor("range")
	self.blood_duration = self.ability:GetSpecialValueFor("blood_duration")
end

function bloodstained_x2_modifier_soulsteal:OnRefresh( kv )

end

function bloodstained_x2_modifier_soulsteal:OnRemoved( kv )
	
end
---------------------------------------------------------------------------------------------------

function bloodstained_x2_modifier_soulsteal:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bloodstained_x2_modifier_soulsteal:OnTakeDamage(keys)
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	local distance = CalcDistanceBetweenEntityOBB(self.parent, keys.unit)
	if distance > self.range then return end

	if keys.damage > 0 then
		self:CreateBlood(keys.unit, 75, keys.damage)
	end
end

function bloodstained_x2_modifier_soulsteal:CreateBlood(target, area, damage)
	local point = target:GetOrigin()
	local random_x
	local random_y

	local quarter = RandomInt(1,4)
	if quarter == 1 then
		random_x = RandomInt(-area, area)
		random_y = -area
	elseif quarter == 2 then
		random_x = RandomInt(-area, area)
		random_y = area
	elseif quarter == 3 then
		random_x = -area
		random_y = RandomInt(-area, area)
	elseif quarter == 4 then
		random_x = area
		random_y = RandomInt(-area, area)
	end

	local x = self:Calculate( random_x, random_y)
	local y = self:Calculate( random_y, random_x)

    point.x = point.x + x
    point.y = point.y + y

	CreateModifierThinker(self.caster, self.ability, "bloodstained_x2_modifier_blood", {
		duration = self.blood_duration,
		damage = damage
	}, point, self.parent:GetTeamNumber(), false)
end

function bloodstained_x2_modifier_soulsteal:Calculate( a, b)

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