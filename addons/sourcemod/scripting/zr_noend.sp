#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin myinfo =
{
    name        = "ZR Not Early End",
    author      = "Franc1sco steam: franug",
    description = "pos eso",
    version     = "1.0",
    url         = "www.servers-cfg.foroactivo.com"
};

bool noterminar;
ConVar tiempospawn;

bool HasAlivePlayers(int team)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
            return true;
    }
    return false;
}

public void OnPluginStart()
{
    CreateConVar("zr_NotEarlyEnd", "1.1 by Franc1sco steam: franug", "version", FCVAR_NOTIFY);

    HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
    HookEvent("round_start", Event_RoundStart, EventHookMode_Post);

    tiempospawn = FindConVar("zr_respawn");
}

public void OnMapStart()
{
    tiempospawn = FindConVar("zr_respawn");
}

public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    noterminar = false;

    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (!attacker)
        return Plugin_Continue;

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (GetClientTeam(client) != CS_TEAM_T)
        return Plugin_Continue;

    int terros = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T)
            terros++;
    }

    if (terros == 1)
        noterminar = true;

    return Plugin_Continue;
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
    if (tiempospawn != null 
        && tiempospawn.IntValue == 1 
        && noterminar 
        && reason == view_as<CSRoundEndReason>(7)
        && HasAlivePlayers(CS_TEAM_T))
    {
        return Plugin_Handled;
    }

    if (reason == view_as<CSRoundEndReason>(7) && HasAlivePlayers(CS_TEAM_T))
        return Plugin_Handled;

    if (reason == view_as<CSRoundEndReason>(8) && HasAlivePlayers(CS_TEAM_CT))
        return Plugin_Handled;

    return Plugin_Continue;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    noterminar = false;
    return Plugin_Continue;
}
