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

-- function druid_2_modifier_aura_effect:DeclareFunctions()
--     local funcs = {
--     }
--     return funcs
-- end

function druid_2_modifier_aura_effect:CheckRootState()
	self:StartIntervalThink(-1)

	local root_duration = self.ability:GetSpecialValueFor("root_duration")

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {
		duration = self.ability:CalcStatus(root_duration, self.caster, self.parent),
		effect = 5
	})

	-- local damageTable = {
	--     victim = target,
	--     attacker = caster,
	--     damage = self.damage,
	--     damage_type = DAMAGE_TYPE_MAGICAL,
	--     ability = self
	-- }
	-- ApplyDamage(damageTable)
end

function druid_2_modifier_aura_effect:DrainHealth()
	if self.parent == nil then return end
	if IsValidEntity(self.parent) == false then return end
	if self.parent:IsAlive() == false then return end
	if self.drain == false then return end

	Timers:CreateTimer((0.1), function()
		local iDesiredHealthValue = self.parent:GetHealth() - (self.parent:GetMaxHealth() * 0.005)
		self.parent:ModifyHealth(iDesiredHealthValue, self.ability, true, 0)
		self:DrainHealth()
	end)
end

function druid_2_modifier_aura_effect:OnIntervalThink()
	self:CheckRootState()
end

-----------------------------------------------------------