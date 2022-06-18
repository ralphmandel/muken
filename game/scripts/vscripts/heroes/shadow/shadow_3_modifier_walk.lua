shadow_3_modifier_walk = class({})

function shadow_3_modifier_walk:IsHidden()
	return false
end

function shadow_3_modifier_walk:IsPurgable()
	return true
end

-----------------------------------------------------------

function shadow_3_modifier_walk:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	-- local cosmetics = self.parent:FindAbilityByName("cosmetics")
	-- if cosmetics then cosmetics:SetStatusEffect("shadow_3_modifier_walk_cosmetic", true) end

	self.invi = false
	self.hits = 1
	self.ability:SetActivated(false)
	self:PlayEfxStart()

	-- UP 3.13
	if self.ability:GetRank(13) then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {
			percent = 20
		})
	end

	-- UP 3.23
	if self.ability:GetRank(23) then
		self.hits = 5
	end

	if IsServer() then self:StartIntervalThink(0.5) end
end

function shadow_3_modifier_walk:OnRefresh(kv)
end

function shadow_3_modifier_walk:OnRemoved()
	if self.parent:IsIllusion() and self.parent:IsAlive() == false then return end
	if IsServer() then self.parent:EmitSound("Hero_PhantomAssassin.Blur.Break") end

	-- local cosmetics = self.parent:FindAbilityByName("cosmetics")
	-- if cosmetics then cosmetics:SetStatusEffect("shadow_3_modifier_walk_cosmetic", false) end

	self.ability:SetActivated(true)
	self.ability:StartRechargeTime()

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function shadow_3_modifier_walk:CheckState()
	local state = {}
	
	if self.invi then
		state = {[MODIFIER_STATE_INVISIBLE] = true}
	end

	return state
end

function shadow_3_modifier_walk:DeclareFunctions()
	local funcs = {
		--MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_START
	}

	return funcs
end

-----------------------------------------------------------

-- function shadow_3_modifier_walk:GetModifierInvisibilityLevel()
-- 	return 1
-- end

function shadow_3_modifier_walk:GetModifierPreAttack(keys)
	self.hits = self.hits - 1
	if self.hits > 0 then return end

	local shadow_duration = self.ability:GetSpecialValueFor("shadow_duration")
    local shadow_number = self.ability:GetSpecialValueFor("shadow_number")

	-- UP 3.21
	if self.ability:GetRank(21) then
		shadow_duration = shadow_duration + 5
		shadow_number = shadow_number + 1
	end

	self.ability:CreateShadow(keys.target, shadow_duration, shadow_number, true)
	self:Destroy()
end

function shadow_3_modifier_walk:OnAbilityStart(keys)
	if keys.unit == self:GetParent() 
	and keys.ability ~= nil then
		if keys.ability:GetAbilityName() ~= "shadow_2__puddle" then
			self:Destroy()
		end
	end
end

function shadow_3_modifier_walk:OnIntervalThink()
	self.invi = true
	self:StartIntervalThink(-1)
end

-----------------------------------------------------------

function shadow_3_modifier_walk:GetEffectName()
	return "particles/shadowmancer/blur/shadowmancer_blur_ambient.vpcf"
end

function shadow_3_modifier_walk:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function shadow_3_modifier_walk:PlayEfxStart(target)
	local particle = "particles/shadowmancer/blur/shadowmancer_blur_start.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)

	if IsServer() then self.parent:EmitSound("Hero_PhantomAssassin.Blur") end
	--if IsServer() then EmitSoundOnLocationForAllies(self.parent:GetOrigin(), "string", self.caster) end
end