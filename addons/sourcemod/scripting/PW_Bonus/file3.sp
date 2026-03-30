// Decompilation by Maxim "Kailo" Telezhenko, 2018

new Handle:g_var2096 = INVALID_HANDLE; // address: 2096 // codestart: 0
new g_var2100[66][3]; // address: 2100 // zero // codestart: 0
new g_var3156[66]; // address: 3156 // zero // codestart: 0
new g_var3420[66]; // address: 3420 // zero // codestart: 0
new String:g_var3684[66][16]; // address: 3684 // codestart: 0
new g_var5004[66]; // address: 5004 // zero // codestart: 0
new String:g_var5268[66][32]; // address: 5268 // zero // codestart: 0
new bool:g_var7644 = false; // address: 7644 // codestart: 0
new bool:g_var7648 = false; // address: 7648 // codestart: 0
new bool:g_var7652 = false; // address: 7652 // codestart: 0
new bool:g_var7656 = false; // address: 7656 // codestart: 0
// 7660 global address

Func1484996() // address: 1484996
{
	g_var2096 = CreateKeyValues("stats");
	HookEvent("player_death", player_death, EventHookMode_Post);
	new Handle:var4 = INVALID_HANDLE;
	var4 = CreateConVar("sm_weapons_kill", "1", "Выдавать бонусное оружие по килам", 0, true, 0.0, true, 1.0);
	g_var7644 = GetConVarBool(var4);
	HookConVarChange(var4, Cvar_WeaponsKill);
	var4 = CreateConVar("sm_weapons_kill_awp", "1", "Выдавать бонусное оружие по килам с авп", 0, true, 0.0, true, 1.0);
	g_var7648 = GetConVarBool(var4);
	HookConVarChange(var4, Cvar_WeaponsKillAwp);
	var4 = CreateConVar("sm_weapons_kill_knife", "1", "Выдавать бонусное оружие по килам с ножа", 0, true, 0.0, true, 1.0);
	g_var7652 = GetConVarBool(var4);
	HookConVarChange(var4, Cvar_WeaponsKillKnife);
	var4 = CreateConVar("sm_webmotd", "1", "Включить показ мотд окна игроку выигравшему бонус", 0, true, 0.0, true, 1.0);
	g_var7656 = GetConVarBool(var4);
	HookConVarChange(var4, Cvar_WeaponsMotd);
	CloseHandle(var4);
}

