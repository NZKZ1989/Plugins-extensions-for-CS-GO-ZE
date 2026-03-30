// Decompilation by Maxim "Kailo" Telezhenko, 2018

new Handle:g_var32576 = INVALID_HANDLE; // address: 32576
new Handle:g_var32580 = INVALID_HANDLE; // address: 32580
new Handle:g_var32584[66]; // address: 32584 // zero
new Handle:g_var32848 = INVALID_HANDLE; // address: 32848
new Handle:g_var32852 = INVALID_HANDLE; // address: 32852
new Handle:g_var32856 = INVALID_HANDLE; // address: 32856
// global address 32860

Func1603704() // address: 1603704
{
	g_var32580 = CreateKeyValues("Group");
	g_var32848 = CreateTrie();
	g_var32856 = CreateTrie();
	HookConVarChange(FindConVar("mp_restartgame"), OnConVarRestart);
}

Func1605664() // address: 1605664
{
	g_var32852 = CreateKeyValues("Drop");
	decl String:var256[256];
	BuildPath(Path_SM, var256, 256, "data/skins_weapons/models.txt");
	g_var32576 = CreateKeyValues("Models");
	if (!FileToKeyValues(g_var32576, var256))
	{
		SetFailState("File not found %s", var256);
		return;
	}
	new bool:var260 = false;
	if (KvGotoFirstSubKey(g_var32576, true))
	{
		decl String:var516[256];
		decl String:var568[52];
		decl String:var588[20];
		decl String:var596[8];
		do
		{
			KvGetSectionName(g_var32576, var588, 20);
			Func1677348(var588, var588, 20);
			if (KvGotoFirstSubKey(g_var32576, true))
			{
				do
				{
					new var616[5];
					KvGetSectionName(g_var32576, var568, 51);
					if (GetTrieArray(g_var32848, var568, var616, 5))
					{
						var260 = true;
						Format(var568, 51, "%s_%d", var568, GetRandomInt(100, 999));
						KvSetSectionName(g_var32576, var568);
						LogError("An identical ID: Name Change To %s", var568);
					}
					var516[0] = '\0'; // Array
					KvGetString(g_var32576, "world", var516, 256);
					if (var516[0]) // Array
					{
						var616[0] = PrecacheModel(var516, false); // Array
						IntToString(var616[0], var596, 5); // Array
						SetTrieString(g_var32856, var596, var568, true);
					}
					else
					{
						SetFailState("World Model not found - weapon: %s", var568);
					}
					var516[0] = '\0'; // Array
					KvGetString(g_var32576, "view", var516, 256);
					if (!(var516[0])) // Array
					{
						KvGetString(g_var32576, "view_t", var516, 256);
						var616[2] = PrecacheModel(var516, false); // Array
						KvGetString(g_var32576, "view_ct", var516, 256);
						var616[3] = PrecacheModel(var516, false); // Array
					}
					else
					{
						var616[1] = PrecacheModel(var516, false); // Array
					}
					var516[0] = '\0'; // Array
					if (!strcmp("c4", var588, true))
					{
						KvGetString(g_var32576, "world_planted", var516, 256);
						if (var516[0]) // Array
						{
							var616[4] = PrecacheModel(var516, false); // Array
						}
					}
					else
					{
						var616[4] = KvGetNum(g_var32576, "flip_view", 0); // Array
					}
					SetTrieArray(g_var32848, var568, var616, 5, true);
					Func1704704(var568, var588);
				}
				while (KvGotoNextKey(g_var32576, true));
				KvGoBack(g_var32576);
			}
		}
		while (KvGotoNextKey(g_var32576, true));
	}
	KvRewind(g_var32576);
	if (var260)
	{
		KeyValuesToFile(g_var32576, var256);
	}
	Func1707620();
	BuildPath(Path_SM, var256, 256, "data/skins_weapons/download.txt");
	if (!Func1662864(var256))
	{
		PrintToServer("%s not found", var256);
	}
}

Func1609116() // address: 1609116
{
	if (g_var32576)
	{
		CloseHandle(g_var32576);
	}
	if (g_var32852)
	{
		CloseHandle(g_var32852);
	}
	ClearTrie(g_var32848);
	ClearTrie(g_var32856);
}

