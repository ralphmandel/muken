shrine_modifier = class({})

function shrine_modifier:IsHidden() return true end
function shrine_modifier:IsPurgable() return false end

function shrine_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.name = string.sub(self.caster:GetName(), 1, -3)

  if IsServer() then self:StartIntervalThink(1) end
end

function shrine_modifier:OnRefresh( kv )
end

function shrine_modifier:OnRemoved()
end

  -- hp_heal
  -- mp_heal
  -- hp_heal_pct
  -- mp_heal_pct
  -- hp_heal_growth
  -- mp_heal_growth
  -- duration

--------------------------------------------------------------------------------------------------------------------------

function shrine_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
    MODIFIER_EVENT_ON_MODIFIER_ADDED
	}

	return funcs
end

function shrine_modifier:GetModifierOverrideAbilitySpecial(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level

	if ability:GetAbilityName() == "filler_ability" then
    if self.name == "hp_filler" then
      if value_name == "AbilityCooldown" then return 1 end
      if value_name == "duration" then return 1 end
      if value_name == "mp_heal" then return 1 end
      if value_name == "mp_heal_pct" then return 1 end
      if value_name == "mp_heal_growth" then return 1 end
      if value_name == "hp_heal" then return 1 end
      if value_name == "hp_heal_pct" then return 1 end
    end
    if self.name == "mp_filler" then
      if value_name == "AbilityCooldown" then return 1 end
      if value_name == "duration" then return 1 end
      if value_name == "hp_heal" then return 1 end
      if value_name == "hp_heal_pct" then return 1 end
      if value_name == "hp_heal_growth" then return 1 end
      if value_name == "mp_heal" then return 1 end
      if value_name == "mp_heal_pct" then return 1 end
    end
	end

	return 0
end

function shrine_modifier:GetModifierOverrideAbilitySpecialValue(keys)
	local caster = self:GetCaster()
	local ability = keys.ability
	local value_name = keys.ability_special_value
	local value_level = keys.ability_special_level
	local ability_level = ability:GetLevel()
	if ability_level < 1 then ability_level = 1 end

	if ability:GetAbilityName() == "filler_ability" then
    if self.name == "hp_filler" then
      if value_name == "AbilityCooldown" then return 120 end
      if value_name == "duration" then return 4 end
      if value_name == "mp_heal" then return 0 end
      if value_name == "mp_heal_pct" then return 0 end
      if value_name == "mp_heal_growth" then return 0 end
      if value_name == "hp_heal" then return 250 end
      if value_name == "hp_heal_pct" then return 5 end
    end
    if self.name == "mp_filler" then
      if value_name == "AbilityCooldown" then return 150 end
      if value_name == "duration" then return 4 end
      if value_name == "hp_heal" then return 0 end
      if value_name == "hp_heal_pct" then return 0 end
      if value_name == "hp_heal_growth" then return 0 end
      if value_name == "mp_heal" then return 50 end
      if value_name == "mp_heal_pct" then return 5 end
    end
	end

	return 0
end

function shrine_modifier:OnModifierAdded(keys)
  if not IsServer() then return end

  if keys.added_buff:GetName() == "modifier_filler_buff_icon" and keys.added_buff:GetCaster() == self.parent then
    self:SetFow(true)
  end

  if keys.added_buff:GetName() == "modifier_filler_heal" and keys.added_buff:GetCaster() == self.parent then
    if self.name == "hp_filler" then self:ActivateHP(keys.added_buff) end
    if self.name == "mp_filler" then self:ActiveteMP(keys.added_buff) end
  end
end

function shrine_modifier:OnIntervalThink()
  local filler = self.parent:FindAbilityByName("filler_ability")

  filler:EndCooldown()

  if self.name == "hp_filler" then filler:StartCooldown(PRE_GAME_TIME) end
  if self.name == "mp_filler" then filler:StartCooldown(PRE_GAME_TIME + 30) end

  if IsServer() then self:StartIntervalThink(-1) end
end

--------------------------------------------------------------------------------------------------------------------------

function shrine_modifier:ActivateHP(mod)
  if mod:GetParent():GetHealthPercent() > 50 then
    Timers:CreateTimer(FrameTime(), function()
      if IsServer() then self.parent:StopSound("Shrine.Cast") end
    end)

    local filler = self.parent:FindAbilityByName("filler_ability")
    filler:EndCooldown()
    filler:StartCooldown(1)
    mod:Destroy()
    return
  end

  if IsServer() then self:PlayEfxHP(mod) end
end

function shrine_modifier:ActiveteMP(mod)
  if mod:GetParent():GetManaPercent() > 50
  or mod:GetParent():HasModifier("ancient_1_modifier_passive") then
    Timers:CreateTimer(FrameTime(), function()
      if IsServer() then self.parent:StopSound("Shrine.Cast") end
    end)

    local filler = self.parent:FindAbilityByName("filler_ability")
    filler:EndCooldown()
    filler:StartCooldown(1)
    mod:Destroy()
    return
  end

  if IsServer() then self:PlayEfxMP(mod) end
end

function shrine_modifier:PlayEfxHP(mod)
  local string = "particles/world_shrine/dire_shrine_regen.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, mod:GetParent())
	mod:AddParticle(particle, false, false, -1, false, false)

	local particle_cast = "particles/world_shrine/dire_shrine_active.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

  self:SetFow(false)
end

function shrine_modifier:PlayEfxMP(mod)
  local string = "particles/world_shrine/radiant_shrine_regen.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, mod:GetParent())
	mod:AddParticle(particle, false, false, -1, false, false)

	local particle_cast = "particles/world_shrine/radiant_shrine_active.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

  self:SetFow(false)
end

function shrine_modifier:SetFow(bEnabled)
  if bEnabled == true then
    self.fow = {
      [DOTA_TEAM_CUSTOM_1] = AddFOWViewer(DOTA_TEAM_CUSTOM_1, self.parent:GetOrigin(), 200, 9999, false),
      [DOTA_TEAM_CUSTOM_2] = AddFOWViewer(DOTA_TEAM_CUSTOM_2, self.parent:GetOrigin(), 200, 9999, false),
      [DOTA_TEAM_CUSTOM_3] = AddFOWViewer(DOTA_TEAM_CUSTOM_3, self.parent:GetOrigin(), 200, 9999, false),
      [DOTA_TEAM_CUSTOM_4] = AddFOWViewer(DOTA_TEAM_CUSTOM_4, self.parent:GetOrigin(), 200, 9999, false)
    }
  else
    if self.fow then
      for team, fow in pairs(self.fow) do
        RemoveFOWViewer(team, fow)
      end
    end
    self.fow = nil
  end
end