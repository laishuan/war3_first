//TESH.scrollpos=9
//TESH.alwaysfold=0
function Trig_Melee_InitializationFunc004002 takes nothing returns nothing
    call AdjustPlayerStateBJ(500, GetEnumPlayer(), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Melee_InitializationFunc006002 takes nothing returns nothing
    call CreateFogModifierRectBJ(true, GetEnumPlayer(), FOG_OF_WAR_VISIBLE, GetPlayableMapRect())
endfunction

function Trig_Melee_InitializationActions takes nothing returns nothing
    set udg_Money = 3
    set udg_Extra_money = 4
    call ForForce(GetPlayersAll(), function Trig_Melee_InitializationFunc004002)
    set udg_Negative_money = -1
    call ForForce(GetPlayersAll(), function Trig_Melee_InitializationFunc006002)
    call TriggerSleepAction(0.01)
    call CreateTimerDialogBJ(udg_Timer, "TRIGSTR_001")
    call StartTimerBJ(udg_Timer, false, 30)
    set udg_Timer = GetLastCreatedTimerBJ()
    call CreateLeaderboardBJ(GetPlayersAll(), "TRIGSTR_002")
    call LeaderboardAddItemBJ(Player(0), GetLastCreatedLeaderboard(), GetPlayerName(Player(0)), udg_Points_1)
    call LeaderboardAddItemBJ(Player(1), GetLastCreatedLeaderboard(), GetPlayerName(Player(1)), udg_Points_2)
    call LeaderboardAddItemBJ(Player(2), GetLastCreatedLeaderboard(), GetPlayerName(Player(2)), udg_Points_3)
    call LeaderboardAddItemBJ(Player(3), GetLastCreatedLeaderboard(), GetPlayerName(Player(3)), udg_Points_4)
    call LeaderboardAddItemBJ(Player(4), GetLastCreatedLeaderboard(), GetPlayerName(Player(4)), udg_Points_5)
    call LeaderboardAddItemBJ(Player(8), GetLastCreatedLeaderboard(), GetPlayerName(Player(8)), udg_Points_6)
    set udg_Lives = 30
    call LeaderboardAddItemBJ(Player(7), GetLastCreatedLeaderboard(), "TRIGSTR_003", udg_Lives)
    call CameraSetupApplyForPlayer(true, gg_cam_Camera_001, Player(0), 0)
    call CameraSetupApplyForPlayer(true, gg_cam_Camera_001, Player(1), 0)
    call CameraSetupApplyForPlayer(true, gg_cam_Camera_001, Player(2), 0)
    call CameraSetupApplyForPlayer(true, gg_cam_Camera_001, Player(3), 0)
    call CameraSetupApplyForPlayer(true, gg_cam_Camera_001, Player(4), 0)
    call CameraSetupApplyForPlayer(true, gg_cam_Camera_001, Player(8), 0)
    call CreateQuestBJ(bj_QUESTTYPE_REQ_DISCOVERED, "TRIGSTR_004", "TRIGSTR_005", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp")
    call CreateQuestBJ(bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_006", "TRIGSTR_007", "ReplaceableTextures\\CommandButtons\\BTNSlow.blp")
    call CreateQuestBJ(bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_008", "TRIGSTR_009", "ReplaceableTextures\\CommandButtons\\BTNSlow.blp")
    call Cheat("exec-lua: \"runtime_init\"")
    call Cheat("exec-lua: \"main\"")
endfunction

//===========================================================================
function InitTrig_Melee_Initialization takes nothing returns nothing
    set gg_trg_Melee_Initialization = CreateTrigger()
#ifdef DEBUG
    call YDWESaveTriggerName(gg_trg_Melee_Initialization, "Melee Initialization")
#endif
    call TriggerAddAction(gg_trg_Melee_Initialization, function Trig_Melee_InitializationActions)
endfunction

