inquisitor_x2_modifier_redemption = class({})

function inquisitor_x2_modifier_redemption:IsHidden()
	return false
end

function inquisitor_x2_modifier_redemption:IsDebuff()
	return false
end

function inquisitor_x2_modifier_redemption:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function inquisitor_x2_modifier_redemption:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self:PlayEfxCast()
end

--------------------------------------------------------------------------------

function inquisitor_x2_modifier_redemption:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}

	return funcs
end
function inquisitor_x2_modifier_redemption:GetMinHealth()
	return 1
end

--------------------------------------------------------------------------------

function inquisitor_x2_modifier_redemption:GetEffectName()
	return "particles/econ/items/dazzle/dazzle_ti6_gold/dazzle_ti6_shallow_grave_gold.vpcf"
end

function inquisitor_x2_modifier_redemption:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function inquisitor_x2_modifier_redemption:PlayEfxCast()
	local particle = "particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Hero_SkywrathMage.AncientSeal.Target") end
end