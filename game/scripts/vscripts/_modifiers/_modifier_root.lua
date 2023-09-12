_modifier_root = class({})

function _modifier_root:IsHidden() return false end
function _modifier_root:IsPurgable() return true end
function _modifier_root:GetTexture() return "_modifier_root" end
function _modifier_root:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

--------------------------------------------------------------------------------

function _modifier_root:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
  self.ability = self:GetAbility()

	local effect = kv.effect or 0
	local sound = "Druid.Root"
	local path = nil

	if effect == 1 then
		path = "particles/units/heroes/hero_treant/treant_bramble_root.vpcf"
	elseif effect == 2 then
		path = "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_crimson_ti8_immortal_pitofmalice_stun.vpcf"
    sound = "Hero_AbyssalUnderlord.Pit.Target"
	elseif effect == 3 then
		path = "particles/units/heroes/hero_treant/treant_overgrowth_vines_small.vpcf"
	elseif effect == 4 then
		path = "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf"
		--sound = "Hero_Treant.Overgrowth.Target"
		--sound = "Hero_DarkWillow.Bramble.Target.Layer"
	elseif effect == 5 then
		path = "particles/units/heroes/hero_treant/treant_bramble_root.vpcf"
		sound = "Druid.Root"
	elseif effect == 6 then
		path = "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
		sound = "Hero_Treant.Overgrowth.Target"
	elseif effect == 7 then
		path = "particles/econ/items/lone_druid/lone_druid_cauldron_retro/lone_druid_bear_entangle_retro_cauldron.vpcf"
		sound = "LoneDruid_SpiritBear.Entangle"
	elseif effect == 8 then
		path = "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root.vpcf"
  elseif effect == 9 then
    path = "particles/units/heroes/hero_oracle/oracle_fortune_purge.vpcf"
    sound = nil
	end

	self:PlayEfxStart(path, sound)
end

function _modifier_root:OnRemoved(kv)
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end
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

function _modifier_root:PlayEfxStart(path, sound)
  if path == nil then return end
	self.particle = ParticleManager:CreateParticle(path, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetOrigin())

  if sound == nil then return end
	if IsServer() then self.parent:EmitSound(sound) end
end