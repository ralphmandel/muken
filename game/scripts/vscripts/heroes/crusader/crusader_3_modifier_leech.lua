crusader_3_modifier_leech = class({})

function crusader_3_modifier_leech:IsHidden()
    return false 
end

function crusader_3_modifier_leech:IsPurgable()
	if self:GetCaster() == self:GetParent() then return false end
    return true 
end

---------------------------------------------------------------------------------------------------

function crusader_3_modifier_leech:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	
	if self.caster ~= self.parent then
		table.insert(self.ability.tHeroes, self.parent)
		local rand = RandomInt(1, 4)
		if rand == 1 then self.str = 1 else self.str = 0 end
		if rand == 2 then self.agi = 1 else self.agi = 0 end
		if rand == 3 then self.int = 1 else self.int = 0 end
		if rand == 4 then self.con = 1 else self.con = 0 end
	end

	if IsServer() then
		self:SetStackCount(1)
	end
end

function crusader_3_modifier_leech:OnRefresh( kv )
	if self.caster ~= self.parent then
		local rand = RandomInt(1, 4)
		if rand == 1 then self.str = self.str + 1 end
		if rand == 2 then self.agi = self.agi + 1 end
		if rand == 3 then self.int = self.int + 1 end
		if rand == 4 then self.con = self.con + 1 end
	end

	if IsServer() then
		self:IncrementStackCount()
	end
end

function crusader_3_modifier_leech:OnRemoved( kv )
	if self.caster == self.parent then
		for i = #self.ability.tHeroes, 1, -1 do
			local hero = self.ability.tHeroes[i]
			local leech = hero:FindModifierByName("crusader_3_modifier_leech")
			if leech ~= nil then leech:SetStackCount(0) end
			table.remove(self.ability.tHeroes,i)
		end
	else
		local leech = self.caster:FindModifierByName("crusader_3_modifier_leech")
		if leech ~= nil then leech:SetStackCount(leech:GetStackCount() - self:GetStackCount()) end
		for i = #self.ability.tHeroes, 1, -1 do
			local hero = self.ability.tHeroes[i]
			if hero == self.parent then
				table.remove(self.ability.tHeroes,i)
			end
		end
	end

	self:SetStackCount(0)
	self.ability:RemoveBonus("_1_STR", self.parent)
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_1_INT", self.parent)
	self.ability:RemoveBonus("_1_CON", self.parent)
end

---------------------------------------------------------------------------------------------------

function crusader_3_modifier_leech:OnStackCountChanged(old)
	self.ability:RemoveBonus("_1_STR", self.parent)
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_1_INT", self.parent)
	self.ability:RemoveBonus("_1_CON", self.parent)

	local stack = self:GetStackCount()
	if stack == 0 then self:Destroy() return end

	if self.caster == self.parent then
		self.ability:AddBonus("_1_CON", self.parent, stack, 0, nil)
	else
		self.ability:AddBonus("_1_STR", self.parent, -self.str, 0, nil)
		self.ability:AddBonus("_1_AGI", self.parent, -self.agi, 0, nil)
		self.ability:AddBonus("_1_INT", self.parent, -self.int, 0, nil)
		self.ability:AddBonus("_1_CON", self.parent, -self.con, 0, nil)
	end
end

--------------------------------------------------------------------------------------------------

function crusader_3_modifier_leech:GetEffectName()
    if self:GetParent() ~= self:GetCaster() then
		return "particles/econ/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_dagger_debuff_arcana_combined.vpcf"
	end
end

function crusader_3_modifier_leech:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end