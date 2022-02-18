strider_1_modifier_spirit = class ({})

function strider_1_modifier_spirit:IsHidden()
    return false
end

function strider_1_modifier_spirit:IsPurgable()
    return false
end

-----------------------------------------------------------

function strider_1_modifier_spirit:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local player = PlayerResource:GetPlayer(self.parent:GetPlayerOwnerID())
	self.hero = player:GetAssignedHero()

	self.parent:SetOrigin(self.hero:GetOrigin())

	self.delay = true
	self:PlayEfxStart()
	self:StartIntervalThink(0.5)
end

function strider_1_modifier_spirit:OnRefresh(kv)
end

function strider_1_modifier_spirit:OnRemoved(kv)
	if self.parent:IsAlive() then
		self.parent:ForceKill(false)
	end

	self.hero:RemoveModifierByName("strider_1_modifier_debuff")
end

------------------------------------------------------------

function strider_1_modifier_spirit:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

function strider_1_modifier_spirit:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_EVENT_ON_MODIFIER_ADDED
	}
	
	return funcs
end

function strider_1_modifier_spirit:GetModifierAvoidDamage(keys)
	return 1
end

function strider_1_modifier_spirit:OnModifierAdded(keys)
	for k, v in pairs(keys) do
		print(k, v)
	end
end

function strider_1_modifier_spirit:OnIntervalThink()
	if self.delay == true then
		self.delay = false
		self:StartIntervalThink(0.1)
		return
	end

	if CalcDistanceBetweenEntityOBB(self.hero, self.parent) < 15 then
		self:StartIntervalThink(-1)
		self:Destroy()
	end
end

------------------------------------------------------------------------

function strider_1_modifier_spirit:GetStatusEffectName()
	return "particles/strider/strider__status_effect_arcana.vpcf"
end

function strider_1_modifier_spirit:StatusEffectPriority()
	return 99999999
end

function strider_1_modifier_spirit:PlayEfxStart()
	local particle_cast = "particles/strider/strider_mark_debuff_white.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, true)
end