Func1610108(arg12) // address: 1610108
{
	if (g_var32584[arg12])
	{
		CloseHandle(g_var32584[arg12]);
		g_var32584[arg12] = INVALID_HANDLE;
	}
	g_var32584[arg12] = CreateKeyValues("Weapons");
}

Func1611648(arg12, const String:arg16[], const String:arg20[], arg24, arg28) // address: 1611648
{
	if (arg24 && arg24 < GetTime())
	{
		Func1695224(arg12, arg20);
		return;
	}
	if (KvJumpToKey(g_var32584[arg12], arg16, true))
	{
		if (KvJumpToKey(g_var32584[arg12], arg20, true))
		{
			KvSetNum(g_var32584[arg12], "time", arg24);
			if (arg28)
			{
				Func1613552(arg12, arg16, arg20, arg24);
			}
			KvRewind(g_var32584[arg12]);
		}
		KvRewind(g_var32584[arg12]);
	}
}

Func1613552(arg12, const String:arg16[], const String:arg20[], arg24) // address: 1613552
{
	if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], true))
	{
		if (KvJumpToKey(g_var32580, arg16, true))
		{
			new var20[5];
			GetTrieArray(g_var32848, arg20, var20, 5);
			KvSetString(g_var32580, "Name", arg20);
			KvSetNum(g_var32580, "w", var20[0]); // Array
			KvSetNum(g_var32580, "v", var20[1]); // Array
			KvSetNum(g_var32580, "v_t", var20[2]); // Array
			KvSetNum(g_var32580, "v_ct", var20[3]); // Array
			KvSetNum(g_var32580, "v_flip", var20[4]); // Array
			KvSetNum(g_var32580, "time", arg24);
			KvRewind(g_var32580);
		}
		KvRewind(g_var32580);
	}
}

Func1615784(arg12, const String:arg16[]) // address: 1615784
{
	if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], false))
	{
		if (KvJumpToKey(g_var32580, arg16, false))
		{
			KvDeleteThis(g_var32580);
			KvRewind(g_var32580);
		}
		KvRewind(g_var32580);
	}
}

Func1617064(arg12, const String:arg16[], const String:arg20[]) // address: 1617064
{
	if (KvJumpToKey(g_var32584[arg12], arg16, false))
	{
		if (KvJumpToKey(g_var32584[arg12], arg20, false))
		{
			KvDeleteThis(g_var32584[arg12]);
			KvRewind(g_var32584[arg12]);
		}
		KvRewind(g_var32584[arg12]);
	}
}

Func1618504(arg12,  const String:arg16[]) // address: 1618504
{
	if (KvJumpToKey(g_var32584[arg12], arg16, false))
	{
		KvDeleteThis(g_var32584[arg12]);
		KvRewind(g_var32584[arg12]);
	}
}

Func1619800(arg12) // address: 1619800
{
	if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], false))
	{
		KvDeleteThis(g_var32580);
		KvRewind(g_var32580);
	}
	if (g_var32584[arg12])
	{
		CloseHandle(g_var32584[arg12]);
		g_var32584[arg12] = INVALID_HANDLE;
	}
}

bool:Func1621172(arg12, const String:arg16[]) // address: 1621172
{
	new bool:var4 = false;
	if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], false))
	{
		if (KvJumpToKey(g_var32580, arg16, false))
		{
			KvRewind(g_var32580);
			var4 = true;
		}
		KvRewind(g_var32580);
	}
	return var4;
}

bool:Func1622992(arg12, const String:arg16[], const String:arg20[]) // address: 1622992
{
	decl String:var52[52];
	if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], false))
	{
		if (KvJumpToKey(g_var32580, arg16, false))
		{
			KvGetString(g_var32580, "Name", var52, 51);
			KvRewind(g_var32580);
		}
		KvRewind(g_var32580);
	}
	return (!strcmp(arg20, var52, true)) ? true : false;
}

bool:Func1624584(arg12, const String:arg16[]) // address: 1624584
{
	new bool:var4 = false;
	if (KvJumpToKey(g_var32584[arg12], arg16, false))
	{
		var4 = true;
		KvRewind(g_var32584[arg12]);
	}
	return var4;
}

