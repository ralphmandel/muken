genuine_1_modifier_starfall_stack = class ({})

genuine_1_modifier_starfall_stack = class({})

function genuine_1_modifier_starfall_stack:IsHidden() return false end
function genuine_1_modifier_starfall_stack:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_1_modifier_starfall_stack:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(1) end
end

function genuine_1_modifier_starfall_stack:OnRefresh(kv)
	local starfall_combo = self.ability:GetSpecialValueFor("special_starfall_combo")

	if IsServer() then
		if self:GetStackCount() < starfall_combo then
			self:IncrementStackCount()
			if self:GetStackCount() == starfall_combo then
				self:StartIntervalThink(self.ability:GetSpecialValueFor("starfall_delay"))
				self:PlayEfxStarfall()
			end
		end
	end
end

function genuine_1_modifier_starfall_stack:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_1_modifier_starfall_stack:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
		self.ability:GetSpecialValueFor("starfall_radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
	)

	for _,enemy in pairs(enemies) do
		ApplyDamage({
			attacker = self.caster, victim = enemy,
			damage = self.ability:GetSpecialValueFor("starfall_damage"),
			damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability
		})
	end

	if IsServer() then self.parent:EmitSound("Hero_Mirana.Starstorm.Impact") end
	self:Destroy()
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_1_modifier_starfall_stack:PlayEfxStarfall()
	local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Mirana.Starstorm.Cast") end
end