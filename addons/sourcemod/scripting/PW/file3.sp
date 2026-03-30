// Decompilation by Maxim "Kailo" Telezhenko, 2018

new g_var11396[66]; // address: 11396 // zero // codestart: 0 // end address: 11660

public OnPostThinkPost(client) // address: 1536368
{
	Func1522832(client);
	new var4 = Func1473928(client);
	if (g_var8560[client] && g_var8560[client] < GetTime() && var4 > 0)
	{
		Func1539832(client, var4);
		return;
	}
	if (!IsValidEdict(g_var6432[client][0]))
	{
		return;
	}
	new var8 = Func1476524(g_var6432[client][0]);
	if (var4 < 1)
	{
		if (g_var7504[client])
		{
			Func1482604(g_var6432[client][1], 32); // Array
			Func1484924(g_var6432[client][0], 32);
			g_var7504[client] = 0;
			g_var8032[client] = 0;
			g_var9088[client] = 0.0;
		}
		g_var8296[client] = var4;
		return;
	}
	new Float:var12 = GetGameTime();
	new Float:var16 = Func1479052(g_var6432[client][0]);
	if (var4 != g_var8296[client] && !Func1541204(client, var4, var8))
	{
		g_var8296[client] = var4;
		return;
	}
	if (g_var7504[client])
	{
		if (IsValidEdict(g_var6432[client][1])) // Array
		{
			Func1488020(g_var6432[client][1], Func1486252(g_var6432[client][0])); // Array
			if (g_var9352[client])
			{
				if (var16 < g_var8824[client] && var8 == g_var8032[client])
				{
					Func1478124(g_var6432[client][1], 0); // Array
					g_var9088[client] = 0.02 + var12;
				}
				else
				{
					if (g_var9088[client] < var12)
					{
						Func1478124(g_var6432[client][1], var8); // Array
					}
				}
			}
			else
			{
				if (var8 != g_var8032[client])
				{
					g_var9352[client] = 1;
				}
			}
		}
	}
	if (g_var7240[client])
	{
		g_var7240[client] = 0;
		if (g_var7504[client])
		{
			Func1482604(g_var6432[client][0], 32);
		}
	}
	g_var8296[client] = var4;
	g_var8032[client] = var8;
	g_var8824[client] = var16;
}

Func1539832(arg12, arg16) // address: 1539832
{
	decl String:var32[32];
	decl String:var84[50];
	GetEdictClassname(arg16, var32, 32);
	new var88 = Func1546656(var32);
	if (Func1651704(arg12, var32[var88], var84))
	{
		Func1632396(arg12, var32[var88], var84, 1);
		Func1541204(arg12, arg16, Func1476524(g_var6432[arg12][0]));
		PrintToChat(arg12, "[Skins Weapons] < %s > удален по истечению времени!", var84);
	}
	g_var8560[arg12] = 0;
}

Func1541204(arg12, arg16, arg20) // address: 1541204
{
	g_var9088[arg12] = 0.0;
	new var4 = 0;
	if (!var4)
	{
		new var8 = 0;
		if (g_var7768[arg12])
		{
			decl String:var40[32];
			GetEdictClassname(arg16, var40, 32);
			new var44 = Func1546656(var40);
			new var60[4];
			Func1648240(arg12, var60, var40[var44]);
			if (var60[1]) // Array
			{
				g_var8560[arg12] = var60[3]; // Array
				if (IsValidEdict(g_var6432[arg12][1])) // Array
				{
					Func1482604(g_var6432[arg12][0], 32);
					Func1484924(g_var6432[arg12][1], 32); // Array
					Func1478124(g_var6432[arg12][1], arg20); // Array
					Func1488988(g_var6432[arg12][1], var60[1]); // Array; Array
					g_var11396[arg12] = var60[1]; // Array
					Func1478124(g_var6432[arg12][1], arg20); // Array
					if (var60[2] && strcmp(var40[var44], "c4", true)) // Array
					{
						new var64 = GetPlayerWeaponSlot(arg12, 2);
						if (var64 != -1)
						{
							Func1493752(g_var6432[arg12][1], var64); // Array
						}
					}
					else
					{
						Func1493752(g_var6432[arg12][1], arg16); // Array
					}
					Func1478124(g_var6432[arg12][1], arg20); // Array
					Func1488020(g_var6432[arg12][1], Func1486252(g_var6432[arg12][0])); // Array
					g_var7504[arg12] = 1;
					var4 = 1;
				}
			}
			else
			{
				g_var8560[arg12] = 0;
			}
			var8 = var60[0]; // Array
		}
		if (!var4 && g_var7504[arg12])
		{
			Func1484924(g_var6432[arg12][0], 32);
			if (IsValidEdict(g_var6432[arg12][1])) // Array
			{
				Func1482604(g_var6432[arg12][1], 32); // Array
				Func1478124(g_var6432[arg12][1], 0); // Array
			}
			g_var7504[arg12] = 0;
			g_var9088[arg12] = 0.0;
		}
		if (var8 > 0)
		{
			SetEntProp(arg16, Prop_Send, "m_iWorldModelIndex", var8, 4, 0);
		}
		Func1496576(arg16, var8);
	}
	return var4;
}

public OnWeaponEquipPost(client, weapon) // address: 1544836
{
	if (g_var7768[client])
	{
		decl String:var32[32];
		GetEdictClassname(weapon, var32, 32);
		new var36 = Func1546656(var32);
		new var40 = Func1646368(client, var32[var36]);
		new var44 = Func1495348(weapon);
		if (g_var1676 > 0 && var44 > 0 && var44 != var40)
		{
			Func1650448(client, var44, var32[var36]);
			SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", var44, 4, 0);
			Func1496576(weapon, var44);
		}
		else
		{
			if (var40 > 0)
			{
				SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", var40, 4, 0);
				Func1496576(weapon, var40);
			}
		}
	}
}

Func1546656(const String:arg12[]) // address: 1546656
{
	new var4 = 0;
	if (StrContains(arg12, "weapon_", false) == 0)
	{
		var4 = 7;
	}
	return var4;
}