bool:Func1626196(arg12, const String:arg16[], const String:arg20[]) // address: 1626196
{
	new bool:var4 = false;
	if (KvJumpToKey(g_var32584[arg12], arg16, false))
	{
		if (KvJumpToKey(g_var32584[arg12], arg20, false))
		{
			var4 = true;
			KvRewind(g_var32584[arg12]);
		}
		KvRewind(g_var32584[arg12]);
	}
	return var4;
}

Func1628244(arg12, const String:arg16[], const String:arg20[]) // address: 1628244
{
	new var4 = -1;
	if (KvJumpToKey(g_var32584[arg12], arg16, false))
	{
		if (KvJumpToKey(g_var32584[arg12], arg20, false))
		{
			var4 = KvGetNum(g_var32584[arg12], "time", 0);
			KvRewind(g_var32584[arg12]);
		}
		KvRewind(g_var32584[arg12]);
	}
	return var4;
}

Func1629704(arg12, const String:arg16[], String:arg20[51]) // address: 1629704
{
	if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], false))
	{
		if (KvJumpToKey(g_var32580, arg16, false))
		{
			KvGetString(g_var32580, "Name", arg20, 51);
			KvRewind(g_var32580);
		}
		KvRewind(g_var32580);
	}
}

Func1631052(arg12) // address: 1631052
{
	new var4 = -1;
	if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], true))
	{
		if (KvJumpToKey(g_var32580, "c4", true))
		{
			var4 = KvGetNum(g_var32580, "v_flip", -1);
			KvRewind(g_var32580);
		}
		KvRewind(g_var32580);
	}
	return var4;
}

Func1632396(arg12, const String:arg16[], const String:arg20[], arg24) // address: 1632396
{
	if (Func1622992(arg12, arg16, arg20))
	{
		Func1615784(arg12, arg16);
	}
	if (arg24)
	{
		Func1617064(arg12, arg16, arg20);
	}
	Func1695224(arg12, arg20);
}

Func1634244(Handle:arg12) // address: 1634244
{
	if (KvGotoFirstSubKey(g_var32576, true))
	{
		decl String:var16[16];
		decl String:var68[52];
		do
		{
			KvGetSectionName(g_var32576, var16, 15);
			KvGetString(g_var32576, "title", var68, 50, "NULL");
			AddMenuItem(arg12, var16, var68, 0);
		}
		while (KvGotoNextKey(g_var32576, true));
		KvRewind(g_var32576);
	}
}

Func1636308(arg12, const String:arg16[], Handle:arg20) // address: 1636308
{
	if (KvJumpToKey(g_var32576, arg16, false))
	{
		if (KvGotoFirstSubKey(g_var32576, true))
		{
			decl String:var52[52];
			decl String:var116[64];
			do
			{
				KvGetSectionName(g_var32576, var52, 51);
				if (Func1638632(arg12, arg16, var52))
				{
					FormatEx(var116, 61, "%s [+]", var52);
					AddMenuItem(arg20, var52, var116, 1);
				}
				else
				{
					AddMenuItem(arg20, var52, var52, 0);
				}
			}
			while (KvGotoNextKey(g_var32576, true));
			KvRewind(g_var32576);
		}
	}
}

bool:Func1638632(arg12, const String:arg16[], const String:arg20[]) // address: 1638632
{
	new bool:var4 = false;
	new var8 = GetClientOfUserId(g_var12088[arg12][E2_var1]);
	if (var8 < 1)
	{
		var4 = true;
	}
	if (KvJumpToKey(g_var32584[var8], arg16, false))
	{
		if (KvJumpToKey(g_var32584[var8], arg20, false))
		{
			new var12 = KvGetNum(g_var32584[var8], "time", 0);
			if (var12 && var12 < GetTime())
			{
				Func1632396(var8, arg16, arg20, 0);
				Func1599824(var8, arg16, 1);
				KvDeleteThis(g_var32584[var8]);
			}
			else
			{
				var4 = true;
			}
			KvRewind(g_var32584[var8]);
		}
		KvRewind(g_var32584[var8]);
	}
	return var4;
}

