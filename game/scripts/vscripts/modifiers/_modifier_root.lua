_modifier_root = class({})

--------------------------------------------------------------------------------
function _modifier_root:IsHidden()
	return false
end

function _modifier_root:IsPurgable()
	return true
end

function _modifier_root:GetTexture()
	return "_modifier_root"
end

function _modifier_root:IsDebuff()
	return true
end

function _modifier_root:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------

function _modifier_root:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.effect = kv.effect
	self.sound = "Hero_DarkWillow.Bramble.Target.Layer"

	local path
	if self.effect == 1 then
		path = "particles/units/heroes/hero_treant/treant_bramble_root.vpcf"
	elseif self.effect == 2 then
		path = "particles/units/heroes/heroes_underlord/abyssal_underlord_pitofmalice_stun.vpcf"
	elseif self.effect == 3 then
		path = "particles/units/heroes/hero_treant/treant_overgrowth_vines_small.vpcf"
	elseif self.effect == 4 then
		path = "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf"
		--self.sound = "Hero_Treant.Overgrowth.Target"
	elseif self.effect == 5 then
		path = "particles/units/heroes/hero_treant/treant_bramble_root.vpcf"
		self.sound = "Druid.Root"
	elseif self.effect == 6 then
		path = "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
		self.sound = "Hero_Treant.Overgrowth.Target"
	elseif self.effect == 7 then
		path = "particles/econ/items/lone_druid/lone_druid_cauldron_retro/lone_druid_bear_entangle_retro_cauldron.vpcf"
		self.sound = "LoneDruid_SpiritBear.Entangle"
	end

	self:PlayEfxStart(path)
end

function _modifier_root:OnRemoved(kv)
	ParticleManager:DestroyParticle(self.particle, false)

	local druid_root = self.parent:FindModifierByName("druid_2_modifier_aura_effect")
	if self.ability == nil then return end
	
	if druid_root
	and self.ability:GetAbilityName() == "druid_2__root"
	and self.effect == 5 then
		druid_root:StartIntervalThink(3)
	end
end
--------------------------------------------------------------------------------

function _modifier_root:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_INVISIBLE] = false
	}

	return state
end

function _modifier_root:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

--------------------------------------------------------------------------------

function _modifier_root:PlayEfxStart(path)
	self.particle = ParticleManager:CreateParticle(path, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound(self.sound) end
end