crusader_1_modifier_delay = class ({})

function crusader_1_modifier_delay:IsHidden()
    return true
end

function crusader_1_modifier_delay:IsPurgable()
    return false
end

-----------------------------------------------------------

function crusader_1_modifier_delay:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.max = self.ability:GetSpecialValueFor("max")
	local delay = self.ability:GetSpecialValueFor("delay")

	-- UP 1.5
	if self.ability:GetRank(5) then
		self.max = self.max - 1
	end

	self:StartIntervalThink(delay)
end

function crusader_1_modifier_delay:OnRefresh(kv)
	local add = self.ability:GetSpecialValueFor("max")

	-- UP 1.5
	if self.ability:GetRank(5) then
		add = add - 1
	end

	self.max = self.max + add
end

function crusader_1_modifier_delay:OnRemoved(kv)
end

------------------------------------------------------------

function crusader_1_modifier_delay:OnIntervalThink()
	local duration = self.ability:GetSpecialValueFor("duration")
	local point = self:CalculatePoint(self.parent:GetOrigin())

	local summoned_unit = CreateUnitByName(
		"crusader", -- name
		point, -- point
		true, -- bFindClearSpace,
		self.caster, -- hNPCOwner,
		self.caster:GetOwner(), -- hUnitOwner,
		self.caster:GetTeamNumber() -- iTeamNumber
	)

	-- dominate units
	--summoned_unit:SetControllableByPlayer(self.caster:GetPlayerID(), false) -- (playerID, bSkipAdjustingPosition)
	summoned_unit:SetOwner(self.caster)
	summoned_unit:AddNewModifier(self.caster, self.ability, "crusader_1_modifier_summon", {
		duration = self.ability:CalcStatus(duration, self.caster, nil)
	})

	self.max = self.max - 1
	if self.max < 1 then self:Destroy() end
end

function crusader_1_modifier_delay:CalculatePoint(point)
	local explosion_damage = 50
	local radius_min = 200
	local radius_max = 400

	local random_x
	local random_y

	local quarter = RandomInt(1,4)
	if quarter == 1 then
		random_x = RandomInt(-radius_max, radius_max)
		if random_x > 0 then
			random_y = RandomInt(-radius_max, radius_min)
		else
			random_y = RandomInt(-radius_max, radius_min + 1)
		end
	elseif quarter == 2 then
		random_x = RandomInt(-radius_max, radius_max)
		if random_x > 0 then
			random_y = RandomInt(radius_min + 1, radius_max)
		else
			random_y = RandomInt(radius_min, radius_max)
		end
	elseif quarter == 3 then
		random_y = RandomInt(-radius_max, radius_max)
		if random_y > 0 then
			random_x = RandomInt(-radius_max, radius_min)
		else
			random_x = RandomInt(-radius_max, radius_min + 1)
		end
	elseif quarter == 4 then
		random_y = RandomInt(-radius_max, radius_max)
		if random_y > 0 then
			random_x = RandomInt(radius_min + 1, radius_max)
		else
			random_x = RandomInt(radius_min, radius_max)
		end
	end

	local x = self:CalculateAngle(random_x, random_y)
	local y = self:CalculateAngle(random_y, random_x)

	point.x = point.x + x
	point.y = point.y + y

	return point
end

function crusader_1_modifier_delay:CalculateAngle(a, b)
    if a < 0 then
        if b > 0 then b = -b end
    else
		if b < 0 then b = -b end
    end
    return a - math.floor(b/4)
end