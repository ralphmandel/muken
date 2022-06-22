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
	local special = 0

	-- UP 2.31
	if self.ability:GetRank(31) then
		defense = defense + 10
	end

	self.ability:AddBonus("_2_DEF", self.parent, defense, 0, nil)
	self.def = defense

	if self.parent:IsHero() and self.parent:IsIllusion() == false then
		self.ability.total_regen = self.ability.total_regen + 1
	end

	self:PlayEfxStart()
end

function dasdingo_2_modifier_aura_effect:OnRefresh(kv)
end

function dasdingo_2_modifier_aura_effect:OnRemoved(kv)
	self.ability:RemoveBonus("_2_DEF", self.parent)

	if self.parent:IsHero() and self.parent:IsIllusion() == false then
		self.ability.total_regen = self.ability.total_regen - 1
	end
end

------------------------------------------------------------

function dasdingo_2_modifier_aura_effect:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function dasdingo_2_modifier_aura_effect:GetModifierIncomingDamage_Percentage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end

	-- UP 2.21
	if self.ability:GetRank(21) then
		if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
			local damageTable = {
				victim = keys.attacker,
				attacker = self.parent,
				damage = keys.original_damage * 0.3,
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

-----------------------------------------------------------

function dasdingo_2_modifier_aura_effect:PlayEfxStart()
	local special = ((self.ability:GetLevel() - 1) * 12) + 8
	local string = "particles/dasdingo/dasdingo_aura.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effect_cast, 3, Vector(special, 0, 0 ))

	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Pangolier.TailThump.Cast") end
end