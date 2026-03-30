#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <PTaH>

#pragma newdecls required

public Plugin myinfo =
{
    name = "[PTaH] Block SM Commands",
    author = "Bara + igroman1266 (объединено)",
    version = "1.1",
    url = "https://github.com/Bara"
};

ConVar g_cBlockPlugins;
ConVar g_cBlockSM;
ConVar g_cBlockMeta;
ConVar g_cBlockRcon;
ConVar g_cAllowRootAdmin;
ConVar g_cMiddleFinger;

char g_sLogs[PLATFORM_MAX_PATH + 1];

public void OnPluginStart() 
{
    g_cBlockPlugins   = CreateConVar("sbp_block_plugins", "1", "Block \"sm plugins\" and \"sm exts\"?", _, true, 0.0, true, 1.0);
    g_cBlockSM        = CreateConVar("sbp_block_sm", "1", "Block \"sm\"?", _, true, 0.0, true, 1.0);
    g_cBlockMeta      = CreateConVar("sbp_block_meta", "1", "Block \"meta\"?", _, true, 0.0, true, 1.0);
    g_cBlockRcon      = CreateConVar("sbp_block_rcon", "1", "Block \"sm_rcon\"?", _, true, 0.0, true, 1.0);
    g_cAllowRootAdmin = CreateConVar("sbp_allow_rootadmin", "1", "Allow root admins to access all commands?", _, true, 0.0, true, 1.0);
    g_cMiddleFinger   = CreateConVar("sbp_show_middle_finger", "1", "Show middle finger?", _, true, 0.0, true, 1.0);

    LoadTranslations("sbp.phrases");

    PTaH(PTaH_ConsolePrintPre, Hook, ConsolePrint);
    PTaH(PTaH_ExecuteStringCommandPre, Hook, ExecuteStringCommand);

    char sDate[18];
    FormatTime(sDate, sizeof(sDate), "%y-%m-%d");
    BuildPath(Path_SM, g_sLogs, sizeof(g_sLogs), "logs/sbp-%s.log", sDate);
}

public Action ConsolePrint(int client, char message[1024])
{
    if (!IsClientConnected(client))
        return Plugin_Continue;

    if (g_cAllowRootAdmin.BoolValue && CheckCommandAccess(client, "sbp_admin", ADMFLAG_ROOT, true))
        return Plugin_Continue;

    if (g_cBlockPlugins.BoolValue)
    {
        if (message[1] == '"' && (StrContains(message, "\" (") != -1 || StrContains(message, ".smx\" ") != -1))
        {
            return Plugin_Handled;
        }
        else if (StrContains(message, "To see more, type \"sm plugins", false) != -1 || StrContains(message, "To see more, type \"sm exts", false) != -1)
        {
            if (g_cMiddleFinger.BoolValue)
            {
                PrintToConsole(client, "<<< ASCII ART MIDDLE FINGER >>>");
            }

            PrintToConsole(client, "\t\t%T\n", "SMPlugin", client);
            LogToFile(g_sLogs, "\"%L\" tried to get the plugin list", client);
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}

public Action ExecuteStringCommand(int client, char sCommandString[512]) 
{
    if (!IsClientValid(client))
        return Plugin_Continue;

    if (g_cAllowRootAdmin.BoolValue && CheckCommandAccess(client, "sm_admin", ADMFLAG_ROOT, true))
        return Plugin_Continue;

    char message[512];
    strcopy(message, sizeof(message), sCommandString);
    TrimString(message);

    if (g_cBlockSM.BoolValue && (StrContains(message, "sm ") == 0 || StrEqual(message, "sm", false)))
        return Plugin_Handled;

    if (g_cBlockMeta.BoolValue && (StrContains(message, "meta ") == 0 || StrEqual(message, "meta", false)))
        return Plugin_Handled;

    if (g_cBlockRcon.BoolValue && StrContains(message, "sm_rcon", false) != -1)
    {
        PrintToConsole(client, "Unknown command: %s", message);
        LogToFile(g_sLogs, "\"%L\" tried to use sm_rcon", client);
        return Plugin_Handled;
    }

    return Plugin_Continue; 
}

bool IsClientValid(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && !IsClientSourceTV(client));
}
