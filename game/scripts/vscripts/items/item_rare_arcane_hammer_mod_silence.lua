item_rare_arcane_hammer_mod_silence = class({})

function item_rare_arcane_hammer_mod_silence:IsHidden()
    return false
end

function item_rare_arcane_hammer_mod_silence:IsPurgable()
    return true
end

function item_rare_arcane_hammer_mod_silence:IsDebuff()
    return true
end

---------------------------------------------------------------------------------------------------

function item_rare_arcane_hammer_mod_silence:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.damage_percent = self.ability:GetSpecialValueFor("damage_percent") * 0.01
	self.total_damage = 0
end

function item_rare_arcane_hammer_mod_silence:OnRefresh( kv )
end

function item_rare_arcane_hammer_mod_silence:OnRemoved( kv )
	if IsServer() then self.parent:EmitSound("Arcane_Hammer.End") end
	RemoveBonus(self.ability, "_1_INT", self.parent)
	
	local damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = 50 + (self.total_damage * self.damage_percent),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}
	ApplyDamage(damageTable)
end

---------------------------------------------------------------------------------------------------

function item_rare_arcane_hammer_mod_silence:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true
	}

	return state
end

function item_rare_arcane_hammer_mod_silence:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function item_rare_arcane_hammer_mod_silence:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	self.total_damage = self.total_damage + keys.damage
end

---------------------------------------------------------------------------------------------------

function item_rare_arcane_hammer_mod_silence:GetEffectName()
	return "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_orchid.vpcf"
end

function item_rare_arcane_hammer_mod_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end