bloodstained__modifier_bloodstained = class({})

function bloodstained__modifier_bloodstained:IsHidden() return true end
function bloodstained__modifier_bloodstained:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained__modifier_bloodstained:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self.steal = true

    self.target_mod = AddModifier(self.parent, self.ability, "bloodstained__modifier_bloodloss", {
      hp_stolen = kv.hp_stolen
    }, false)

    self.caster_mod = AddModifier(self.caster, self.ability, "bloodstained__modifier_bloodgain", {
      hp_stolen = 0
    }, false)

    self:PlayEfxStart()
  end
end

function bloodstained__modifier_bloodstained:OnRefresh(kv)
  if IsServer() then
    self.target_mod:SetStackCount(kv.hp_stolen)
  end
end

function bloodstained__modifier_bloodstained:OnRemoved()
  if IsServer() then
    if self.steal == true then
      self.target_mod:SetDuration(self.ability:GetSpecialValueFor("steal_duration"), true)
      self.caster_mod:SetDuration(self.ability:GetSpecialValueFor("steal_duration"), true)
      self.caster_mod:SetStackCount(self.target_mod:GetStackCount())
    else
      self.target_mod:Destroy()
      self.caster_mod:Destroy()
    end
  end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained__modifier_bloodstained:PlayEfxStart()
	local string = "particles/bloodstained/bloodstained_u_track1.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(particle, 3, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
  self:AddParticle(particle, false, false, -1, false, true)

	if IsServer() then self.parent:EmitSound("Hero_LifeStealer.OpenWounds") end
end