public Cvar_WeaponsKill(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1487024
{
	g_var7644 = bool:StringToInt(newValue, 10);
}

public Cvar_WeaponsKillAwp(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1488508
{
	g_var7648 = bool:StringToInt(newValue, 10);
}

public Cvar_WeaponsKillKnife(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1490416
{
	g_var7652 = bool:StringToInt(newValue, 10);
}

public Cvar_WeaponsMotd(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1492120
{
	g_var7656 = bool:StringToInt(newValue, 10);
}

Func1493428() // address: 1493428
{
	KvRewind(g_var2096);
	if (KvGotoFirstSubKey(g_var2096, true))
	{
		do
		{
			KvDeleteThis(g_var2096);
		}
		while (KvGotoNextKey(g_var2096, true));
	}
}

Func1494740() // address: 1494740
{
	KvRewind(g_var2096);
	if (KvGotoFirstSubKey(g_var2096, true))
	{
		do {
			for (new var4 = 0; var4 < 3; var4++)
			{
				KvSetNum(g_var2096, g_var1428[var4], 0);
			}
			KvSetNum(g_var2096, "kill", 0);
			KvSetNum(g_var2096, "death", 0);
		} while (KvGotoNextKey(g_var2096, true));
	}
	for (new var4 = 1; var4 <= MaxClients; var4++)
	{
		if (IsClientInGame(var4))
		{
			g_var2100[var4][0] = 0; // Array
			g_var2100[var4][1] = 0; // Array
			g_var2100[var4][2] = 0; // Array
			g_var3420[var4] = 0;
			g_var3156[var4] = 0;
		}
	}
}

Func1496940(arg12) // address: 1496940
{
	if (IsFakeClient(arg12))
	{
		return;
	}
	GetClientAuthId(arg12, AuthId_Steam2, g_var5268[arg12], 30, true);
	KvRewind(g_var2096);
	if (KvJumpToKey(g_var2096, g_var5268[arg12], false))
	{
		for (new var4 = 0; var4 < 3; var4++)
		{
			g_var2100[arg12][var4] = KvGetNum(g_var2096, g_var1428[var4], 0);
		}
		g_var3156[arg12] = KvGetNum(g_var2096, "kill", 0);
		g_var3420[arg12] = KvGetNum(g_var2096, "death", 0);
		new Handle:var4 = Handle:KvGetNum(g_var2096, "time", 0);
		if (var4)
		{
			KillTimer(var4, false);
		}
	}
	else
	{
		if (KvJumpToKey(g_var2096, g_var5268[arg12], true))
		{
			for (new var4 = 0; var4 < 3; var4++)
			{
				KvSetNum(g_var2096, g_var1428[var4], 0);
				g_var2100[arg12][var4] = 0;
			}
			g_var3420[arg12] = 0;
			g_var3156[arg12] = 0;
			KvSetNum(g_var2096, "kill", 0);
			KvSetNum(g_var2096, "death", 0);
		}
	}
}

Func1499968(arg12) // address: 1499968
{
	KvRewind(g_var2096);
	if (KvJumpToKey(g_var2096, g_var5268[arg12], false))
	{
		for (new var4 = 0; var4 < 3; var4++)
		{
			KvSetNum(g_var2096, g_var1428[var4], g_var2100[arg12][var4]);
			g_var2100[arg12][var4] = 0;
		}
		KvSetNum(g_var2096, "kill", g_var3156[arg12]);
		KvSetNum(g_var2096, "death", g_var3420[arg12]);
		g_var3420[arg12] = 0;
		g_var3156[arg12] = 0;
		new Handle:var4 = INVALID_HANDLE;
		new Handle:var8 = INVALID_HANDLE;
		var4 = CreateDataTimer(float(300), DeleteStatsTime, var8, 2);
		WritePackString(var8, g_var5268[arg12]);
		KvSetNum(g_var2096, "time", _:var4);
	}
}

public Action:DeleteStatsTime(Handle:timer, any:data) // address: 1502248
{
	decl String:var28[28];
	ResetPack(data, false);
	ReadPackString(data, var28, 25);
	KvRewind(g_var2096);
	if (KvJumpToKey(g_var2096, var28, false))
	{
		KvDeleteThis(g_var2096);
	}
}


public player_death(Handle:event, const String:name[], bool:dontBroadcast) // address: 1503272
{
	new var4 = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (var4 < 1)
	{
		return;
	}
	new var8 = GetClientOfUserId(GetEventInt(event, "userid"));
	if (GetClientTeam(var4) == GetClientTeam(var8))
	{
		return;
	}
	decl String:var24[15];
	GetEventString(event, "weapon", var24, 14);
	for (new var28 = 0; var28 < 3; var28++)
	{
		if (var28 == 0 && !StrEqual(var24, "awp", true) && !StrEqual(var24, "knife", true))
		{
			g_var2100[var4][var28]++;
		}
		else
		{
			if (StrEqual(var24, g_var1428[var28], true))
			{
				g_var2100[var4][var28]++;
			}
		}
		if (g_var2100[var4][var28] >= g_var1464[var28])
		{
			g_var2100[var4][var28] = 0;
			if (Func1510272(var28) && Func1505608(var4, var24, var28, false))
			{
				break;
			}
		}
	}
	g_var3156[var4]++;
	g_var3420[var8]++;
	PlayerDeath_NextMap(var4);
}

Func1505608(arg12, String:arg16[15], arg20, bool:arg24) // address: 1505608
{
	decl String:var52[51];
	var52[0] = '\0'; // Array
	Func1478144(g_var1428[arg20], arg16, var52);
	if (var52[0]) // Array
	{
		g_var5004[arg12] = arg20;
		strcopy(g_var3684[arg12], 15, arg16);
		if (!arg24)
		{
			decl String:var312[260];
			if (GetTrieString(g_var1424, g_var1428[arg20], var312, 257))
			{
				EmitSoundToAll(var312, -2, 6, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			}
		}
		switch (arg20)
		{
			case 0:
			{
				if (!arg24)
				{
					PrintCenterTextAll("ИГРОК %N ВЫИГРАЛ ОРУЖИЕ!", arg12);
				}
			}
			case 1:
			{
				PrintCenterTextAll("ИГРОК %N САМЫЙ КРУТОЙ АВАПЕР НА ЭТОЙ КАРТЕ!", arg12);
			}
			case 2:
			{
				PrintCenterTextAll("ИГРОК %N САМЫЙ КРУТОЙ МЯСНИК НА ЭТОЙ КАРТЕ!", arg12);
			}
		}
		new Handle:var56 = CreateMenu(Select_Menu, MENU_ACTIONS_DEFAULT);
		decl String:var96[40];
		var96[0] = '\0'; // Array
		if (!CheckSkinWeapon_SkinsWeapons(arg12, arg16, var52, false))
		{
			Func1511924(g_var1476[arg20], var96, 40);
			PrintToChatAll("[P.W] Игрок %N выиграл оружие %s %s", arg12, var52, var96);
			SetMenuTitle(var56, "Вы выиграли оружие %s:\n \n", var52);
		}
		else
		{
			Func1511924(g_var1476[3], var96, 40); // Array
			PrintToChatAll("[P.W] Игрок %N выиграл продление срока для оружия %s %s", arg12, var52, var96);
			SetMenuTitle(var56, "Вы выиграли продление %s:\n \n", var52);
		}
		AddMenuItem(var56, var52, "Забрать", 0);
		AddMenuItem(var56, var52, "Отказ", 0);
		DisplayMenu(var56, arg12, 0);
	}
	return 0;
}

public Select_Menu(Handle:menu, MenuAction:action, param1, param2) // address: 1507844
{
	switch (action)
	{
		case MenuAction_Select:
		{
			CloseHandle(menu);
		}
		case MenuAction_End:
		{
			if (!param2)
			{
				decl String:var52[52];
				GetMenuItem(menu, param2, var52, 51);
				if (AddWeapon_SkinsWeapons(param1, g_var3684[param1], var52, g_var1476[g_var5004[param1]]))
				{
					Func1513788(param1, var52);
					PrintToChat(param1, "[P.W] У вас новое оружие в инвентаре.");
				}
				else
				{
					if (AddTime_SkinsWeapons(param1, g_var3684[param1], var52, g_var1476[3])) // Array
					{
						PrintToChat(param1, "[P.W] Вам продлен срок на оружие.");
					}
					else
					{
						LogError("[Bonus] Failed to give the player a bonus weapons");
					}
				}
			}
			else
			{
				PrintToChat(param1, "[P.W] Вы отказались от оружия.");
			}
		}
	}
}

Func1510272(arg12) // address: 1510272
{
	switch (arg12)
	{
		case 0:
		{
			return g_var7644;
		}
		case 1:
		{
			return g_var7648;
		}
		case 2:
		{
			return g_var7652;
		}
	}
	return 0;
}

Func1511924(arg12, String:arg16[], arg20) // address: 1511924
{
	if (arg12)
	{
		if (arg12 >= 86400)
		{
			FormatEx(arg16, arg20, "на %d дн. %d ч.", arg12 / 3600 / 24, arg12 / 3600 % 24);
		}
		else
		{
			FormatEx(arg16, arg20, "на %d ч.", arg12 / 3600 % 24);
		}
	}
	else
	{
		FormatEx(arg16, arg20, "навсегда");
	}
}

Func1513788(arg12, const String:arg16[]) // address: 1513788
{
	if (g_var7656)
	{
		decl String:var512[512];
		if (GetTrieString(g_var1420, arg16, var512, 512))
		{
			ShowMOTDPanel(arg12, arg16, var512, 2);
		}
	}
}

public Float:CalculatorKpd(arg12) // address: 1515140
{
	new var4 = g_var3156[arg12];
	new var8 = g_var3420[arg12];
	if (g_var3420[arg12] == 0)
	{
		var8 = 1;
	}
	return float(var4 * 100 / var8) / 100.0;
}
