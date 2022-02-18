crusader_1_modifier_passive = class ({})

function crusader_1_modifier_passive:IsHidden()
    return false
end

function crusader_1_modifier_passive:IsPurgable()
    return false
end

-----------------------------------------------------------

function crusader_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.start = false

	-- UP 1.2
	if self.ability:GetRank(2) and self.start == false then
		self:StartIntervalThink(RandomInt(25, 35))
		self.start = true
	end

	if IsServer() then
		self:SetStackCount(0)
	end
end

function crusader_1_modifier_passive:OnRefresh(kv)
	-- UP 1.2
	if self.ability:GetRank(2) and self.start == false then
		self:StartIntervalThink(RandomInt(25, 35))
		self.start = true
	end

	-- UP 1.5
	if self.ability:GetRank(5) then
		Timers:CreateTimer((0.1), function()
			self:CheckCharges()
		end)
	end
end

function crusader_1_modifier_passive:OnRemoved(kv)
end

------------------------------------------------------------

function crusader_1_modifier_passive:OnIntervalThink(keys)
    if self.parent:IsAlive() == false then return end
	local point = self:CalculatePoint(self.parent:GetOrigin())

	local summoned_unit = CreateUnitByName(
		"crusader", -- name
		point, -- point
		true, -- bFindClearSpace,
		self.caster, -- hNPCOwner,
		self.caster:GetOwner(), -- hUnitOwner,
		self.caster:GetTeamNumber() -- iTeamNumber
	)

	summoned_unit:SetOwner(self.caster)
	summoned_unit:AddNewModifier(self.caster, self.ability, "crusader_1_modifier_summon", {
		duration = self.ability:CalcStatus(20, self.caster, nil)
	})
end

function crusader_1_modifier_passive:CheckCharges()
	if self:GetStackCount() > 1 then return end
	if self.parent:HasModifier("crusader_1_modifier_charges") then return end

	-- UP 1.5
	if self.ability:GetRank(5) then
		local duration = 0

		if self.ability:IsCooldownReady() then
			if self:GetStackCount() == 0 then
				self:SetStackCount(1)
				return
			end
			duration = self.ability:GetEffectiveCooldown(self.ability:GetLevel())
		else
			duration = self.ability:GetCooldownTimeRemaining()
		end

		self.parent:AddNewModifier(self.caster, self.ability, "crusader_1_modifier_charges", {
			duration = duration
		})
	end
end

function crusader_1_modifier_passive:OnStackCountChanged(old)
	if self:GetStackCount() > 0 then self.ability:EndCooldown() end
	self:CheckCharges()
end

function crusader_1_modifier_passive:CalculatePoint(point)
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

function crusader_1_modifier_passive:CalculateAngle(a, b)
    if a < 0 then
        if b > 0 then b = -b end
    else
		if b < 0 then b = -b end
    end
    return a - math.floor(b/4)
end