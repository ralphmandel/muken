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

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("shadow_3_modifier_walk_cosmetic", true) end

	self.ability:SetActivated(false)
	self:PlayEfxStart()
end

function shadow_3_modifier_walk:OnRefresh(kv)
end

function shadow_3_modifier_walk:OnRemoved()
	if IsServer() then self.parent:EmitSound("Hero_PhantomAssassin.Blur.Break") end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("shadow_3_modifier_walk_cosmetic", false) end

	local delay = self.ability:GetSpecialValueFor("delay")
	self.ability:StartCooldown(delay)
	self.ability:SetActivated(true)
end

-----------------------------------------------------------

function shadow_3_modifier_walk:CheckState()
	local state = {[MODIFIER_STATE_INVISIBLE] = true}
	return state
end

function shadow_3_modifier_walk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ABILITY_START
	}

	return funcs
end

-----------------------------------------------------------

function shadow_3_modifier_walk:GetModifierInvisibilityLevel()
	return 1
end

function shadow_3_modifier_walk:GetModifierProcAttack_Feedback(keys)
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

-----------------------------------------------------------

function shadow_3_modifier_walk:GetEffectName()
	return "particles/econ/items/phantom_assassin/pa_crimson_witness_2021/pa_crimson_witness_blur_ambient.vpcf"
end

function shadow_3_modifier_walk:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function shadow_3_modifier_walk:PlayEfxStart(target)
	local particle = "particles/econ/items/phantom_assassin/pa_crimson_witness_2021/pa_crimson_witness_blur_start.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)

	if IsServer() then EmitSoundOnLocationForAllies(self.parent:GetOrigin(), "Hero_PhantomAssassin.Blur", self.caster) end
end