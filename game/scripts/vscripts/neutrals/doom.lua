doom = class({})
LinkLuaModifier("doom_modifier", "neutrals/doom_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("doom_modifier_status_efx", "neutrals/doom_modifier_status_efx", LUA_MODIFIER_MOTION_NONE)

function doom:CalcStatus(duration, caster, target)
    if caster == nil or target == nil then return duration end
    if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
    local base_stats = caster:FindAbilityByName("base_stats")

    if caster:GetTeamNumber() == target:GetTeamNumber() then
        if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
    else
        if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
        duration = duration * (1 - target:GetStatusResistance())
    end
    
    return duration
end

function doom:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function doom:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

function doom:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor( "duration" )

    if target:TriggerSpellAbsorb(self) then return end

    ApplyDamage({
        attacker = caster,
        victim = target,
        damage = self:GetAbilityDamage(),
        damage_type = self:GetAbilityDamageType(),
        ability = self
    })

    if target:IsAlive() then
        target:AddNewModifier(caster, self, "doom_modifier", {
            duration = self:CalcStatus(duration, caster, target)
        })
    end

    if IsServer() then self:PlayEfxStart(target) end
end

function doom:PlayEfxStart(target)
	local string_1 = "particles/items_fx/abyssal_blink_start.vpcf"
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_1, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle_1)

    if IsServer() then target:EmitSound("Hero_DoomBringer.InfernalBlade.Target") end
end