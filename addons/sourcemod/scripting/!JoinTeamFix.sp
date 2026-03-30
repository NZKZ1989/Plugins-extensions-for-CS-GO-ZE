#include <sourcemod>
#include <sdktools>
#include <cstrike>

// Code by Dr!fter + правка для отключения меню выбора команды
public OnPluginStart()
{
    // Включаем режим "как будто матчмейкинг"
    GameRules_SetProp("m_bIsQueuedMatchmaking", 1);

    AddCommandListener(JoinTeam, "jointeam");
    HookEvent("teamchange_pending", TeamChangePending, EventHookMode_Pre);
}

public Action TeamChangePending(Handle event, const char[] name, bool bDontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    int team = GetEventInt(event, "toteam");
    SetEntProp(client, Prop_Send, "m_iTeam", team);
    return Plugin_Continue;
}

public Action JoinTeam(int client, const char[] command, int args)
{
    // Вместо вызова меню joinclass можно сразу назначать класс/команду
    ChangeClientTeam(client, CS_TEAM_CT);
    return Plugin_Handled; // блокируем стандартное меню
}