Func1640440(arg12, Handle:arg16) // address: 1640440
{
	if (KvGotoFirstSubKey(g_var32584[arg12], true))
	{
		decl String:var16[16];
		decl String:var68[52];
		do
		{
			KvGetSectionName(g_var32584[arg12], var16, 15);
			if (KvJumpToKey(g_var32576, var16, false))
			{
				KvGetString(g_var32576, "title", var68, 50, "NULL");
				KvRewind(g_var32576);
			}
			AddMenuItem(arg16, var16, var68, 0);
		}
		while (KvGotoNextKey(g_var32584[arg12], false));
	}
	KvRewind(g_var32584[arg12]);
}

Func1642004(arg12, const String:arg16[], Handle:arg20, bool:arg24) // address: 1642004
{
	decl String:var52[52];
	if (KvJumpToKey(g_var32584[arg12], arg16, false))
	{
		if (KvGotoFirstSubKey(g_var32584[arg12], true))
		{
			decl String:var132[80];
			do
			{
				KvGetSectionName(g_var32584[arg12], var52, 51);
				new var136 = KvGetNum(g_var32584[arg12], "time", 0);
				if (var136 && var136 < GetTime())
				{
					Func1632396(arg12, arg16, var52, 0);
					Func1599824(arg12, arg16, 1);
					KvDeleteThis(g_var32584[arg12]);
				}
				else
				{
					if (arg24 && Func1622992(arg12, arg16, var52))
					{
						Func1644592(var132, var52, var136, true);
						AddMenuItem(arg20, var52, var132, 0);
						arg24 = false;
					}
					else
					{
						Func1644592(var132, var52, var136, false);
						AddMenuItem(arg20, var52, var132, 0);
					}
				}
			}
			while (KvGotoNextKey(g_var32584[arg12], true));
			KvRewind(g_var32584[arg12]);
		}
	}
	KvRewind(g_var32584[arg12]);
}

Func1644592(String:arg12[80], const String:arg16[], arg20, bool:arg24) // address: 1644592
{
	if (arg20)
	{
		new var4 = arg20 - GetTime();
		FormatEx(arg12, 80, "%s%s\n[%dдн. %dч. %dм.]\n \n", arg16, arg24 ? " [+]" : "", var4 / 3600 / 24, var4 / 3600 % 24, var4 / 60 % 60);
	}
	else
	{
		FormatEx(arg12, 70, "%s%s\n[Навсегда]\n \n", arg16, arg24 ? " [+]" : "");
	}
}

Func1646368(arg12, const String:arg16[]) // address: 1646368
{
	new var4 = 0;
	if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], false))
	{
		if (KvJumpToKey(g_var32580, arg16, false))
		{
			var4 = KvGetNum(g_var32580, "w", 0);
			KvRewind(g_var32580);
		}
		KvRewind(g_var32580);
	}
	return var4;
}

Func1648240(arg12, arg16[4], const String:arg20[]) // address: 1648240
{
	new bool:var4 = false;
	if (g_var1676 > 0 && KvJumpToKey(g_var32852, g_var1680[arg12][E1_var1], false))
	{
		if (KvJumpToKey(g_var32852, arg20, false))
		{
			arg16[0] = KvGetNum(g_var32852, "w", 0); // Array
			arg16[1] = KvGetNum(g_var32852, "v", 0); // Array
			arg16[2] = KvGetNum(g_var32852, "v_flip", 0); // Array
			KvRewind(g_var32852);
			var4 = true;
		}
		KvRewind(g_var32852);
	}
	if (!var4)
	{
		if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], false))
		{
			if (KvJumpToKey(g_var32580, arg20, false))
			{
				arg16[0] = KvGetNum(g_var32580, "w", 0); // Array
				arg16[1] = KvGetNum(g_var32580, "v", 0); // Array
				if (arg16[1] < 1) // Array
				{
					switch (GetClientTeam(arg12))
					{
						case 2:
						{
							arg16[1] = KvGetNum(g_var32580, "v_t", 0); // Array
						}
						case 3:
						{
							arg16[1] = KvGetNum(g_var32580, "v_ct", 0); // Array
						}
					}
				}
				arg16[2] = KvGetNum(g_var32580, "v_flip", 0); // Array
				arg16[3] = KvGetNum(g_var32580, "time", 0); // Array
				KvRewind(g_var32580);
			}
			KvRewind(g_var32580);
		}
	}
}

