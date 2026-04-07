#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <zombiereloaded>

public Plugin myinfo = {
    name        = "zr_fix_inferno",
    author      = "AgentWesker, Jeremiah Jackson, Acik, NZ",
    description = "Slows zombies while they are burning",
    version     = "1.1",
    url         = ""
};

float g_fNormalSpeed[MAXPLAYERS + 1];
bool g_bInferno[MAXPLAYERS + 1];

public void OnPluginStart()
{
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("player_hurt", Event_PlayerHurt);
    HookEvent("player_spawn", Event_PlayerSpawn);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            OnClientPutInServer(i);
        }
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_fNormalSpeed[i] = 0.0;
        g_bInferno[i] = false;
    }
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client))
    {
        CreateTimer(1.0, Timer_SaveSpeed, client);
    }
}

public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    int client   = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    if (!IsValidClient(client) || !IsValidClient(attacker)) return;
    if (client == attacker) return;
    if (ZR_IsClientZombie(attacker)) return;

    char weapon[64];
    event.GetString("weapon", weapon, sizeof(weapon));

    if (StrEqual(weapon, "hegrenade", false) || StrEqual(weapon, "inferno", false))
    {
        if (ZR_IsClientZombie(client))
        {
            ApplyInfernoSlow(client);
        }
    }
}

public void OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
    if (!IsValidClient(victim) || !IsPlayerAlive(victim)) return;

    if (!(damagetype & DMG_BURN)) return;

    if (!ZR_IsClientZombie(victim)) return;

    int effect = GetEntPropEnt(victim, Prop_Data, "m_hEffectEntity");
    if (effect == -1) return;

    ApplyInfernoSlow(victim);
}

void ApplyInfernoSlow(int client)
{
    if (!g_bInferno[client])
    {
        float speed = GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue");
        if (g_fNormalSpeed[client] < 0.1)
        {
            g_fNormalSpeed[client] = speed;
        }

        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed / 3.0);

        CreateTimer(1.0, Timer_CheckInferno, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }

    g_bInferno[client] = true;
}

public Action Timer_SaveSpeed(Handle timer, any client)
{
    if (IsValidClient(client) && IsPlayerAlive(client))
    {
        g_fNormalSpeed[client] = GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue");
    }
    return Plugin_Stop;
}

public Action Timer_CheckInferno(Handle timer, any client)
{
    if (!IsValidClient(client)) return Plugin_Stop;

    int effect = GetEntPropEnt(client, Prop_Data, "m_hEffectEntity");
    if (effect == -1 || !IsPlayerAlive(client))
    {
        if (g_bInferno[client])
        {
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", g_fNormalSpeed[client]);
            g_bInferno[client] = false;
        }
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}
