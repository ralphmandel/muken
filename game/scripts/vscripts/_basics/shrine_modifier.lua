shrine_modifier = class({})

function shrine_modifier:IsHidden() return true end
function shrine_modifier:IsPurgable() return false end

function shrine_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.available = false
  self.delay = true

	if IsServer() then
    self:StartIntervalThink(5)
  end
end

function shrine_modifier:OnRefresh( kv )
end

function shrine_modifier:OnRemoved()
end

--------------------------------------------------------------------------------------------------------------------------

function shrine_modifier:OnIntervalThink()
  local filler = self.parent:FindAbilityByName("filler_ability")

  if self.delay == true and filler then
    filler:EndCooldown()
    filler:StartCooldown(30)
    self.delay = false
  end

  if filler then
    if self.available == true then
      if filler:IsCooldownReady() == false then
        if self.fow then
          for team, fow in pairs(self.fow) do
            RemoveFOWViewer(team, fow)
          end
        end
        self.fow = nil
        self.available = false
      end
    else
      if filler:IsCooldownReady() == true then
        self.fow = {
          [DOTA_TEAM_CUSTOM_1] = AddFOWViewer(DOTA_TEAM_CUSTOM_1, self.parent:GetOrigin(), 200, 9999, false),
          [DOTA_TEAM_CUSTOM_2] = AddFOWViewer(DOTA_TEAM_CUSTOM_2, self.parent:GetOrigin(), 200, 9999, false),
          [DOTA_TEAM_CUSTOM_3] = AddFOWViewer(DOTA_TEAM_CUSTOM_3, self.parent:GetOrigin(), 200, 9999, false),
          [DOTA_TEAM_CUSTOM_4] = AddFOWViewer(DOTA_TEAM_CUSTOM_4, self.parent:GetOrigin(), 200, 9999, false)
        }
        self.available = true
      end
    end    
  end
  
  if IsServer() then self:StartIntervalThink(0.5) end
end

--------------------------------------------------------------------------------------------------------------------------

function shrine_modifier:PlayEfxRecovery()
	local particle_cast = "particles/world_shrine/radiant_shrine_active.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end