Func1650448(arg12, arg16, const String:arg20[]) // address: 1650448
{
	decl String:var8[8];
	decl String:var60[52];
	var8[0] = '\0'; // Array
	IntToString(arg16, var8, 5);
	if (GetTrieString(g_var32856, var8, var60, 50))
	{
		Func1653216(arg12, arg20, var60);
	}
}

bool:Func1651704(arg12, const String:arg16[], String:arg20[50]) // address: 1651704
{
	new bool:var4 = false;
	if (KvJumpToKey(g_var32580, g_var1680[arg12][E1_var1], false))
	{
		if (KvJumpToKey(g_var32580, arg16, false))
		{
			KvGetString(g_var32580, "Name", arg20, 50);
			KvRewind(g_var32580);
			var4 = true;
		}
		KvRewind(g_var32580);
	}
	return var4;
}

Func1653216(arg12, const String:arg16[], const String:arg20[]) // address: 1653216
{
	if (KvJumpToKey(g_var32852, g_var1680[arg12][E1_var1], true))
	{
		if (KvJumpToKey(g_var32852, arg16, true))
		{
			new var20[5];
			GetTrieArray(g_var32848, arg20, var20, 5);
			KvSetNum(g_var32852, "w", var20[0]); // Array
			if (var20[1] < 1) // Array
			{
				switch (GetClientTeam(arg12))
				{
					case 2:
					{
						KvSetNum(g_var32852, "v", var20[2]); // Array
					}
					case 3:
					{
						KvSetNum(g_var32852, "v", var20[3]); // Array
					}
				}
			}
			else
			{
				KvSetNum(g_var32852, "v", var20[1]); // Array
			}
			KvSetNum(g_var32852, "v_flip", var20[4]); // Array
			KvRewind(g_var32852);
		}
		KvRewind(g_var32852);
	}
}

Func1655144(arg12, const String:arg16[]) // address: 1655144
{
	if (KvJumpToKey(g_var32852, g_var1680[arg12][E1_var1], false))
	{
		if (KvJumpToKey(g_var32852, arg16, false))
		{
			KvDeleteThis(g_var32852);
			KvRewind(g_var32852);
		}
		KvRewind(g_var32852);
	}
}

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason) // address: 1656928
{
	if (g_var1676 == 1)
	{
		CreateTimer(delay - 0.7, Timer_DeleteDropModel, _, 2);
	}
}

