doom = class({})
LinkLuaModifier("doom_modifier", "neutrals/doom_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("doom_modifier_status_efx", "neutrals/doom_modifier_status_efx", LUA_MODIFIER_MOTION_NONE)

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

    if target then
        if IsValidEntity(target) then
            if IsServer() then self:PlayEfxStart(target) end
            target:AddNewModifier(caster, self, "doom_modifier", {
                duration = CalcStatus(duration, caster, target)
            })
        end
    end
end

function doom:PlayEfxStart(target)
	local string_1 = "particles/items_fx/abyssal_blink_start.vpcf"
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_1, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle_1)

    if IsServer() then target:EmitSound("Hero_DoomBringer.InfernalBlade.Target") end
end