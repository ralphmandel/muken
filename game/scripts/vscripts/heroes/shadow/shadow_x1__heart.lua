shadow_x1__heart = class({})
LinkLuaModifier("shadow_x1_modifier_heart", "heroes/shadow/shadow_x1_modifier_heart", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadow_x1__heart:CalcStatus(duration, caster, target)
        local time = duration
        if caster == nil then return time end
        local caster_int = caster:FindModifierByName("_1_INT_modifier")
        local caster_mnd = caster:FindModifierByName("_2_MND_modifier")

        if target == nil then
            if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
        else
            if caster:GetTeamNumber() == target:GetTeamNumber() then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                local target_res = target:FindModifierByName("_2_RES_modifier")
                if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function shadow_x1__heart:AddBonus(string, target, const, percent, time)
		local att = target:FindAbilityByName(string)
		if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
	end

	function shadow_x1__heart:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

    function shadow_x1__heart:OnUpgrade()
        self:SetHidden(false)
    end

    function shadow_x1__heart:Spawn()
		self:SetCurrentAbilityCharges(0)
	end

-- SPELL START

    function shadow_x1__heart:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        local radius = self:GetSpecialValueFor("radius")

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(),	-- int, your team number
            caster:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            16,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(caster, self, "shadow_x1_modifier_heart", {
                duration = self:CalcStatus(duration, caster, enemy)
            })
        end

        self:PlayEfxStart()
    end

-- EFFECTS

    function shadow_x1__heart:PlayEfxStart()
        local caster = self:GetCaster()
        local particle_cast = "particles/bioshadow/bioshadow_knives.vpcf"

        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())
        if IsServer() then caster:EmitSound("Hero_PhantomAssassin.FanOfKnives.Cast") end
    end