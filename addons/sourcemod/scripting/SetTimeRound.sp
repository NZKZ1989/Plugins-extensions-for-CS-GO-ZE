#include <sourcemod>
#include <sdktools>

ConVar g_hRoundTime;

public void OnPluginStart()
{
    g_hRoundTime = FindConVar("mp_roundtime");

    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
}

public void Event_RoundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    CreateTimer(2.0, Timer_SetRoundTime, _, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_SetRoundTime(Handle timer)
{
    char map[64];
    GetCurrentMap(map, sizeof(map));

    if (StrContains(map, "ze_", false) != -1)
    {
        g_hRoundTime.SetInt(30);
    }
    else if (StrContains(map, "zm_", false) != -1)
    {
        g_hRoundTime.SetInt(5);
    }

    return Plugin_Continue;
}