public OnConVarRestart(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1658444
{
	if (g_var1676 == 1)
	{
		CreateTimer(0.5, Timer_DeleteDropModel, 0, 2);
	}
}

public Action:Timer_DeleteDropModel(Handle:timer) // address: 1659796
{
	if (g_var32852)
	{
		CloseHandle(g_var32852);
		g_var32852 = CreateKeyValues("Drop");
	}
}

Func1661392(arg12) // address: 1661392
{
	if (KvJumpToKey(g_var32852, g_var1680[arg12][E1_var1], false))
	{
		KvDeleteThis(g_var32852);
		KvRewind(g_var32852);
	}
}

Func1662864(const String:arg12[]) // address: 1662864
{
	new Handle:var4 = OpenFile(arg12, "r");
	if (var4 == INVALID_HANDLE)
	{
		return false;
	}
	new String:var260[256];
	while (!IsEndOfFile(var4))
	{
		ReadFileLine(var4, var260, 256);
		new var264 = 0;
		var264 = StrContains(var260, "//", true);
		if (var264 != -1)
		{
			var260[var264] = '\0';
		}
		var264 = StrContains(var260, "#", true);
		if (var264 != -1)
		{
			var260[var264] = '\0';
		}
		var264 = StrContains(var260, ";", true);
		if (var264 != -1)
		{
			var260[var264] = '\0';
		}
		TrimString(var260);
		if (var260[0] == '\0') // Array
		{
			continue;
		}
		Func1665392(var260, 1);
	}
	CloseHandle(var4);
	return true;
}

Func1665392(String:arg12[], arg16) // address: 1665392
{
	if (arg12[0] == '\0') // Array
	{
		return;
	}
	new var4 = strlen(arg12) + -1;
	if (arg12[var4] == '\\' || arg12[var4] == '/')
	{
		arg12[var4] = '\0';
	}
	if (FileExists(arg12, false))
	{
		decl String:var8[4];
		Func1669036(arg12, var8, 4);
		if (StrEqual(var8, "bz2", false) || StrEqual(var8, "ztmp", false))
		{
			return;
		}
		if (StrEqual(var8, "txt", false) || StrEqual(var8, "ini", false))
		{
			Func1662864(arg12);
			return;
		}
		AddFileToDownloadsTable(arg12);
	}
	else
	{
		if (arg16 && DirExists(arg12))
		{
			decl String:var260[256];
			new Handle:var264 = OpenDirectory(arg12);
			while (ReadDirEntry(var264, var260, 256))
			{
				if (StrEqual(var260, ".", true) || StrEqual(var260, "..", true))
				{
					continue;
				}
				Format(var260, 256, "%s/%s", arg12, var260);
				Func1665392(var260, arg16);
			}
			CloseHandle(var264);
		}
		else
		{
			if (FindCharInString(arg12, '*', true))
			{
				decl String:var8[4];
				Func1669036(arg12, var8, 4);
				if (StrEqual(var8, "*", true))
				{
					decl String:var264[256];
					decl String:var520[256];
					decl String:var776[256];
					Func1670368(arg12, var264, 256);
					Func1671924(arg12, var520, 256);
					StrCat(var520, 256, ".");
					new Handle:var780 = OpenDirectory(var264);
					while (ReadDirEntry(var780, var776, 256))
					{
						if (StrEqual(var776, ".", true) || StrEqual(var776, "..", true))
						{
							continue;
						}
						if (strncmp(var776, var520, strlen(var520), true) == 0)
						{
							Format(var776, 256, "%s/%s", var264, var776);
							Func1665392(var776, arg16);
						}
					}
					CloseHandle(var780);
				}
			}
		}
	}
}

Func1669036(const String:arg12[], String:arg16[], arg20) // address: 1669036
{
	new var4 = FindCharInString(arg12, '.', true);
	if (var4 == -1)
	{
		arg16[0] = '\0'; // Array
		return;
	}
	strcopy(arg16, arg20, arg12[++var4]);
}

Func1670368(const String:arg12[], String:arg16[], arg20) // address: 1670368
{
	if (arg12[0] == '\0') // Array
	{
		arg16[0] = 0; // Array
		return;
	}
	new var4 = FindCharInString(arg12, '/', true);
	if (var4 == -1)
	{
		var4 = FindCharInString(arg12, '\\', true);
		if (var4 == -1)
		{
			arg16[0] = 0; // Array
			return;
		}
	}
	strcopy(arg16, arg20, arg12);
	arg16[var4] = '\0';
}

Func1671924(const String:arg12[], String:arg16[], arg20) // address: 1671924
{
	if (arg12[0] == '\0') // Array
	{
		arg16[0] = '\0'; // Array
		return;
	}
	Func1673684(arg12, arg16, arg20);
	new var4 = FindCharInString(arg16, '.', true);
	if (var4 != -1)
	{
		arg16[var4] = '\0';
	}
}

Func1673684(const String:arg12[], String:arg16[], arg20) // address: 1673684
{
	if (arg12[0] == '\0') // Array
	{
		arg16[0] = '\0'; // Array
		return;
	}
	new var4 = FindCharInString(arg12, '/', true);
	if (var4 == -1)
	{
		var4 = FindCharInString(arg12, '\\', true);
	}
	var4++;
	strcopy(arg16, arg20, arg12[var4]);
}

bool:Func1675440(const String:arg12[], const String:arg16[]) // address: 1675440
{
	if (KvJumpToKey(g_var32576, arg16, false))
	{
		if (KvJumpToKey(g_var32576, arg12, false))
		{
			KvRewind(g_var32576);
			return false;
		}
		KvRewind(g_var32576);
	}
	return true;
}

Func1677348(const String:arg12[], String:arg16[], arg20) // address: 1677348
{
	arg20--;
	new var4 = 0;
	while (arg12[var4] || var4 < arg20)
	{
		if (IsCharUpper(arg12[var4]))
		{
			arg16[var4] = CharToLower(arg12[var4]);
		}
		else
		{
			arg16[var4] = arg12[var4];
		}
		var4++;
	}
	arg16[var4] = 0;
}
