// Decompilation by Maxim "Kailo" Telezhenko, 2018

new Handle:g_var1404[4]; // address: 1404 // zero // codestart: 0
new Handle:g_var1420 = INVALID_HANDLE; // address: 1420 // codestart: 0
new Handle:g_var1424 = INVALID_HANDLE; // address: 1424 // codestart: 0
new String:g_var1428[3][8] = {"all", "awp", "knife"}; // address: 1428 // codestart: 0
new g_var1464[3]; // address: 1464 // zero // codestart: 0
new g_var1476[4]; // address: 1476 // zero // codestart: 0
new g_var1492[3]; // address: 1492 // zero // codestart: 0

Func1472636() // address: 1472636
{
	g_var1420 = CreateTrie();
	g_var1424 = CreateTrie();
	for (new var4 = 0; var4 < 4; var4++)
	{
		g_var1404[var4] = CreateArray(15, 0);
	}
	new Handle:var4 = CreateKeyValues("Bonus");
	if (!FileToKeyValues(var4, "addons/sourcemod/data/skins_weapons/bonus_weapons.txt"))
	{
		SetFailState("File not found data/skins_weapons/bonus_weapons.txt");
		return;
	}
	if (KvJumpToKey(var4, "Random", false))
	{
		if (KvGotoFirstSubKey(var4, false))
		{
			decl String:var20[16];
			decl String:var72[52];
			new var76 = 0;
			do
			{
				if (KvGetSectionName(var4, var20, 15) && var20[0]) // Array
				{
					KvGetString(var4, NULL_STRING, var72, 51);
					if (!strcmp(var20, "kills", true))
					{
						var76 = 0;
						g_var1464[var76] = StringToInt(var72, 10);
						continue;
					}
					else
					{
						if (!strcmp(var20, "kills_awp", true))
						{
							var76 = 1;
							g_var1464[var76] = StringToInt(var72, 10);
							continue;
						}
						else
						{
							if (!strcmp(var20, "kills_knife", true))
							{
								var76 = 2;
								g_var1464[var76] = StringToInt(var72, 10);
								continue;
							}
						}
					}
					new var80 = FindStringInArray(g_var1404[var76], var72);
					if (var80 == -1)
					{
						if (var76 == 0)
						{
							PushArrayString(g_var1404[3], var20); // Array
						}
						PushArrayString(g_var1404[var76], var72);
					}
					else
					{
						SetArrayString(g_var1404[var76], var80, var72);
					}
				}
			}
			while (KvGotoNextKey(var4, false));
			KvGoBack(var4);
		}
		KvGoBack(var4);
	}
	if (KvJumpToKey(var4, "Time", false))
	{
		for (new var8 = 0; var8 < 3; var8++)
		{
			g_var1476[var8] = KvGetNum(var4, g_var1428[var8], 1) * 3600;
		}
		g_var1476[3] = KvGetNum(var4, "none", 1) * 3600; // Array
		KvRewind(var4);
	}
	if (KvJumpToKey(var4, "Motd", false))
	{
		if (KvGotoFirstSubKey(var4, false))
		{
			decl String:var516[512];
			decl String:var568[52];
			do
			{
				if (KvGetSectionName(var4, var568, 51) && var568[0]) // Array
				{
					KvGetString(var4, NULL_STRING, var516, 512);
					SetTrieString(g_var1420, var568, var516, true);
				}
			}
			while (KvGotoNextKey(var4, false));
			KvGoBack(var4);
		}
		KvRewind(var4);
	}
	if (KvJumpToKey(var4, "Sound", false))
	{
		decl String:var264[260];
		decl String:var276[12];
		for (new var280 = 0; var280 <= 3; var280++)
		{
			var264[0] = '\0'; // Array
			FormatEx(var276, 9, "%s", var280 < 3 ? g_var1428[var280] : "nextmap");
			KvGetString(var4, var276, var264, 257);
			if (var264[0]) // Array
			{
				SetTrieString(g_var1424, var276, var264, true);
			}
		}
	}
	CloseHandle(var4);
}

Func1476732(arg12, arg16) // address: 1476732
{
	for (new var4 = arg12; var4 < arg16; var4++)
	{
		g_var1492[var4] = 0;
		new var8 = GetArraySize(g_var1404[var4]);
		new var12[var8];
		for (new var16 = 0; var16 < var8; var16++)
		{
			var12[var16] = var16;
		}
		SortIntegers(var12, var8, SortOrder:2);
		SetTrieArray(g_var1420, g_var1428[var4], var12, var8, true);
	}
}

Func1478144(const String:arg12[], String:arg16[15], String:arg20[51]) // address: 1478144
{
	new var4 = -1;
	for (new var8 = 0; var8 < 3; var8++)
	{
		if (!strcmp(arg12, g_var1428[var8], true))
		{
			var4 = var8;
			break;
		}
	}
	if (var4 == -1)
	{
		return;
	}
	new var8 = GetArraySize(g_var1404[var4]);
	if (var8 < 1)
	{
		return;
	}
	if (g_var1492[var4] >= var8)
	{
		Func1476732(var4, var4 + 1);
	}
	new var12[var8];
	strcopy(arg16, 15, g_var1428[var4]);
	if (GetTrieArray(g_var1420, arg16, var12, var8))
	{
		new var16 = var12[g_var1492[var4]];
		GetArrayString(g_var1404[var4], var16, arg20, 51);
		g_var1492[var4]++;
		if (!var4)
		{
			GetArrayString(g_var1404[3], var16, arg16, 15); // Array
		}
	}
}
