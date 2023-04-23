genuine_u_modifier_star = class({})

function genuine_u_modifier_star:IsHidden() return false end
function genuine_u_modifier_star:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_u_modifier_star:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then
		self:PlayEfxDebuff()
		self:PlayEfxSpecial()

		if self.parent ~= self.caster then
			self:StartIntervalThink(self.ability:GetSpecialValueFor("interval") + 0.1)
		end
	end
end

function genuine_u_modifier_star:OnRefresh(kv)
end

function genuine_u_modifier_star:OnRemoved()
	if IsServer() then self.parent:StopSound("Hero_DeathProphet.Exorcism") end
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_u_modifier_star:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
	}
	
	return funcs
end

function genuine_u_modifier_star:OnHeroKilled(keys)
	if self.parent ~= self.caster then
		if keys.target == self.parent then
			self.ability:EndCooldown()
			self.caster:RemoveModifierByName(self:GetName())
		end
		if keys.target == self.caster then
			self.ability:StartCooldown(180)
			self:Destroy()
		end
	end
end

function genuine_u_modifier_star:GetModifierTotalDamageOutgoing_Percentage(keys)
	if keys.target == self.caster or self.parent == self.caster then return 0 end
	return self.ability:GetSpecialValueFor("target_damage_percent") - 100
end

function genuine_u_modifier_star:GetAbsoluteNoDamagePhysical(keys)
	return self:CheckTarget(keys.attacker)
end

function genuine_u_modifier_star:GetAbsoluteNoDamageMagical(keys)
	return self:CheckTarget(keys.attacker)
end

function genuine_u_modifier_star:GetAbsoluteNoDamagePure(keys)
	return self:CheckTarget(keys.attacker)
end

function genuine_u_modifier_star:OnIntervalThink()
	if self.ability:GetSpecialValueFor("special_starfall") > 0 then
		self.ability:CreateStarfall(self.parent)
	end

	if self.ability:GetSpecialValueFor("special_purge") > 0 then
		self.parent:Purge(true, false, false, false, false)
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
			percent = 100, duration = 0.5
		})
	end

	if IsServer() then
		self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
		self:PlayEfxSpecial()
	end
end

-- UTILS -----------------------------------------------------------

function genuine_u_modifier_star:CheckTarget(target)
	if self.parent ~= self.caster then return 0 end
	if target == nil then return 1 end
	if IsValidEntity(target) == false then return 1 end
	if target:IsBaseNPC() == false then return 1 end
	if target:HasModifier("genuine_u_modifier_star") == false then return 1 end
	return 0
end

-- EFFECTS -----------------------------------------------------------

function genuine_u_modifier_star:PlayEfxDebuff()
	local particle = "particles/genuine/genuine_ultimate.vpcf"
	self.effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	self:AddParticle(self.effect_caster, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_DeathProphet.Exorcism") end
end

function genuine_u_modifier_star:PlayEfxSpecial()
	local particle_cast = "particles/genuine/ult_deny/genuine_deny_v2.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end