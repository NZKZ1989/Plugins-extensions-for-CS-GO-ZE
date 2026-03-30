#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#undef REQUIRE_PLUGIN
#tryinclude <zombiereloaded>
#define REQUIRE_PLUGIN
#include "loghelper.inc"

#pragma newdecls required

bool g_bZRLoaded;
Handle g_hFwd_SpectateByCommand;

bool g_bRoundEnd;

public Plugin myinfo =
{
	name		= "Spectate",
	description	= "Adds a command to spectate specific players and removes broken spectate mode.",
	author		= "Obus + BotoX",
	version		= "1.1",
	url			= ""
}

// Spectator Movement modes (from smlib)
enum Obs_Mode
{
	OBS_MODE_NONE = 0,	// not in spectator mode
	OBS_MODE_DEATHCAM,	// special mode for death cam animation
	OBS_MODE_FREEZECAM,	// zooms to a target, and freeze-frames on them
	OBS_MODE_FIXED,		// view from a fixed camera position
	OBS_MODE_IN_EYE,	// follow a player in first person view
	OBS_MODE_CHASE,		// follow a player in third person view
	OBS_MODE_POI,		// PASSTIME point of interest - game objective, big fight, anything interesting; added in the middle of the enum due to tons of hard-coded "<ROAMING" enum compares
	OBS_MODE_ROAMING,	// free roaming

	NUM_OBSERVER_MODES
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	RegConsoleCmd("sm_spectate", Command_Spectate, "Spectate a player.");
	RegConsoleCmd("sm_spec", Command_Spectate, "Spectate a player.");

	AddCommandListener(Command_Suicide, "spectate");
	AddCommandListener(Command_Suicide, "kill");
	AddCommandListener(Command_Goto, "spec_goto");

	g_hFwd_SpectateByCommand = CreateGlobalForward("OnPlayerSwitchedToSpectateByCommand", ET_Ignore, Param_Cell);

	HookEvent("round_start", OnRoundStart, EventHookMode_Post);
	HookEvent("round_end", OnRoundEnd, EventHookMode_Pre);
}

public void OnAllPluginsLoaded()
{
	g_bZRLoaded = LibraryExists("zombiereloaded");
}

public void OnLibraryAdded(const char[] sName)
{
	if (strcmp(sName, "zombiereloaded", false) == 0)
		g_bZRLoaded = true;
}

public void OnLibraryRemoved(const char[] sName)
{
	if (strcmp(sName, "zombiereloaded", false) == 0)
		g_bZRLoaded = false;
}

public void OnMapStart()
{
	GetTeams();
}

public void OnRoundStart(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	g_bRoundEnd = false;
}

public void OnRoundEnd(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	g_bRoundEnd = true;
}

public void OnClientSettingsChanged(int client)
{
	static char sSpecMode[8];
	GetClientInfo(client, "cl_spec_mode", sSpecMode, sizeof(sSpecMode));

	Obs_Mode iObserverMode = view_as<Obs_Mode>(StringToInt(sSpecMode));

	// Skip broken OBS_MODE_POI, but not on CS:GO
	if (GetEngineVersion() != Engine_CSGO && iObserverMode == OBS_MODE_POI)
	{
		ClientCommand(client, "cl_spec_mode %d", OBS_MODE_ROAMING);
		if(IsClientInGame(client) && !IsPlayerAlive(client))
			SetEntProp(client, Prop_Send, "m_iObserverMode", OBS_MODE_ROAMING);
	}
}

public Action Command_Spectate(int client, int argc)
{
	if (!client)
	{
		PrintToServer("[SM] Cannot use command from server console.");
		return Plugin_Handled;
	}

#if defined _zr_included
	if (g_bZRLoaded && IsPlayerAlive(client) && ZR_IsClientZombie(client))
	{
		bool bOnlyZombie = true;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (i != client && IsClientInGame(i) && IsPlayerAlive(i) && ZR_IsClientZombie(i))
			{
				bOnlyZombie = false;
				break;
			}
		}

		if (bOnlyZombie)
		{
			PrintToChat(client, "[SM] Can not switch to spectate as the last zombie!");
			return Plugin_Handled;
		}
	}
