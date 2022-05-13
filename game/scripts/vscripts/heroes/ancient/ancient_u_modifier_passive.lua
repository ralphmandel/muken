ancient_u_modifier_passive = class ({})

function ancient_u_modifier_passive:IsHidden()
    return false
end

function ancient_u_modifier_passive:IsPurgable()
    return false
end

-----------------------------------------------------------

function ancient_u_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.hp_regen = 0
	self.ability.mana_loss = 0

	if IsServer() then
		self:SetStackCount(0)
		self:PlayEfxBuff()
		self:StartIntervalThink(FrameTime())
	end
end

function ancient_u_modifier_passive:OnRefresh(kv)
	if IsServer() then
		self:PlayEfxBuff()
		self:StartIntervalThink(FrameTime())
	end
end

function ancient_u_modifier_passive:OnRemoved(kv)
end

------------------------------------------------------------

function ancient_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT
	}

	return funcs
end

function ancient_u_modifier_passive:GetModifierManaBonus()
	return self.ability.mana_bonus
end

function ancient_u_modifier_passive:GetModifierConstantHealthRegen()
    return self.hp_regen
end

function ancient_u_modifier_passive:GetModifierConstantManaRegen()
	if self.parent:HasModifier("ancient_3_modifier_aura") then return 0 end
    return -self.ability.mana_loss
end

function ancient_u_modifier_passive:GetModifierIncomingSpellDamageConstant(keys)
	local damage = 0
	local percent = self.ability:GetSpecialValueFor("percent")

	-- UP 4.11
	if self.ability:GetRank(11) then
		percent = percent + 0.01
	end	

	if keys.damage_type == DAMAGE_TYPE_PURE then damage = keys.original_damage end
	if keys.damage_type == DAMAGE_TYPE_MAGICAL then damage = keys.damage end

	local reduction = damage * percent * self.parent:GetMana() * 0.01
	self.ability.mana_loss = self.ability.mana_loss + (reduction * 0.01)

	return -reduction
end

function ancient_u_modifier_passive:OnIntervalThink()
	local value = self.parent:GetMana()
	if self.ability.casting == true then value = 0 end
	if self.effect_caster then ParticleManager:SetParticleControl(self.effect_caster, 1, Vector(value, 0, 0)) end
	if self.ancient_mace then
		ParticleManager:SetParticleControl(self.ancient_mace, 20, Vector(value, 30, 12))
		ParticleManager:SetParticleControl(self.ancient_mace, 21, Vector(value * 0.01, 0, 0))
	end

	if self.parent:GetManaPercent() < self.ability.min_mana then
		self.ability:SetActivated(false)
	else
		self.ability:SetActivated(true)
	end

	-- UP 4.21
	if self.ability:GetRank(21) then
		self.hp_regen = self.parent:GetMana() * 0.03
	end
end

-----------------------------------------------------------

function ancient_u_modifier_passive:PlayEfxBuff()
	if self.effect_caster then ParticleManager:DestroyParticle(self.effect_caster, false) end

	self.effect_caster = ParticleManager:CreateParticle("particles/ancient/ancient_aura_alt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 1, Vector(self.parent:GetMana(), 0, 0))
	--ParticleManager:SetParticleControl(self.effect_caster, 16, Vector(255, 255, 255))
	self:AddParticle(self.effect_caster, false, false, -1, false, false)

	local channel = self.parent:FindAbilityByName("_channel")
	if channel then
		for i = 1, #channel.models, 1 do
			if channel.models[i] == "models/items/elder_titan/harness_of_the_soulforged_weapon/harness_of_the_soulforged_weapon.vmdl" then
				local mod_cosmetic = channel.cosmetic[i]:FindModifierByName("_modifier_cosmetics")
				if mod_cosmetic then self.ancient_mace = mod_cosmetic.ancient_mace end
			end
		end	
	end

	if self.ancient_mace then
		ParticleManager:SetParticleControl(self.ancient_mace, 20, Vector(self.parent:GetMana(), 30, 12))
		ParticleManager:SetParticleControl(self.ancient_mace, 21, Vector(self.parent:GetMana() * 0.01, 0, 0))
	end
end