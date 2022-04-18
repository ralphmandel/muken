druid_2_modifier_aura_effect = class({})

function druid_2_modifier_aura_effect:IsHidden()
	return false
end

function druid_2_modifier_aura_effect:IsPurgable()
	return false
end

function druid_2_modifier_aura_effect:IsDebuff()
	return true
end

-----------------------------------------------------------

function druid_2_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.drain = false
	self.break_passive = false

	-- UP 2.41
	if self.ability:GetRank(41) then
		self.drain = true
		self:DrainHealth()
	end

	if IsServer() then
		self:CheckRootState()
	end
end

function druid_2_modifier_aura_effect:OnRefresh(kv)
end

function druid_2_modifier_aura_effect:OnRemoved(kv)
	self.drain = false
end

-----------------------------------------------------------

function druid_2_modifier_aura_effect:CheckState()
	local state = {}
	
	if self.break_passive == true then
		state = {
			[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		}
	end

	return state
end

function druid_2_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function druid_2_modifier_aura_effect:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end

	-- UP 2.22
	if self.ability:GetRank(22)
	and keys.unit:IsRooted() then
		print("nani")
		self.break_passive = true
	else
		print("nani off")
		self.break_passive = false
	end
end

function druid_2_modifier_aura_effect:CheckRootState()
	self:StartIntervalThink(-1)

	local root_duration = self.ability:GetSpecialValueFor("root_duration")
	local mods_root = self.parent:FindAllModifiersByName("_modifier_root")

	-- UP 2.22
	if self.ability:GetRank(22) then
		root_duration = root_duration + 1
	end

	local new = true
	for _,root in pairs(mods_root) do
		if root:GetAbility() == self.ability
		and root.effect == 5 then
			new = false
			break
		end
	end

	if new == true then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {
			duration = self.ability:CalcStatus(root_duration, self.caster, self.parent),
			effect = 5
		})		
	end
end

function druid_2_modifier_aura_effect:DrainHealth()
	if self.parent == nil then return end
	if IsValidEntity(self.parent) == false then return end
	if self.parent:IsAlive() == false then return end
	if self.drain == false then return end

	Timers:CreateTimer((0.1), function()
		local iDesiredHealthValue = self.parent:GetHealth() - (self.parent:GetMaxHealth() * 0.004)
		self.parent:ModifyHealth(iDesiredHealthValue, self.ability, true, 0)
		self:DrainHealth()
	end)
end

function druid_2_modifier_aura_effect:OnIntervalThink()
	self:CheckRootState()
end

-----------------------------------------------------------