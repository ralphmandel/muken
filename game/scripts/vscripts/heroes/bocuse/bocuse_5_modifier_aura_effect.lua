bocuse_5_modifier_aura_effect = class ({})

function bocuse_5_modifier_aura_effect:IsHidden()
    return true
end

function bocuse_5_modifier_aura_effect:IsPurgable()
    return false
end

function bocuse_5_modifier_aura_effect:IsDebuff()
    return true
end

-----------------------------------------------------------

function bocuse_5_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.rooted = false

	self.time_to_root = self.ability:GetSpecialValueFor("time_to_root")	

	self.parent:AddNewModifier(self.caster, self.ability, "bocuse_5_modifier_pull", {})

	-- UP 5.11
	if self.ability:GetRank(11) then
		self:DrainHealth(self.parent, self.ability)
	end

	if IsServer() then
    	self:PlayEfxStart()
		self:StartIntervalThink(self.time_to_root)
	end
end

function bocuse_5_modifier_aura_effect:OnRefresh(kv)
end

function bocuse_5_modifier_aura_effect:OnRemoved(kv)
	self.parent:RemoveModifierByNameAndCaster("bocuse_5_modifier_pull", self.caster)
end

------------------------------------------------------------

function bocuse_5_modifier_aura_effect:OnIntervalThink()
	local interval = -1

	if self.rooted then
		interval = self.time_to_root
		self.rooted = false
	else
		local root_duration = self.ability:GetSpecialValueFor("root_duration")

		-- UP 5.21
		if self.ability:GetRank(21) then
			root_duration = root_duration + 1
		end

		interval = self.ability:CalcStatus(root_duration, self.caster, self.parent)
		self.rooted = true

		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {
			duration = interval,
			effect = 3
		})
	end

	if IsServer() then self:StartIntervalThink(interval) end
end

function bocuse_5_modifier_aura_effect:DrainHealth(target, ability)
	target:ModifyHealth(target:GetHealth() - 8, ability, true, 0)

	Timers:CreateTimer((0.2), function()
		if target then
			if IsValidEntity(target) then
				local mod = target:FindModifierByName("bocuse_5_modifier_aura_effect")
				if mod then mod:DrainHealth(target, ability) end
			end
		end
	end)
end

------------------------------------------------------------

function bocuse_5_modifier_aura_effect:PlayEfxStart()
    if IsServer() then self.parent:EmitSound("Hero_Bristleback.ViscousGoo.Target") end
end

function bocuse_5_modifier_aura_effect:GetEffectName()
	return "particles/bocuse/bocuse_roux_debuff.vpcf"
end

function bocuse_5_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end