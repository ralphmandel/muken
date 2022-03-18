dasdingo_2_modifier_aura_effect = class({})

function dasdingo_2_modifier_aura_effect:IsHidden()
	return false
end

function dasdingo_2_modifier_aura_effect:IsPurgable()
	return false
end

-----------------------------------------------------------

function dasdingo_2_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local defense = self.ability:GetSpecialValueFor("defense")
	local resistance = 8
	local special = 0

	-- UP 2.21
	if self.ability:GetRank(21) then
		defense = defense + 8
	end

	if self.caster ~= self.parent then
		defense = defense * 0.5
		resistance = resistance * 0.5
	end

	self.ability:AddBonus("_2_DEF", self.parent, defense, 0, nil)
	self.def = defense
	self.res = 0

	-- UP 2.22
	if self.ability:GetRank(22) then
		self.ability:AddBonus("_2_RES", self.parent, resistance, 0, nil)
		self.res = resistance
	end

	self:PlayEfxStart()
end

function dasdingo_2_modifier_aura_effect:OnRefresh(kv)
end

function dasdingo_2_modifier_aura_effect:OnRemoved(kv)
	self.ability:RemoveBonus("_2_DEF", self.parent)
	self.ability:RemoveBonus("_2_RES", self.parent)
end

------------------------------------------------------------

function dasdingo_2_modifier_aura_effect:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function dasdingo_2_modifier_aura_effect:GetModifierIncomingDamage_Percentage(keys)
	if keys.attacker == nil then return end

	-- UP 2.31
	if self.ability:GetRank(31) then
		if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
			local damageTable = {
				victim = keys.attacker,
				attacker = self.parent,
				damage = keys.original_damage * 0.4,
				damage_type = keys.damage_type,
				ability = self.ability,
				damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
			}
			ApplyDamage(damageTable)
		end
	end
end

function dasdingo_2_modifier_aura_effect:GetModifierPhysicalArmorBonus()
	if self:GetParent():IsHero() == false then
		return self.def * 0.4
	end
	return 0
end

function dasdingo_2_modifier_aura_effect:GetModifierMagicalResistanceBonus()
	if self:GetParent():IsHero() == false then
		return self.res
	end
	return 0
end

-----------------------------------------------------------

function dasdingo_2_modifier_aura_effect:PlayEfxStart()
	local special = (self.ability:GetLevel() - 1) * 10
	local string = "particles/dasdingo/dasdingo_aura.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effect_cast, 3, Vector(special, 0, 0 ))

	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Pangolier.TailThump.Cast") end
end