// Decompilation by Maxim "Kailo" Telezhenko, 2018

new g_var8988[4]; // address: 8988 // zero // codestart: 0
new Handle:g_var9004 = INVALID_HANDLE; // address: 9004 // codestart: 0
new g_var9008 = 0; // address: 9008 // codestart: 0
new Handle:g_var9012 = INVALID_HANDLE; // address: 9012 // codestart: 0
new Handle:g_var9016 = INVALID_HANDLE; // address: 9016 // codestart: 0
new Handle:g_var9020 = INVALID_HANDLE; // address: 9020 // codestart: 0
new Handle:g_var9024 = INVALID_HANDLE; // address: 9024 // codestart: 0
new g_var9028 = 0; // address: 9028 // codestart: 0
new g_var9032 = 0; // address: 9032 // codestart: 0
new g_var9036 = 0; // address: 9036 // codestart: 0
new bool:g_var9040 = false; // address: 9040 // codestart: 0
// 9044 global address

Func1516880() // address: 1516880
{
	g_var9004 = CreateArray(256, 0);
	new Handle:var4 = OpenFile("mapcycle.txt", "r");
	if (var4 == INVALID_HANDLE)
	{
		SetFailState("File not found mapcycle.txt");
		return;
	}
	decl String:var260[256];
	var260[0] = '\0'; // Array
	while (!IsEndOfFile(var4) && ReadFileLine(var4, var260, 256))
	{
		if (var260[0] == 0) // Array
		{
			continue;
		}
		PushArrayString(g_var9004, var260);
	}
	CloseHandle(var4);
	g_var9020 = CreateConVar("sw_timelimit", "60", "Ограничение по времени на карту, в минутах, при достижение запуститься розыгрыш оружий и смена карты", 0, true, 0.0, false, 0.0);
	g_var9024 = CreateConVar("sw_winlimit", "50", "Количество выигрышей одной команды, при достижении которого запуститься розыгрыш оружий и смена карты", 0, true, 0.0, false, 0.0);
	new Handle:var264 = CreateConVar("sw_fraglimit", "110", "Количество фрагов, при достижении которого запуститься розыгрыш оружий и смена карты.", 0, true, 1.0, false, 0.0);
	HookConVarChange(var264, HookCvarFragLimit);
	g_var9028 = GetConVarInt(var264);
	if (g_var9024)
	{
		HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
	}
	if (g_var9020 || g_var9024 || g_var9028)
	{
		HookEvent("player_team", Event_PlayerTeam, EventHookMode_PostNoCopy);
		HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
	}
	HookConVarChange(FindConVar("mp_restartgame"), HookRestart);
	var264 = CreateConVar("sm_weapons_maps_unit", "5", "Количество игроков учавствующих в розыгрыше бонуса при смене карты", 0, true, 1.0, true, 10.0);
	HookConVarChange(var264, HookCvarMapsUnit);
	g_var9032 = GetConVarInt(var264);
	var264 = CreateConVar("sm_weapons_maps_liders", "2", "Cкольким призерам будет выдано оружие.", 0, true, 1.0, true, 10.0);
	HookConVarChange(var264, HookCvarMapsLiders);
	g_var9036 = GetConVarInt(var264);
	CloseHandle(var264);
}

