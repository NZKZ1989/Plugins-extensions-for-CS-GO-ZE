#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
    name = "[CS:GO] TOP DEFENDERS and INFECTORS",
    author = "NZ",
    version = "1.1"
};

int g_iTopDmg[MAXPLAYERS+1][2];
int g_iTopInfect[MAXPLAYERS+1][2];
int g_iTopMax = 3;

int g_iTopDefenders[3];

public void OnPluginStart()
{
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("player_hurt", Event_PlayerHurt);
    HookEvent("player_death", Event_PlayerDeath);
}

void OSTopClear()
{
    for(int i = 1; i <= MaxClients; ++i) {
        g_iTopDmg[i][0] = g_iTopInfect[i][0] = 0;
        g_iTopDmg[i][1] = g_iTopInfect[i][1] = 0;
    }
}

public void Event_RoundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    OSTopClear();

    for (int k = 0; k < 3; k++)
    {
        if (g_iTopDefenders[k] > 0 && IsClientInGame(g_iTopDefenders[k]))
        {
            CreateTimer(5.0, Timer_GiveExtraHE, g_iTopDefenders[k]);
        }
    }
}

public Action Timer_GiveExtraHE(Handle timer, any client)
{
    if(IsClientInGame(client) && IsPlayerAlive(client))
    {
        int ammoOffset = FindSendPropInfo("CCSPlayer", "m_iAmmo");
        int currentAmmo = GetEntData(client, ammoOffset + (14 * 4));
        SetEntData(client, ammoOffset + (14 * 4), currentAmmo + 1, 4, true);
    }
    return Plugin_Stop;
}

public void Event_RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    OSTopShow();

    for (int k = 0; k < 3; k++)
        g_iTopDefenders[k] = -1;

    int idx = 0;
    for (int i = MaxClients; i > MaxClients - g_iTopMax && idx < 3; --i)
    {
        if (g_iTopDmg[i][0] > 0 && IsClientInGame(g_iTopDmg[i][0]))
        {
            g_iTopDefenders[idx++] = g_iTopDmg[i][0];
        }
    }
}

public void Event_PlayerHurt(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    int iAttacker = GetClientOfUserId(hEvent.GetInt("attacker"));

    if(0 < iAttacker && iAttacker <= MaxClients)
    {
        g_iTopDmg[iAttacker][0] = iAttacker;
        g_iTopDmg[iAttacker][1] += hEvent.GetInt("dmg_health");
    }
}

public void Event_PlayerDeath(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    int iVictim = GetClientOfUserId(hEvent.GetInt("userid"));
    int iAttacker = GetClientOfUserId(hEvent.GetInt("attacker"));

    if(0 < iAttacker && iAttacker <= MaxClients && 0 < iVictim && iVictim <= MaxClients)
    {
        if(GetClientTeam(iAttacker) == 2 && GetClientTeam(iVictim) == 3)
        {
            g_iTopInfect[iAttacker][0] = iAttacker;
            ++g_iTopInfect[iAttacker][1];
        }
    }
}

void OSTopShow()
{
    OSTopForming();

    int iTopNum;
    char sBuffer[256];

    // --- TOP DEFENDERS ---
    SetHudTextParams(0.0, 0.35, 15.0, 0, 0, 255, 255, 0, 1.0, 1.0, 1.0);
    Format(sBuffer, sizeof(sBuffer), "TOP DEFENDERS\n====================\n");
    for(int i = MaxClients; i > MaxClients - g_iTopMax; --i)
    {
        if(g_iTopDmg[i][0] > 0 && IsClientInGame(g_iTopDmg[i][0]))
        {
            ++iTopNum;
            Format(sBuffer, sizeof(sBuffer), "%s#%i %N - %i DMG\n", sBuffer, iTopNum, g_iTopDmg[i][0], g_iTopDmg[i][1]);
        }
    }
    Format(sBuffer, sizeof(sBuffer), "%s====================", sBuffer);
    for(int iClient = 1; iClient <= MaxClients; ++iClient) {
        if(IsClientInGame(iClient)) ShowHudText(iClient, 1, "%s", sBuffer);
    }

    // --- TOP INFECTORS ---
    iTopNum = 0;
    sBuffer[0] = '\0';

    SetHudTextParams(0.0, 0.55, 15.0, 255, 0, 0, 255, 0, 1.0, 1.0, 1.0);
    Format(sBuffer, sizeof(sBuffer), "TOP INFECTORS\n====================\n");
    for(int i = MaxClients; i > MaxClients - g_iTopMax; --i)
    {
        if(g_iTopInfect[i][0] > 0 && IsClientInGame(g_iTopInfect[i][0]))
        {
            ++iTopNum;
            Format(sBuffer, sizeof(sBuffer), "%s#%i %N - %i INFECTED\n", sBuffer, iTopNum, g_iTopInfect[i][0], g_iTopInfect[i][1]);
        }
    }
    Format(sBuffer, sizeof(sBuffer), "%s====================", sBuffer);
    for(int iClient = 1; iClient <= MaxClients; ++iClient) {
        if(IsClientInGame(iClient)) ShowHudText(iClient, 2, "%s", sBuffer);
    }
}

void OSTopForming()
{
    for(int i = 1; i <= MaxClients; ++i)
    {
        for(int j = 1; j < MaxClients; ++j)
        {
            if(g_iTopDmg[j][1] > g_iTopDmg[j+1][1])
                OnDistribution(j);

            if(g_iTopInfect[j][1] > g_iTopInfect[j+1][1])
                OnDistribution2(j);
        }
    }
}

void OnDistribution(int j)
{
    int iIndex = g_iTopDmg[j][0];
    int iDmg = g_iTopDmg[j][1];
    g_iTopDmg[j][0] = g_iTopDmg[j+1][0];
    g_iTopDmg[j][1] = g_iTopDmg[j+1][1];
    g_iTopDmg[j+1][0] = iIndex;
    g_iTopDmg[j+1][1] = iDmg;
}

void OnDistribution2(int j)
{
    int iIndex = g_iTopInfect[j][0];
    int iInfect = g_iTopInfect[j][1];
    g_iTopInfect[j][0] = g_iTopInfect[j+1][0];
    g_iTopInfect[j][1] = g_iTopInfect[j+1][1];
    g_iTopInfect[j+1][0] = iIndex;
    g_iTopInfect[j+1][1] = iInfect;
}
