spike_armor_modifier = class({})

function spike_armor_modifier:IsHidden()
	return false
end

function spike_armor_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function spike_armor_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

end

function spike_armor_modifier:OnRefresh( kv )
end

function spike_armor_modifier:OnRemoved()
end

--------------------------------------------------------------------------------

function spike_armor_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function spike_armor_modifier:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	local return_percent = self.ability:GetSpecialValueFor("return_percent") * 0.01

	if keys.damage_flags ~= 31 then
		local damageTable = {
			damage = keys.damage * return_percent,
			damage_type = keys.damage_type,
			attacker = self.caster,
			victim = keys.attacker,
			ability = self.ability,
			damage_flags = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR
      + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_REFLECTION
		}

		if IsServer() then keys.attacker:EmitSound("DOTA_Item.BladeMail.Damage") end
		ApplyDamage(damageTable)
	end
end

--------------------------------------------------------------------------------

function spike_armor_modifier:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function spike_armor_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end