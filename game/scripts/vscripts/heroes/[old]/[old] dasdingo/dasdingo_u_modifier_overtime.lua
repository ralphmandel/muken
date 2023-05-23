dasdingo_u_modifier_overtime = class({})

function dasdingo_u_modifier_overtime:IsHidden()
	return true
end

function dasdingo_u_modifier_overtime:IsDebuff()
	return true
end

function dasdingo_u_modifier_overtime:IsPurgable()
	return false
end

-----------------------------------------------------------

function dasdingo_u_modifier_overtime:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = 3,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self.ability
	}

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		percent = 75
	})

	self:StartIntervalThink(0.2)
end

function dasdingo_u_modifier_overtime:OnRefresh(kv)
end

function dasdingo_u_modifier_overtime:OnRemoved(kv)
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

------------------------------------------------------------

function dasdingo_u_modifier_overtime:OnIntervalThink()
	local find = false
	local units = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, 325,
		DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		16, 0, false
	)

	for _,unit in pairs(units) do
		if unit ~= self.parent then
			local mods = unit:FindAllModifiersByName("dasdingo_u_modifier_maledict")
			for _,modifier in pairs(mods) do
				if modifier:GetAbility() == self.ability then
					find = true
					break
				end
			end
		end
	end

	if find == true then
		ApplyDamage(self.damageTable)
	else
		self:Destroy()
	end
end

-----------------------------------------------------------

function dasdingo_u_modifier_overtime:GetEffectName()
	return "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6_knockback_debuff.vpcf"
end

function dasdingo_u_modifier_overtime:GetEffectAttachType()
	return dasdingo_u_modifier_overtime
end