public HookCvarFragLimit(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1519192
{
	g_var9028 = StringToInt(newValue, 10);
}

public HookCvarMapsUnit(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1520560
{
	g_var9032 = StringToInt(newValue, 10);
}

public HookCvarMapsLiders(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1521804
{
	g_var9036 = StringToInt(newValue, 10);
}

public OnConfigsExecuted() // address: 1523884
{
	decl String:var260[260];
	decl String:var272[12];
	for (new var276 = 0; var276 <= 3; var276++)
	{
		FormatEx(var272, 9, "%s", var276 < 3 ? g_var1428[var276] : "nextmap");
		if (GetTrieString(g_var1424, var272, var260, 257))
		{
			PrecacheSound(var260, true);
			Format(var260, 257, "sound/%s", var260);
			AddFileToDownloadsTable(var260);
		}
	}
}

public HookRestart(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1525824
{
	Func1527400();
	new var4 = GetConVarInt(g_var9020) * 60;
	if (var4 > 0 && g_var9012 == INVALID_HANDLE)
	{
		g_var9012 = CreateTimer(float(var4), TimeLimiteStart, 0, 0);
	}
}

Func1527400() // address: 1527400
{
	if (g_var9012)
	{
		KillTimer(g_var9012, false);
		g_var9012 = INVALID_HANDLE;
	}
	if (g_var9016)
	{
		KillTimer(g_var9016, false);
		g_var9016 = INVALID_HANDLE;
	}
	g_var8988[2] = 0; // Array
	g_var8988[3] = 0; // Array
	g_var9040 = false;
	for (new var4 = 1; var4 <= MaxClients; var4++)
	{
		if (IsClientInGame(var4))
		{
			SetEntityRenderColor(var4, 255, 255, 255, 255);
			SetEntityMoveType(var4, MoveType:2);
		}
	}
	Func1494740();
}

public Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast) // address: 1529356
{
	CreateTimer(0.1, CheckPlayerTeam, 0, 2);
}

public Event_WeaponFire(Handle:event, const String:name[], bool:dontBroadcast) // address: 1530812
{
	if (g_var9016)
	{
		new var4 = GetClientOfUserId(GetEventInt(event, "userid"));
		if (var4 > 0)
		{
			new var8 = GetEntPropEnt(var4, Prop_Send, "m_hActiveWeapon", 0);
			CS_DropWeapon(var4, var8, true, true);
		}
	}
}

public Action:CheckPlayerTeam(Handle:timer) // address: 1532976
{
	if (GetTeamClientCount(2) < 1 || GetTeamClientCount(3) < 1)
	{
		Func1527400();
	}
	else
	{
		if (g_var9012 == INVALID_HANDLE)
		{
			new var4 = GetConVarInt(g_var9020) * 60;
			if (var4 > 0)
			{
				g_var9012 = CreateTimer(float(var4), TimeLimiteStart, 0, 0);
			}
		}
	}
}

public Action:TimeLimiteStart(Handle:timer) // address: 1534748
{
	g_var9040 = true;
	g_var9012 = INVALID_HANDLE;
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) // address: 1536040
{
	new var4 = GetEventInt(event, "winner");
	if (var4 < 2)
	{
		return;
	}
	g_var8988[var4]++;
	CheckWinLimit(g_var8988[var4]);
}

public CheckWinLimit(arg12) // address: 1537700
{
	new var4 = GetConVarInt(g_var9024);
	if (var4)
	{
		if (arg12 >= var4 + -1)
		{
			g_var9040 = true;
		}
	}
}

public PlayerDeath_NextMap(arg12) // address: 1538772
{
	if (!g_var9028)
	{
		return;
	}
	if (GetClientFrags(arg12) >= g_var9028 + -1)
	{
		g_var9040 = true;
	}
}

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason) // address: 1540204
{
	if (g_var9040)
	{
		if (g_var9016 == INVALID_HANDLE)
		{
			g_var9016 = CreateTimer(1.0, TimeBonusStart, 0, 3);
			PrintToChatAll("*************************************");
			PrintToChatAll("[PERSONAL WEAPOMS] Запущен розыгрыш призов!");
			PrintToChatAll("*************************************");
			decl String:var260[260];
			if (GetTrieString(g_var1424, "nextmap", var260, 257))
			{
				EmitSoundToAll(var260, -2, 6, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			}
			for (new var264 = 1; var264 <= MaxClients; var264++)
			{
				if (IsClientInGame(var264))
				{
					SetEntityRenderColor(var264, 0, 128, 255, 192);
					SetEntityMoveType(var264, MoveType:0);
				}
			}
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Timer_PrintCenter(Handle:timer, any:data) // address: 1541920
{
	if (g_var9016)
	{
		decl String:var1024[1024];
		ResetPack(data, false);
		ReadPackString(data, var1024, 1024);
		PrintCenterTextAll("ИГРОКИ %s ВЫИГРАЛИ ОРУЖИЯ!", var1024);
		return Action:0;
	}
	return Action:4;
}

public Action:TimeBonusStart(Handle:timer) // address: 1543432
{
	static g_var10256 = 10; // address: 10256 // codestart: 0
	if (g_var10256 <= 3)
	{
		if (g_var10256 < 1)
		{
			Func1481064(g_var9032, g_var9036);
			g_var9016 = INVALID_HANDLE;
			Func1545404();
			g_var10256 = 10;
			return Action:4;
		}
		PrintToChatAll("[P.W] Розыгрыш призов начнется через: %d", g_var10256);
	}
	PrintCenterTextAll("РОЗЫГРЫШ ПРИЗОВ НАЧНЕТСЯ ЧЕРЕЗ: %d", g_var10256);
	g_var10256 = g_var10256 + -1;
	return Action:0;
}

Func1545404() // address: 1545404
{
	if (g_var9008 >= GetArraySize(g_var9004))
	{
		g_var9008 = 0;
	}
	decl String:var256[256];
	decl String:var512[256];
	GetArrayString(g_var9004, g_var9008++, var256, 256);
	GetCurrentMap(var512, 256);
	if (!strcmp(var256, var512, true))
	{
		if (g_var9008 >= GetArraySize(g_var9004))
		{
			g_var9008 = 0;
		}
		GetArrayString(g_var9004, g_var9008++, var256, 256);
	}
	new Handle:var516 = CreateDataPack();
	WritePackString(var516, var256);
	g_var9016 = CreateTimer(15.0, TimeChangeMap, var516, 514);
	PrintToChatAll("Смена карты на: %s", var256);
}

public Action:TimeChangeMap(Handle:timer, any:data) // address: 1547076
{
	decl String:var512[512];
	ResetPack(data, false);
	ReadPackString(data, var512, 512);
	ForceChangeLevel(var512, "[SW] Bonus - next map");
	g_var9040 = false;
	g_var9016 = INVALID_HANDLE;
}
