#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
    name        = "Auto ZSpawn (Improved)",
    author      = "Franc1sco franug, NZ",
    description = "Автоматически вызывает zspawn с задержкой и повторной попыткой.",
    version     = "1.1",
    url         = ""
};

public void OnPluginStart()
{
    HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Post);
}

public Action Event_OnPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!client || !IsClientInGame(client))
    {
        return Plugin_Continue;
    }

    if (!IsPlayerAlive(client))
    {
        CreateTimer(2.0, Timer_ZSpawn, GetClientUserId(client));
    }

    return Plugin_Continue;
}

public Action Timer_ZSpawn(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (!client || !IsClientInGame(client))
    {
        return Plugin_Stop;
    }

    int team = GetClientTeam(client);
    if (team <= 1)
    {
        return Plugin_Stop;
    }

    if (IsPlayerAlive(client))
    {
        return Plugin_Stop;
    }

    ClientCommand(client, "zspawn");

    CreateTimer(2.0, Timer_ZSpawnRetry, GetClientUserId(client));

    return Plugin_Stop;
}

public Action Timer_ZSpawnRetry(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (!client || !IsClientInGame(client))
    {
        return Plugin_Stop;
    }

    int team = GetClientTeam(client);
    if (team <= 1)
    {
        return Plugin_Stop;
    }

    if (IsPlayerAlive(client))
    {
        return Plugin_Stop;
    }

    ClientCommand(client, "zspawn");

    return Plugin_Stop;
}
