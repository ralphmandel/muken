paladin_1_modifier_link = class({})

function paladin_1_modifier_link:IsHidden() return false end
function paladin_1_modifier_link:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_1_modifier_link:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.cast_range = self.ability:GetSpecialValueFor("cast_range")
  self.max_range = self.ability:GetSpecialValueFor("max_range")

  if IsServer() then
    self:PlayEfxStart()
    self:OnIntervalThink()
  end
end

function paladin_1_modifier_link:OnRefresh(kv)
end

function paladin_1_modifier_link:OnRemoved()
  if IsServer() then
    self.caster:StopSound("Hero_Wisp.Tether")
    self.caster:EmitSound("Hero_Wisp.Tether.Stop")
  end
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_1_modifier_link:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function paladin_1_modifier_link:OnDeath(keys)
  if keys.unit == self.caster then self:Destroy() end
end

function paladin_1_modifier_link:GetModifierIncomingDamage_Percentage(keys)
  return -self.ability:GetSpecialValueFor("absorption")
end

function paladin_1_modifier_link:OnTakeDamage(keys)
  if keys.unit ~= self.parent then return end
  local mult = (100 / (100 - self.ability:GetSpecialValueFor("absorption"))) - 1
  
  local damageTable = {
    victim = self.caster, attacker = keys.attacker, damage = keys.damage * mult,
    damage_type = keys.damage_type, ability = keys.inflictor,
    damage_flags = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR
    + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_REFLECTION
  }

  --if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		local total = ApplyDamage(damageTable)
    --print("kubo", total)
	--end
end

function paladin_1_modifier_link:OnIntervalThink()
  if CalcDistanceBetweenEntityOBB(self.caster, self.parent) > self.max_range then
    self:Destroy()
    return
  end

  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function paladin_1_modifier_link:PlayEfxStart()
  local string = "particles/paladin/link/paladin_link.vpcf"
  self.pfx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControlEnt(self.pfx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(self.pfx, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
  ParticleManager:SetParticleControl(self.pfx, 3, Vector(self.cast_range, self.max_range, 0))
  self:AddParticle(self.pfx, false, false, -1, false, false)

  if IsServer() then
    self.caster:EmitSound("Hero_Wisp.Tether")
    self.parent:EmitSound("Hero_Wisp.Tether.Target")
  end
end