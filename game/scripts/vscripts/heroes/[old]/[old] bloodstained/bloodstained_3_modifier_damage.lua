bloodstained_3_modifier_damage = class({})

function bloodstained_3_modifier_damage:IsHidden() return true end
function bloodstained_3_modifier_damage:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_3_modifier_damage:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then self:OnIntervalThink() end
end

function bloodstained_3_modifier_damage:OnRefresh(kv)
end

function bloodstained_3_modifier_damage:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_3_modifier_damage:OnIntervalThink()	
	ApplyDamage({
		victim = self.parent, attacker = self.caster,
		damage = self.parent:GetMaxHealth() * self.ability:GetSpecialValueFor("special_curse_damage") * 0.01,
		damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability
	})

	if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("special_curse_interval")) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------