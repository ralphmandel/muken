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

	local cosmetics = self.caster:FindAbilityByName("cosmetics")
	if cosmetics.cosmetic == nil then return end

	local model_name = "models/items/shadowshaman/ss_fall20_immortal_head/ss_fall20_immortal_head.vmdl"
	cosmetics:FadeCosmeticsGesture(model_name, ACT_DOTA_CHANNEL_ABILITY_3)
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
	local amount = self.parent:GetMaxHealth() * self.drain
	self.parent:ModifyHealth(self.parent:GetHealth() - amount, self.ability, true, 0)
	self.caster:ModifyHealth(self.caster:GetHealth() + amount, self.ability, false, 0)
end

--------------------------------------------------------------------------------

function dasdingo_x2_modifier_lash:PlayEfxStart()
	local cosmetics = self.caster:FindAbilityByName("cosmetics")
	if cosmetics.cosmetic == nil then return end

	local model_name = "models/items/shadowshaman/ss_fall20_immortal_head/ss_fall20_immortal_head.vmdl"
	local head = cosmetics:FindCosmeticByModel(model_name)
	if head == nil then return end

	cosmetics:ChangeCosmeticsActivity(true)
	cosmetics:StartCosmeticGesture(model_name, ACT_DOTA_CHANNEL_ABILITY_3)

	local string = "particles/econ/items/shadow_shaman/ss_2021_crimson/shadowshaman_crimson_shackle.vpcf"
	local shackle_particle = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, head)
	ParticleManager:SetParticleControlEnt(shackle_particle, 0, head, PATTACH_POINT_FOLLOW, "attach_tongue", head:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackle_particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self:AddParticle(shackle_particle, true, false, -1, true, false)

	if IsServer() then self.parent:EmitSound("Hero_ShadowShaman.Shackles") end
end