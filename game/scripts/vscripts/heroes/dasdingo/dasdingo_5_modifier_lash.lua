dasdingo_5_modifier_lash = class({})

function dasdingo_5_modifier_lash:IsHidden()
	return false
end

function dasdingo_5_modifier_lash:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function dasdingo_5_modifier_lash:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	-- UP 5.11
	if self.ability:GetRank(11) then
		self.ability:AddBonus("_2_DEX", self.caster, 15, 0, nil)   
	end

	-- UP 5.21
	if self.ability:GetRank(21) then
		self.caster:AddNewModifier(self.caster, self.ability, "_modifier_bkb", {})        
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_stun", {})

	if IsServer() then
		self.ticks = 0.25
		local drain_percent = self.ability:GetSpecialValueFor("drain_percent")

		-- UP 5.32
		if self.ability:GetRank(32) then
			drain_percent = drain_percent + 1.5
		end

		self.drain = drain_percent * self.ticks * 0.01
		self.mp_drain = self.ticks * 0.05

		self:PlayEfxStart()
		self:StartIntervalThink(self.ticks)
	end
end

function dasdingo_5_modifier_lash:OnRefresh(kv)
end

function dasdingo_5_modifier_lash:OnRemoved(kv)
	self.caster:Interrupt()
	if IsServer() then self.parent:StopSound("Hero_ShadowShaman.Shackles") end

	local cosmetics = self.caster:FindAbilityByName("cosmetics")
	if cosmetics.cosmetic == nil then return end

	local model_name = "models/items/shadowshaman/ss_fall20_immortal_head/ss_fall20_immortal_head.vmdl"
	cosmetics:FadeCosmeticsGesture(model_name, ACT_DOTA_CHANNEL_ABILITY_3)

	self.ability:RemoveBonus("_2_DEX", self.caster)

	local mod = self.caster:FindAllModifiersByName("_modifier_bkb")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_stun")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

--------------------------------------------------------------------------------

-- function dasdingo_5_modifier_lash:CheckState()
-- 	return {[MODIFIER_STATE_STUNNED] = true}
-- end

-- function dasdingo_5_modifier_lash:DeclareFunctions()
-- 	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
-- end

-- function dasdingo_5_modifier_lash:GetOverrideAnimation()
-- 	return ACT_DOTA_DISABLED
-- end

function dasdingo_5_modifier_lash:OnIntervalThink()
	local amount = self.parent:GetMaxHealth() * self.drain
	self.parent:ModifyHealth(self.parent:GetHealth() - amount, self.ability, true, 0)
	self.caster:ModifyHealth(self.caster:GetHealth() + amount, self.ability, false, 0)

	-- UP 5.31
	if self.ability:GetRank(31) then
		local mp_amount = math.floor(self.parent:GetMaxMana() * self.mp_drain)
		if mp_amount > self.parent:GetMana() then mp_amount = self.parent:GetMana() end
        if mp_amount > 0 then
            self.parent:ReduceMana(mp_amount)
            self.caster:GiveMana(mp_amount)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, self.parent, mp_amount, self.caster)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.caster, mp_amount, self.caster)
        end
	end

	self:StartIntervalThink(-1)
	self:StartIntervalThink(self.ticks)
end

--------------------------------------------------------------------------------

function dasdingo_5_modifier_lash:PlayEfxStart()
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