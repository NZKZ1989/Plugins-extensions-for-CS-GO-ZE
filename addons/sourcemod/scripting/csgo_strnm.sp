#pragma semicolon 1
#include <sourcemod>

#define PLUGIN_VERSION "1.0.3"

new UserMsg:g_TextMsg;
new String:SMNextMap[64];

public Plugin:myinfo =
{
    name = "CS:GO - Show The Right Next Map (STRNM)",
    author = "PharaohsPaw (patched)",
    description = "Replace CS:GO's end of map chat msg with what SM says the next map will be",
    version = PLUGIN_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?t=195384"
}

public OnPluginStart()
{
    g_TextMsg = GetUserMessageId("TextMsg");
    HookUserMessage(g_TextMsg, pReplaceNextMapMsg, true);

    CreateConVar("csgo_strnm_version", PLUGIN_VERSION,
        "CSGO STRNM Plugin Version",
        FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_SPONLY);
}

public Action:pReplaceNextMapMsg(UserMsg:msg_id, Handle:pb, const players[], playersNum, bool:reliable, bool:init)
{
    if (!reliable)
        return Plugin_Continue;

    decl String:message[256];

    if (PbGetRepeatedFieldCount(pb, "params") > 0)
    {
        PbReadString(pb, "params", message, sizeof(message), 0);
    }
    else
    {
        return Plugin_Continue;
    }

    if (StrContains(message, "#game_nextmap") != -1)
    {
        if (GetNextMap(SMNextMap, sizeof(SMNextMap)))
        {
            for (new i = 0; i < playersNum; i++)
            {
                if (!IsClientInGame(players[i]) || IsFakeClient(players[i]))
                    continue;

                CreateTimer(0.1, pPrintNextMap, players[i]);
            }
        }
        else
        {
            PrintToServer("[csgo_strnm] GetNextMap() call failed :(");
        }
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public Action:pPrintNextMap(Handle:timer, any:client)
{
    if (IsClientInGame(client))
    {
        PrintToChat(client, "\x01\x0B\x04[SourceMod] \x01Next Map: \x05%s", SMNextMap);
    }
}
