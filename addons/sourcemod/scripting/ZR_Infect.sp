#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <clientprefs>
#include <zombiereloaded>

#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
    name        = "ZR Advanced Infect Effects",
    author      = "SenatoR (fixed by Copilot)",
    description = "Добавляет визуальные и аудио эффекты при заражении",
    version     = PLUGIN_VERSION,
    url         = ""
};

// ConVars
ConVar g_hInfectTime;
ConVar g_hInfectSound;
ConVar g_hInfectSpeed;

char g_sInfectSound[256];

// UserMessages
UserMsg g_umsgFade = INVALID_MESSAGE_ID;
UserMsg g_umsgShake = INVALID_MESSAGE_ID;

// Переменные состояния
Handle g_hInfectTimer[MAXPLAYERS+1];
int g_iInfectState[MAXPLAYERS+1]; // 0 = не заражён, 1 = заражается, 2 = завершил
int g_iInfectAttacker[MAXPLAYERS+1];

public void OnPluginStart()
{
    g_hInfectTime  = CreateConVar("zr_adv_infect_time", "5.0", "Время мутации игрока", FCVAR_NOTIFY);
    g_hInfectSound = CreateConVar("zr_adv_infect_sound", "zr/heartbeat4.wav", "Путь до звука заражения", FCVAR_NOTIFY);
    g_hInfectSpeed = CreateConVar("zr_adv_infect_speed", "0.6", "Скорость зараженного игрока", FCVAR_NOTIFY);

    AutoExecConfig(true, "zr_adv_infect");

    GetConVarString(g_hInfectSound, g_sInfectSound, sizeof(g_sInfectSound));
    HookConVarChange(g_hInfectSound, OnInfectSoundChanged);

    HookEvent("round_end", Event_RoundEnd);

    g_umsgFade  = GetUserMessageId("Fade");
    if (g_umsgFade == INVALID_MESSAGE_ID)
    {
        LogError("Эта игра не поддерживает затухание!");
    }

    g_umsgShake = GetUserMessageId("Shake");
    if (g_umsgShake == INVALID_MESSAGE_ID)
    {
        LogError("Эта игра не поддерживает встряхивание!");
    }
}

public void OnInfectSoundChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    strcopy(g_sInfectSound, sizeof(g_sInfectSound), newValue);
}

public void OnMapStart()
{
    PrecacheSound(g_sInfectSound, true);
}

public void OnClientDisconnect(int client)
{
    ResetPlayerBuff(client);
}

public void OnClientPostAdminCheck(int client)
{
    ResetPlayerBuff(client);
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        ResetPlayerBuff(i);
    }
}

void ResetPlayerBuff(int client)
{
    if (g_hInfectTimer[client] != null)
    {
        KillTimer(g_hInfectTimer[client]);
        g_hInfectTimer[client] = null;
    }
    g_iInfectState[client] = 0;
    g_iInfectAttacker[client] = -1;
}

public void OnClientInfected(int client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
        return;

    SetEntityHealth(client, 1);

    float speed = g_hInfectSpeed.FloatValue;
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed);

    float time = g_hInfectTime.FloatValue;
    FlashScreen(client, time, 2.0);
    ShakeScreen(client, time, 40.0, 30.0);

    EmitSoundToClient(client, g_sInfectSound, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);
}

void FlashScreen(int client, float hold, float fade)
{
    if (g_umsgFade == INVALID_MESSAGE_ID) return;

    int clients[1];
    clients[0] = client;

    Handle hMsg = StartMessageEx(g_umsgFade, clients, 1);
    if (hMsg != null)
    {
        PbSetInt(hMsg, "duration", RoundToNearest(fade * 255.0));
        PbSetInt(hMsg, "hold_time", RoundToNearest(hold * 255.0));
        PbSetInt(hMsg, "flags", 1);
        int clr[4] = {255, 0, 0, 128};
        PbSetColor(hMsg, "clr", clr);
        EndMessage();
    }
}

void ShakeScreen(int client, float duration, float magnitude, float noise)
{
    if (g_umsgShake == INVALID_MESSAGE_ID) return;

    int clients[1];
    clients[0] = client;

    Handle hMsg = StartMessageEx(g_umsgShake, clients, 1);
    if (hMsg != null)
    {
        PbSetInt(hMsg, "command", 0);
        PbSetFloat(hMsg, "local_amplitude", magnitude);
        PbSetFloat(hMsg, "frequency", noise);
        PbSetFloat(hMsg, "duration", duration);
        EndMessage();
    }
}
