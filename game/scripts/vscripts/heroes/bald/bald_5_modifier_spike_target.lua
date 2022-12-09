bald_5_modifier_spike_target = class({})

function bald_5_modifier_spike_target:IsHidden() return false end
function bald_5_modifier_spike_target:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_5_modifier_spike_target:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	
	self.caster:AddNewModifier(self.caster, self.ability, "bald_5_modifier_spike_caster", {
		duration = self:GetDuration()
	})

	local movespeed = self.ability:GetSpecialValueFor("movespeed")
	if movespeed > 0 then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {
			percent = movespeed
		})
	end

	if IsServer() then self:PlayEfxStart() end
end

function bald_5_modifier_spike_target:OnRefresh(kv)
	self.caster:AddNewModifier(self.caster, self.ability, "bald_5_modifier_spike_caster", {
		duration = self:GetDuration()
	})
end

function bald_5_modifier_spike_target:OnRemoved()
	local mod_caster = self.caster:FindModifierByNameAndCaster("bald_5_modifier_spike_caster", self.caster)
	if mod_caster then mod_caster:DecrementStackCount() end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_5_modifier_spike_target:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function bald_5_modifier_spike_target:GetAbsorbSpell(keys)
	local absorb_skill = self.ability:GetSpecialValueFor("absorb_skill")

	if absorb_skill > 0 then
		local attacker = keys.ability:GetCaster()
		attacker:SetCursorCastTarget(self.caster)
		keys.ability:OnSpellStart()
	end

	return absorb_skill
end

function bald_5_modifier_spike_target:GetModifierIncomingDamage_Percentage(keys)
	local percent = self.ability:GetSpecialValueFor("percent")

	local total = ApplyDamage({
		damage = keys.original_damage * percent * 0.01,
		attacker = keys.attacker,
		victim = self.caster,
		damage_type = keys.damage_type,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
		ability = keys.inflictor
	})

	self:PlayEfxHit()

	return -percent
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_5_modifier_spike_target:GetEffectName()
	return "particles/items3_fx/star_emblem_friend_shield.vpcf"
end

function bald_5_modifier_spike_target:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function bald_5_modifier_spike_target:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Item.StarEmblem.Friendly") end
end

function bald_5_modifier_spike_target:PlayEfxHit()
	local particle_cast = "particles/econ/items/dark_seer/dark_seer_ti8_immortal_arms/dark_seer_ti8_immortal_ion_shell_dmg_golden.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.caster:EmitSound("Hero_Bristleback.PistonProngs.Bristleback") end
end