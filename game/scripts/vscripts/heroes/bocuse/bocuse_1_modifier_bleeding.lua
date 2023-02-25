bocuse_1_modifier_bleeding = class({})

function bocuse_1_modifier_bleeding:IsHidden() return false end
function bocuse_1_modifier_bleeding:IsPurgable() return true end
function bocuse_1_modifier_bleeding:GetTexture() return "bleeding" end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_1_modifier_bleeding:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.intervals = 0.3
	local bleeding_damage = self.ability:GetSpecialValueFor("bleeding_damage") * self.intervals

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = bleeding_damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_HPLOSS,
		ability = self.ability
	}

	if IsServer() then
		self:StartIntervalThink(self.intervals)
		self:PlayEfxStart()
	end
end

function bocuse_1_modifier_bleeding:OnRefresh(kv)
	if IsServer() then self:PlayEfxStart() end
end

function bocuse_1_modifier_bleeding:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_1_modifier_bleeding:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING
	}

	return funcs
end

function bocuse_1_modifier_bleeding:GetDisableHealing()
	return 1
end

function bocuse_1_modifier_bleeding:OnIntervalThink()
	if IsServer() then
		--if self.parent:IsMoving() then
		--end

		local apply_damage = math.floor(ApplyDamage(self.damageTable))
		if apply_damage > 0 then
			if self.parent then
				if IsValidEntity(self.parent) then
					self:PopupBleeding(apply_damage)				
				end
			end
		end

		self:StartIntervalThink(self.intervals)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bocuse_1_modifier_bleeding:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf"
end

function bocuse_1_modifier_bleeding:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bocuse_1_modifier_bleeding:PopupBleeding(amount)
  local digits = 1 + #tostring(amount)
	local pidx = ParticleManager:CreateParticle("particles/bocuse/bocuse_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(pidx, 3, Vector(0, tonumber(amount), 3))
  ParticleManager:SetParticleControl(pidx, 4, Vector(1, digits, 0))
end

function bocuse_1_modifier_bleeding:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	local particle_cast2 = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf"
	local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast2, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast2, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast2)

	if IsServer() then self.parent:EmitSound("Generic.Bleed") end
end