#include <sourcemod>
#include <sdktools>
#include <csgo_colors>

bool g_HitmarkerEnabled[MAXPLAYERS+1];

public void OnPluginStart()
{
    RegConsoleCmd("hitmarker", Command_ToggleHitmarker, "Toggle hitmarker overlay on/off");
    RegConsoleCmd("hm", Command_ToggleHitmarker, "Toggle hitmarker overlay on/off (short)");
    HookEvent("player_hurt", EnDamage, EventHookMode_Post);
}

public void OnClientPutInServer(int client)
{
    g_HitmarkerEnabled[client] = true; // по умолчанию включено
}

public Action Command_ToggleHitmarker(int client, int args)
{
    if (!IsClientInGame(client)) return Plugin_Handled;

    g_HitmarkerEnabled[client] = !g_HitmarkerEnabled[client];

    if (g_HitmarkerEnabled[client])
    {
        CGOPrintToChat(client, "{GREEN}[Hitmarker] Включен");
    }
    else
    {
        CGOPrintToChat(client, "{RED}[Hitmarker] Отключен");
    }

    return Plugin_Handled;
}

public Action EnDamage(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (attacker <= 0 || !IsClientInGame(attacker)) return Plugin_Continue;

    if (!g_HitmarkerEnabled[attacker]) return Plugin_Continue;

    ShowOverlayToClient(attacker, "overlays/zelost/hitmarker4");
    CreateTimer(0.5, NoOverlay, attacker);

    return Plugin_Continue;
}

void ShowOverlayToClient(int client, const char[] overlaypath)
{
    ClientCommand(client, "r_screenoverlay \"%s\"", overlaypath);
}

public Action NoOverlay(Handle timer, any client)
{
    if (IsClientInGame(client))
    {
        ShowOverlayToClient(client, "");
    }
    return Plugin_Continue;
}
