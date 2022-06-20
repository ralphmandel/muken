dasdingo_x2_modifier_lash = class({})

function dasdingo_x2_modifier_lash:IsHidden()
	return false
end

function dasdingo_x2_modifier_lash:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function dasdingo_x2_modifier_lash:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		local ticks = 0.5
		local drain_percent = self.ability:GetSpecialValueFor("drain_percent") * 0.01
		self.drain = drain_percent * ticks

		self:PlayEfxStart()
		self:StartIntervalThink(ticks)
	end
end

function dasdingo_x2_modifier_lash:OnRefresh(kv)
end

function dasdingo_x2_modifier_lash:OnRemoved(kv)
	self.caster:Interrupt()
	if IsServer() then self.parent:StopSound("Hero_ShadowShaman.Shackles") end
end

--------------------------------------------------------------------------------

function dasdingo_x2_modifier_lash:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function dasdingo_x2_modifier_lash:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function dasdingo_x2_modifier_lash:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function dasdingo_x2_modifier_lash:OnIntervalThink()
	local hp = self.parent:GetMaxHealth()
	local amount = hp * self.drain
	self.parent:ModifyHealth(hp - amount, self.ability, true, 0)

	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then amount = amount * base_stats:GetHealPower() end
    if amount > 0 then self.caster:Heal(amount, self.ability) end
end

--------------------------------------------------------------------------------

function dasdingo_x2_modifier_lash:PlayEfxStart()
	--local string = "particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf"
	local string = "particles/econ/items/shadow_shaman/ss_2021_crimson/shadowshaman_crimson_shackle.vpcf"
	local shackle_particle = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(shackle_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_tongue", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackle_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(shackle_particle, true, false, -1, true, false)

	if IsServer() then self.parent:EmitSound("Hero_ShadowShaman.Shackles") end
end