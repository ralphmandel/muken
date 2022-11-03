venom_aoe = class({})
LinkLuaModifier( "venom_aoe_modifier", "neutrals/venom_aoe_modifier", LUA_MODIFIER_MOTION_NONE )

function venom_aoe:CalcStatus(duration, caster, target)
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

function venom_aoe:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function venom_aoe:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

function venom_aoe:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function venom_aoe:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")

    CreateModifierThinker(caster, self, "venom_aoe_modifier", {duration = duration}, point, caster:GetTeamNumber(), false)
end

function venom_aoe:OnOwnerDied()
	local caster = self:GetCaster()

	local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
	for _,thinker in pairs(thinkers) do
		if thinker:GetOwner() == caster and thinker:HasModifier("venom_aoe_modifier") then
			thinker:RemoveModifierByName("venom_aoe_modifier")
			--thinker:Kill(self, nil)
		end
	end
end