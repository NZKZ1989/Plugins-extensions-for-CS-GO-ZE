#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <zombiereloaded>
#include <colorvariables>

#define PLUGIN_AUTHOR "Franc1sco franug, Modified by Someone"
#define PLUGIN_VERSION "1.0"

int g_color[MAXPLAYERS + 1];
int g_iTColors[25][4] = {
    {255, 255, 255, 255}, {255, 0, 0, 255}, {0, 255, 0, 255}, {0, 0, 255, 255},
    {255, 255, 0, 255}, {255, 0, 255, 255}, {0, 255, 255, 255}, {255, 128, 0, 255},
    {255, 0, 128, 255}, {128, 255, 0, 255}, {0, 255, 128, 255}, {128, 0, 255, 255},
    {0, 128, 255, 255}, {192, 192, 192, 255}, {210, 105, 30, 255}, {139, 69, 19, 255},
    {75, 0, 130, 255}, {248, 248, 255, 255}, {216, 191, 216, 255}, {240, 248, 255, 255},
    {70, 130, 180, 255}, {0, 128, 128, 255}, {255, 215, 0, 255}, {210, 180, 140, 255},
    {255, 99, 71, 255}
};

char g_sTColors[25][32];
Handle c_color = INVALID_HANDLE;

public Plugin myinfo = {
    name = "[ZR] Colors",
    author = PLUGIN_AUTHOR,
    description = "Color selection for humans",
    version = PLUGIN_VERSION,
    url = ""
};

public void OnPluginStart()
{
    LoadTranslations("franug_colors.phrases");

    c_color = RegClientCookie("Colors", "Colors", CookieAccess_Private);
    RegConsoleCmd("sm_colors", Colores);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i))
            continue;

        if (AreClientCookiesCached(i)) OnClientCookiesCached(i);
        else g_color[i] = 0;
    }

    AutoExecConfig();

    HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
    HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Post);
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    CreateTimer(1.0, colorapply, client);
}

public void OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    CreateTimer(1.0, colorapply, client);
}

public ZR_OnClientInfected(client, attacker, bool motherInfect, bool respawnOverride, bool respawn)
{
    if (!IsClientInGame(client)) return;
    if (!IsPlayerAlive(client)) return;

    SetEntityRenderColor(client, 255, 255, 255, 255);
}

public Action colorapply(Handle timer, any client)
{
    if (!IsClientInGame(client)) return Plugin_Continue;
    if (!IsPlayerAlive(client)) return Plugin_Continue;

    if (GetClientTeam(client) == 3)
    {
        SetEntityRenderMode(client, RENDER_NORMAL);
        if (g_color[client] != 0)
            SetEntityRenderColor(client,
                g_iTColors[g_color[client]][0],
                g_iTColors[g_color[client]][1],
                g_iTColors[g_color[client]][2],
                g_iTColors[g_color[client]][3]);
        else
            SetEntityRenderColor(client, 255, 255, 255, 255);
    }
    return Plugin_Continue;
}

public OnClientCookiesCached(int client)
{
    char SprayString[12];
    GetClientCookie(client, c_color, SprayString, sizeof(SprayString));

    g_color[client] = StringToInt(SprayString);
}

public OnClientDisconnect(int client)
{
    if (AreClientCookiesCached(client))
    {
        char SprayString[12];
        Format(SprayString, sizeof(SprayString), "%i", g_color[client]);
        SetClientCookie(client, c_color, SprayString);
    }
}

public Action Colores(int client, int args)
{
    Handle menu = CreateMenu(DIDMenuHandler);
    char title[64];
    Format(title, 64, "%t", "Color Title");
    SetMenuTitle(menu, title);
    SetupRGBA(client);

    char temp[4];
    for (int i = 0; i < 25; i++)
    {
        Format(temp, sizeof(temp), "%i", i);
        AddMenuItem(menu, temp, g_sTColors[i]);
    }
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, 0);

    return Plugin_Handled;
}

public DIDMenuHandler(Handle menu, MenuAction action, int client, int itemNum)
{
    if (action == MenuAction_Select)
    {
        char info[32];
        GetMenuItem(menu, itemNum, info, sizeof(info));
        int g = StringToInt(info);

        if (IsPlayerAlive(client) && ZR_IsClientHuman(client))
        {
            CPrintToChat(client, "{green}[SM] %t", "Color Apply");
            SetEntityRenderColor(client,
                g_iTColors[g][0],
                g_iTColors[g][1],
                g_iTColors[g][2],
                g_iTColors[g][3]);
        }
        else
        {
            CPrintToChat(client, "{green}[SM]{default} %t", "Color Only Human");
        }

        g_color[client] = g;
        SetupRGBA(client);
        Colores(client, 0);
    }
    else if (action == MenuAction_End)
    {
        CloseHandle(menu);
    }
}

SetupRGBA(int client)
{
    char colorTemp[32];

    Format(colorTemp, sizeof(colorTemp), "%T", "color_normal", client);      g_sTColors[0]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_red", client);         g_sTColors[1]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_green", client);       g_sTColors[2]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_blue", client);        g_sTColors[3]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_yellow", client);      g_sTColors[4]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_purple", client);      g_sTColors[5]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_cyan", client);        g_sTColors[6]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_orange", client);      g_sTColors[7]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_pink", client);        g_sTColors[8]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_olive", client);       g_sTColors[9]  = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_lime", client);        g_sTColors[10] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_violet", client);      g_sTColors[11] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_lightblue", client);   g_sTColors[12] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_silver", client);      g_sTColors[13] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_chocolate", client);   g_sTColors[14] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_saddlebrown", client); g_sTColors[15] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_indigo", client);      g_sTColors[16] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_ghostwhite", client);  g_sTColors[17] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_thistle", client);     g_sTColors[18] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_aliceblue", client);   g_sTColors[19] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_steelblue", client);   g_sTColors[20] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_teal", client);        g_sTColors[21] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_gold", client);        g_sTColors[22] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_tan", client);         g_sTColors[23] = colorTemp;
    Format(colorTemp, sizeof(colorTemp), "%T", "color_tomato", client);      g_sTColors[24] = colorTemp;
}

stock bool IsValidClient(int client)
{
    if ((client <= 0) || (client > MaxClients)) {
        return false;
    }
    if (!IsClientInGame(client)) {
        return false;
    }
    if (!IsPlayerAlive(client)) {
        return false;
    }
    return true;
}