#endif

	if (!argc)
	{
		if (GetClientTeam(client) != CS_TEAM_SPECTATOR)
		{
#if defined _zr_included
			if (g_bZRLoaded && IsPlayerAlive(client) && ZR_IsClientHuman(client) && GetTeamAliveClientCount(CS_TEAM_T) > 0 && !g_bRoundEnd)
				LogPlayerEvent(client, "triggered", "switch_to_spec");
#endif

			Call_StartForward(g_hFwd_SpectateByCommand);
			Call_PushCell(client);
			Call_Finish();

			StripPlayerKnifes(client);
			ForcePlayerSuicide(client);
			ChangeClientTeam(client, CS_TEAM_SPECTATOR);
		}

		return Plugin_Handled;
	}

	char sTarget[MAX_TARGET_LENGTH];
	GetCmdArg(1, sTarget, sizeof(sTarget));

	int iTarget;
	if ((iTarget = FindTarget(client, sTarget, false, false)) <= 0)
		return Plugin_Handled;

	if (!IsPlayerAlive(iTarget))
	{
		ReplyToCommand(client, "[SM] %t", "Target must be alive");
		return Plugin_Handled;
	}

	if (GetClientTeam(client) != CS_TEAM_SPECTATOR)
	{
#if defined _zr_included
		if (g_bZRLoaded && IsPlayerAlive(client) && ZR_IsClientHuman(client) && GetTeamAliveClientCount(CS_TEAM_T) > 0 && !g_bRoundEnd)
			LogPlayerEvent(client, "triggered", "switch_to_spec");
#endif

		Call_StartForward(g_hFwd_SpectateByCommand);
		Call_PushCell(client);
		Call_Finish();

		StripPlayerKnifes(client);
		ForcePlayerSuicide(client);
		ChangeClientTeam(client, CS_TEAM_SPECTATOR);
	}

	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", iTarget);

	Obs_Mode iObserverMode = view_as<Obs_Mode>(GetEntProp(client, Prop_Send, "m_iObserverMode"));

	// If the client is currently in free roaming then switch them to first person view
	if (iObserverMode >= OBS_MODE_POI)
	{
		ClientCommand(client, "cl_spec_mode %d", OBS_MODE_IN_EYE);
		SetEntProp(client, Prop_Send, "m_iObserverMode", OBS_MODE_IN_EYE);
	}

	PrintToChat(client, "\x01[SM] Spectating \x04%N\x01.", iTarget);

	return Plugin_Handled;
}

public Action Command_Suicide(int client, char[] command, int args)
{
#if defined _zr_included
	if (g_bZRLoaded && IsPlayerAlive(client) && ZR_IsClientHuman(client) && GetTeamAliveClientCount(CS_TEAM_T) > 0 && !g_bRoundEnd)
		LogPlayerEvent(client, "triggered", "switch_to_spec");
#endif

	return Plugin_Continue;
}

// Fix spec_goto crash exploit
public Action Command_Goto(int client, const char[] command, int argc)
{
	if(argc == 5)
	{
		for(int i = 1; i <= 3; i++)
		{
			char sArg[64];
			GetCmdArg(i, sArg, 64);
			float fArg = StringToFloat(sArg);

			if(FloatAbs(fArg) > 5000000000.0)
			{
				PrintToServer("%d -> %f > %f", i, FloatAbs(fArg), 5000000000.0);
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

stock int GetTeamAliveClientCount(int iTeam)
{
	int ret = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || GetClientTeam(i) != iTeam)
			continue;

		if (!IsPlayerAlive(i))
			continue;

		ret++;
	}

	return ret;
}

stock void StripPlayerKnifes(int client)
{
	int w = -1;

	while ((w = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE)) != -1)
	{
		if(IsValidEntity(w) && IsValidEdict(w))
		{
			RemovePlayerItem(client, w);
			AcceptEntityInput(w, "Kill");
		}
	}
}
