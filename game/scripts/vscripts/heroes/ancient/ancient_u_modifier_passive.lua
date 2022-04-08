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

	self.ability.mana_loss = 0

	if IsServer() then
		self:PlayEfxBuff()
		self:StartIntervalThink(FrameTime())
	end
end

function ancient_u_modifier_passive:OnRefresh(kv)
end

function ancient_u_modifier_passive:OnRemoved(kv)
end

------------------------------------------------------------

function ancient_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT
	}

	return funcs
end

function ancient_u_modifier_passive:GetModifierConstantManaRegen()
	if self.parent:HasModifier("ancient_3_modifier_aura") then return 0 end
    return -self.ability.mana_loss
end

function ancient_u_modifier_passive:GetModifierIncomingSpellDamageConstant(keys)
	local damage = 0
	local percent = self.ability:GetSpecialValueFor("percent")
	if keys.damage_type == DAMAGE_TYPE_PURE then damage = keys.original_damage end
	if keys.damage_type == DAMAGE_TYPE_MAGICAL then damage = keys.damage end

	local reduction = damage * percent * self.parent:GetMana() * 0.01
	self.ability.mana_loss = self.ability.mana_loss + (reduction * 0.01)

	return -reduction
end

function ancient_u_modifier_passive:OnIntervalThink()
	ParticleManager:SetParticleControl(self.effect_caster, 3, Vector(self.parent:GetMana(), 0, 0))
end

-----------------------------------------------------------

function ancient_u_modifier_passive:PlayEfxBuff()
	local particle = "particles/ancient/ancient_magic_buff.vpcf"
	self.effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 3, Vector(self.parent:GetMana(), 0, 0))
	ParticleManager:SetParticleControl(self.effect_caster, 16, Vector(255, 255, 255))
	self:AddParticle(self.effect_caster, false, false, -1, false, false)
end