// Decompilation by Maxim "Kailo" Telezhenko, 2018

new bool:g_var1708[66]; // address: 1708 // zero // codestart: 0
// 1972 global address

Func1481064(arg12, arg16) // address: 1481064
{
	new var4 = 0;
	for (new var8 = 1; var8 <= MaxClients; var8++)
	{
		if (IsClientInGame(var8) && !IsClientSourceTV(var8))
		{
			var4++;
		}
		g_var1708[var8] = false;
	}
	arg12 = var4 < arg12 ? var4 : arg12;
	arg16 = arg12 < arg16 ? arg12 : arg16;
	new var8[arg12 + 1];
	for (new var12 = 0; var12 < arg12; var12++)
	{
		var8[var12] = Func1483452();
	}
	SortIntegers(var8, arg12, SortOrder:2);
	decl String:var1032[1024];
	var1032[0] = 0; // Array
	for (new var1036 = 0; var1036 < arg16; var1036++)
	{
		if (IsClientInGame(var8[var1036]))
		{
			if (var1036 < 1)
			{
				GetClientName(var8[var1036], var1032, 1024);
			}
			else
			{
				Format(var1032, 1024, "%s, %N", var1032, var8[var1036]);
			}
			Func1505608(var8[var1036], "all", 0, true);
		}
	}
	PrintCenterTextAll("ИГРОКИ %s ВЫИГРАЛИ ОРУЖИЯ!", var1032);
	new Handle:var1036 = INVALID_HANDLE;
	CreateDataTimer(0.1, Timer_PrintCenter, var1036, 1);
	WritePackString(var1036, var1032);
	PrintToChatAll("[P.W] Игроки %s выиграли оружия!", var1032);
	decl String:var1296[260];
	if (GetTrieString(g_var1424, "all", var1296, 257))
	{
		EmitSoundToAll(var1296, -2, 6, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}
}

Func1483452() // address: 1483452
{
	new var4 = 0;
	new Float:var8[MaxClients + 1];
	new Float:var12 = 0.0;
	for (new var16 = 1; var16 <= MaxClients; var16++)
	{
		if (IsClientInGame(var16) && !IsClientSourceTV(var16) && !g_var1708[var16])
		{
			var8[var16] = CalculatorKpd(var16);
			if (var12 <= var8[var16])
			{
				var4 = var16;
				var12 = var8[var16];
			}
		}
	}
	g_var1708[var4] = true;
	return var4;
}
