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

	if IsServer() then
		self:CheckRootState()
	end
end

function druid_2_modifier_aura_effect:OnRefresh(kv)
end

function druid_2_modifier_aura_effect:OnRemoved(kv)
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

function druid_2_modifier_aura_effect:OnIntervalThink()
	self:CheckRootState()
end

-----------------------------------------------------------