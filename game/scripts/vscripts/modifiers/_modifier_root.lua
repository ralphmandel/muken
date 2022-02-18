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

	local effect = kv.effect
	self.sound = "Hero_DarkWillow.Bramble.Target.Layer"

	local path
	if effect == 1 then
		path = "particles/units/heroes/hero_treant/treant_bramble_root.vpcf"
	elseif effect == 2 then
		path = "particles/units/heroes/heroes_underlord/abyssal_underlord_pitofmalice_stun.vpcf"
	elseif effect == 3 then
		path = "particles/units/heroes/hero_treant/treant_overgrowth_vines_small.vpcf"
	elseif effect == 4 then
		path = "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf"
		--self.sound = "Hero_Treant.Overgrowth.Target"
	end
		

	self:PlayEfxStart(path)
end

function _modifier_root:OnRemoved(kv)
	ParticleManager:DestroyParticle(self.particle, false)
end
--------------------------------------------------------------------------------

function _modifier_root:CheckState()
	local state = {
	[MODIFIER_STATE_ROOTED] = true,
	[MODIFIER_STATE_INVISIBLE] = false,
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