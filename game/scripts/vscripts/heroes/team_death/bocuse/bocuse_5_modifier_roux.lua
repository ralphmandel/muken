bocuse_5_modifier_roux = class({})

function bocuse_5_modifier_roux:IsHidden() return true end
function bocuse_5_modifier_roux:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function bocuse_5_modifier_roux:IsAura() return true end
function bocuse_5_modifier_roux:GetModifierAura() return "bocuse_5_modifier_roux_aura_effect" end
function bocuse_5_modifier_roux:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function bocuse_5_modifier_roux:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function bocuse_5_modifier_roux:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function bocuse_5_modifier_roux:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function bocuse_5_modifier_roux:GetAuraEntityReject(hEntity) return hEntity:IsRooted() end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_5_modifier_roux:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.init = true

  if self.ability:GetSpecialValueFor("special_pull") == 1 then
    self:PullEnemies()
  end

	if IsServer() then
		self.parent:EmitSound("Hero_Bocuse.Roux")
		self:StartIntervalThink(0.25)
	end
end

function bocuse_5_modifier_roux:OnRefresh(kv)
end

function bocuse_5_modifier_roux:OnRemoved()
	if IsServer() then self:PlayEfxFinal(self.ability:GetAOERadius()) end
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_5_modifier_roux:OnIntervalThink()
	local radius = self.ability:GetAOERadius()

	if IsServer() then
		if self.init == true then
			self:PlayEfxStart(radius)
			self.init = false
		elseif self.effect_cast then
			ParticleManager:SetParticleControl(self.effect_cast, 10, Vector(radius, radius, radius))
		end
	end
end

-- UTILS -----------------------------------------------------------

function bocuse_5_modifier_roux:PullEnemies()
  if IsServer() then self.parent:EmitSound("Hero_Dark_Seer.Vacuum") end

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius() + 50,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

  for _,enemy in pairs(enemies) do
    enemy:AddNewModifier(self.caster, self.ability, "_modifier_pull", {
      duration = 0.5,
      x = self.parent:GetOrigin().x,
      y = self.parent:GetOrigin().y,
    })
	end
end

-- EFFECTS -----------------------------------------------------------

function bocuse_5_modifier_roux:PlayEfxStart(radius)
	local particle_cast = "particles/bocuse/bocuse_roux_aoe_mass.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_cast, 10, Vector(radius, radius, radius))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), radius, self:GetDuration() + 1, false)
  if IsServer() then self.parent:EmitSound("Brewmaster_Storm.Cyclone") end
end

function bocuse_5_modifier_roux:PlayEfxFinal(radius)
  local particle_cast = "particles/units/heroes/hero_sandking/sandking_epicenter.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))

	if IsServer() then
			self.parent:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")
			self.parent:StopSound("Brewmaster_Storm.Cyclone")
	end
end