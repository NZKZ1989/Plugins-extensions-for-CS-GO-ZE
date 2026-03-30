#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

int g_Client_CommandCount[MAXPLAYERS + 1];
float g_Client_LastFlood[MAXPLAYERS + 1];
char g_Client_LastCommand[MAXPLAYERS + 1][64];

#define MAX_COMMANDS 100
#define INTERVAL 1.0

public Plugin myinfo =
{
    name = "AntiFlood",
    author = "BotoX + Modified",
    description = "Blocks command flooding and logs offenders",
    version = "1.0",
    url = ""
};

public void OnPluginStart()
{
    /* Late load */
    for(int client = 1; client <= MaxClients; client++)
    {
        if(IsClientInGame(client))
            OnClientConnected(client);
    }

    AddCommandListener(OnAnyCommand, "");
}

public void OnClientConnected(int client)
{
    g_Client_CommandCount[client] = 0;
    g_Client_LastFlood[client] = 0.0;
    g_Client_LastCommand[client][0] = '\0';
}

public Action OnAnyCommand(int client, const char[] command, int argc)
{
    strcopy(g_Client_LastCommand[client], sizeof(g_Client_LastCommand[]), command);

    if(FloodCheck(client))
        return Plugin_Handled;

    return Plugin_Continue;
}

bool FloodCheck(int client)
{
    if(client <= 0 || client > MaxClients)
        return false;

    if(++g_Client_CommandCount[client] <= MAX_COMMANDS)
        return false;

    float Time = GetGameTime();
    if(Time >= g_Client_LastFlood[client] + INTERVAL)
    {
        g_Client_LastFlood[client] = Time;
        g_Client_CommandCount[client] = 0;
        return false;
    }
	
    char sName[64], sSteamID[32], sIP[32];
    GetClientName(client, sName, sizeof(sName));
    GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));
    GetClientIP(client, sIP, sizeof(sIP));

    char sBuffer[256];
    Format(sBuffer, sizeof(sBuffer),
        "Flood detected: %s | SteamID: %s | IP: %s | Commands: %d | Last command: %s",
        sName, sSteamID, sIP, g_Client_CommandCount[client], g_Client_LastCommand[client]);

    LogToFile("addons/sourcemod/logs/antiflood.log", sBuffer);

    KickClientEx(client, "STOP FLOODING THE SERVER!!!");
    return true;
}
