fireball_modifier = class({})

function fireball_modifier:IsHidden()
	return false
end

function fireball_modifier:IsPurgable()
	return true
end

function fireball_modifier:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function fireball_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local flame_damage = self.ability:GetSpecialValueFor("flame_damage") * 0.5

	self.damageTable = {
        victim = self.parent,
        attacker = self.caster,
        damage = flame_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self.ability
    }

	self:PlayEfxStart()
	self:StartIntervalThink(0.5)
end

function fireball_modifier:OnRefresh( kv )
end

function fireball_modifier:OnRemoved()
	if IsServer() then self.parent:StopSound("Hero_Huskar.Burning_Spear") end
end

--------------------------------------------------------------------------------

function fireball_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function fireball_modifier:OnDeath(keys)
	if keys.unit ~= self.caster then return end
	self:Destroy()
end 

function fireball_modifier:OnIntervalThink()
	if self.caster == nil then self:Destroy() return end
	if IsValidEntity(self.caster) == false then self:Destroy() return end
	
	ApplyDamage(self.damageTable)
end

--------------------------------------------------------------------------------

function fireball_modifier:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function fireball_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function fireball_modifier:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Huskar.Burning_Spear") end
end