#pragma newdecls required

public Plugin myinfo = 
{
	name = "Silence Cvar", 
	author = "", 
	description = "Silence Cvar", 
	version = "1.0", 
	url = ""
};

public void OnPluginStart()
{
	HookEvent("server_cvar", SilentEvent, EventHookMode_Pre);
}

public Action SilentEvent(Event event, const char[] name, bool dontBroadcast)
{
	SetEventBroadcast(event, true);
	return Plugin_Continue;
} 