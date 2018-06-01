local wtfBrist = {}

wtfBrist.IsEnable = Menu.AddOptionBool({"Hero Specific", "WTF+ Bristleback"}, "Enable", false)
wtfBrist.SprayKey = Menu.AddKeyOption({"Hero Specific", "WTF+ Bristleback"}, "Spray Key", Enum.ButtonCode.KEY_1);
wtfBrist.Debug = false

wtfBrist.LastUpdateTime = 0
wtfBrist.UpdateTime = 0.0

function wtfBrist.OnUpdate()
    if not Menu.IsEnabled(wtfBrist.IsEnable) or not Engine.IsInGame() or not Heroes.GetLocal() then return end

    if ((os.clock() - wtfBrist.LastUpdateTime) < wtfBrist.UpdateTime) then
        return
    end
    wtfBrist.LastUpdateTime = os.clock();

    wtfBrist.MyHero = Heroes.GetLocal()
    if NPC.GetUnitName(wtfBrist.MyHero) ~= "npc_dota_hero_bristleback" then return end
    if not Entity.IsAlive(wtfBrist.MyHero) or NPC.IsStunned(wtfBrist.MyHero) or NPC.IsSilenced(wtfBrist.MyHero) then return end

    local quillSpray = NPC.GetAbility(wtfBrist.MyHero, "bristleback_quill_spray")
    if not quillSpray then return end

    local quillSprayCastRange = Ability.GetCastRange(quillSpray)

    local Units = Entity.GetUnitsInRadius(wtfBrist.MyHero, quillSprayCastRange, Enum.TeamType.TEAM_ENEMY)
    if not Units then return end

    if not NPC.IsVisibleToEnemies(wtfBrist.MyHero) and not Menu.IsKeyDown(wtfBrist.SprayKey) then
        return
    end

    for i, unit in pairs(Units) do
        if unit ~= nil and unit ~= 0 and NPCs.Contains(unit) and NPC.IsEntityInRange(wtfBrist.MyHero, unit, quillSprayCastRange) then
            if not Entity.IsSameTeam(unit, wtfBrist.MyHero) and not NPC.IsStructure(unit) and NPC.GetUnitName(unit) ~= "npc_dota_neutral_caster" then
                if Entity.IsAlive(unit) and not NPC.IsWaitingToSpawn(unit) and not Entity.IsDormant(unit) and Ability.IsReady(quillSpray) then
                    if NPC.IsCreep(unit) or NPC.IsIllusion(unit) or NPC.IsHero(unit) or NPC.IsCourier(unit) then
                        if wtfBrist.Debug then Log.Write("Attack! [".. NPC.GetUnitName(unit) .."]") end
                        Ability.CastNoTarget(quillSpray)
                        break
                    end
                end
            end
        end
    end
end

return wtfBrist
