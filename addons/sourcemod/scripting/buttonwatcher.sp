#include <sourcemod>
#include <sdktools>

bool g_bPressed[2048];
bool g_bShowMessages[MAXPLAYERS+1]; // состояние для каждого игрока

ConVar cv_showtype, cv_log, cv_onlyadmins;

public Plugin myinfo =
{
    name = "Button Watcher",
    author = "Franc1sco franug",
    description = "Generates an output when a button is pressed",
    version = "2.1",
    url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
    HookEntityOutput("func_button", "OnPressed", Button_Pressed);
    CreateConVar("sm_buttonwatcher", "1.2", "", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

    cv_showtype = CreateConVar("sm_buttonwatcher_showtype", "1", "1 = show in chat. 0 = show in console");
    cv_log = CreateConVar("sm_buttonwatcher_log", "1", "1 = enabled logging. 0 = disabled logging");
    cv_onlyadmins = CreateConVar("sm_buttonwatcher_onlyadmins", "0", "1 = show only for admins. 0 = show for everybody");

    RegConsoleCmd("sm_bw", Cmd_ToggleBW, "Включить/выключить показ сообщений от ButtonWatcher");

    // по умолчанию включено для всех
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bShowMessages[i] = true;
    }
}

public Action Cmd_ToggleBW(int client, int args)
{
    if(!IsValidClient(client)) return Plugin_Handled;

    g_bShowMessages[client] = !g_bShowMessages[client];

    if(g_bShowMessages[client])
        PrintToChat(client, "[BW] Показ сообщений включён");
    else
        PrintToChat(client, "[BW] Показ сообщений выключен");

    return Plugin_Handled;
}

public void Button_Pressed(const char[] output, int caller, int activator, float delay)
{
    if(!IsValidClient(activator) || !IsValidEntity(caller)) return;
    if(g_bPressed[caller]) return;

    decl String:entity[512];
    GetEntPropString(caller, Prop_Data, "m_iName", entity, sizeof(entity));

    if(GetConVarBool(cv_showtype)) 
    {
        for (int i = 1; i <= MaxClients; i++)
        {   
            if (IsClientInGame(i) && g_bShowMessages[i]) // только тем, кто включил
            {
                if(!GetConVarBool(cv_onlyadmins) || GetUserAdmin(i) != INVALID_ADMIN_ID || IsClientSourceTV(i))
                {
                    PrintToChat(i, " \x02[BW] \x0C%N \x04pressed button\x0C %i %s", activator, caller, entity);
                }
            }
        }
    }
    else
    {
        for (int i = 1; i <= MaxClients; i++)
        {   
            if (IsClientInGame(i) && g_bShowMessages[i]) // только тем, кто включил
            {
                if(!GetConVarBool(cv_onlyadmins) || GetUserAdmin(i) != INVALID_ADMIN_ID || IsClientSourceTV(i))
                {
                    PrintToConsole(i, "[BW] %N pressed button %i %s", activator, caller, entity);
                }
            }
        }
    }

    if(GetConVarBool(cv_log)) 
        LogMessage("[BW] %L pressed the button %i %s", activator, caller, entity);

    g_bPressed[caller] = true;
    CreateTimer(5.0, Timer_End, caller);
}

public Action Timer_End(Handle timer, int entity)
{
    g_bPressed[entity] = false;
	return Plugin_Continue;
}

public bool IsValidClient(int client) 
{ 
    if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || !IsPlayerAlive(client)) 
        return false; 
    return true; 
}
