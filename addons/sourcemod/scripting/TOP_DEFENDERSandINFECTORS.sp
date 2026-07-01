#pragma semicolon 1
#pragma newdecls required

#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <zombiereloaded>

public Plugin myinfo =
{
    name = "[CS:GO] TOP DEFENDERS and INFECTORS",
    author = "NZ",
    version = "2.1"
};

int g_iDamage[MAXPLAYERS+1];
int g_iInfect[MAXPLAYERS+1];
int g_iTopDefenders[3];
int g_iTopMax = 3;

public void OnPluginStart()
{
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("player_hurt", Event_PlayerHurt);
}

public void OnMapStart()
{
    ResetStats();
}

void ResetStats()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iDamage[i] = 0;
        g_iInfect[i] = 0;
    }
    for (int k = 0; k < g_iTopMax; k++)
        g_iTopDefenders[k] = -1;
}

public void Event_RoundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    ResetStats();

    for (int k = 0; k < g_iTopMax; k++)
    {
        int client = g_iTopDefenders[k];
        if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
        {
            CreateTimer(5.0, Timer_GiveExtraHE, client, TIMER_FLAG_NO_MAPCHANGE);
        }
    }
}

public Action Timer_GiveExtraHE(Handle timer, any client)
{
    if(IsClientInGame(client) && IsPlayerAlive(client))
    {
        GivePlayerItem(client, "weapon_hegrenade");
    }
    return Plugin_Stop;
}

public void Event_RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    ShowTopStats();

    int sorted[MAXPLAYERS+1];
    int count = 0;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && g_iDamage[i] > 0)
            sorted[count++] = i;
    }

    SortCustom1D(sorted, count, SortByDamage);

    for (int k = 0; k < g_iTopMax && k < count; k++)
        g_iTopDefenders[k] = sorted[k];
}

public int SortByDamage(int elem1, int elem2, const int[] array, Handle hndl)
{
    return g_iDamage[elem2] - g_iDamage[elem1];
}

public void Event_PlayerHurt(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    int victim   = GetClientOfUserId(hEvent.GetInt("userid"));
    int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));

    if (attacker > 0 && attacker <= MaxClients && victim > 0 && victim <= MaxClients)
    {
        if (GetClientTeam(attacker) == CS_TEAM_CT && GetClientTeam(victim) == CS_TEAM_T)
        {
            g_iDamage[attacker] += hEvent.GetInt("dmg_health");
        }
    }
}

public Action ZR_OnClientInfect(int &client, int &attacker, bool &motherinfect, bool &respawnoverride, bool &respawn)
{
    if (attacker > 0 && IsClientInGame(attacker))
    {
        g_iInfect[attacker]++;
    }
    return Plugin_Continue;
}

void ShowTopStats()
{
    char buffer[256];

    // --- TOP DEFENDERS ---
    SetHudTextParams(0.0, 0.35, 10.0, 0, 0, 255, 255);
    Format(buffer, sizeof(buffer), "TOP DEFENDERS\n====================\n");

    int sorted[MAXPLAYERS+1];
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && g_iDamage[i] > 0)
            sorted[count++] = i;

    SortCustom1D(sorted, count, SortByDamage);

    for (int k = 0; k < g_iTopMax && k < count; k++)
        Format(buffer, sizeof(buffer), "%s#%d %N - %d DMG\n", buffer, k+1, sorted[k], g_iDamage[sorted[k]]);

    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i)) ShowHudText(i, 1, "%s", buffer);

    // --- TOP INFECTORS ---
    SetHudTextParams(0.0, 0.55, 10.0, 255, 0, 0, 255);
    buffer[0] = '\0';
    Format(buffer, sizeof(buffer), "TOP INFECTORS\n====================\n");

    count = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && g_iInfect[i] > 0)
            sorted[count++] = i;

    SortCustom1D(sorted, count, SortByInfect);

    for (int k = 0; k < g_iTopMax && k < count; k++)
        Format(buffer, sizeof(buffer), "%s#%d %N - %d INFECTED\n", buffer, k+1, sorted[k], g_iInfect[sorted[k]]);

    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i)) ShowHudText(i, 2, "%s", buffer);
}

public int SortByInfect(int elem1, int elem2, const int[] array, Handle hndl)
{
    return g_iInfect[elem2] - g_iInfect[elem1];
}
