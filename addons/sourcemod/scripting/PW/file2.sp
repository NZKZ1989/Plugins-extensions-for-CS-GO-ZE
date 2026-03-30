// Decompilation by Maxim "Kailo" Telezhenko, 2018

new g_var1676 = 0; // address: 1676 // codestart: 0
enum struct E1
{
    char E1_var1[16];
    int E1_var2;
}
new g_var1680[66][E1]; // address: 1676 // zero // codestart: 0
new g_var6432[66][2]; // address: 6432 // zero // codestart: 0
new g_var7224 = 0; // address: 7224 // codestart: 0
new g_var7228 = 0; // address: 7228 // codestart: 0
new g_var7232 = 0; // address: 7232 // codestart: 0
new g_var7236 = 0; // address: 7236 // codestart: 0
new g_var7240[66]; // address: 7240 // zero // codestart: 0
new g_var7504[66]; // address: 7504 // zero // codestart: 0
new g_var7768[66]; // address: 7768 // zero // codestart: 0
new g_var8032[66]; // address: 8032 // zero // codestart: 0
new g_var8296[66]; // address: 8296 // zero // codestart: 0
new g_var8560[66]; // address: 8560 // zero // codestart: 0
new Float:g_var8824[66]; // address: 8824 // zero // codestart: 0
new Float:g_var9088[66]; // address: 9088 // zero // codestart: 0
new g_var9352[66] = {1, ...}; // address: 9352 // codestart: 0
new g_var9616[66][2]; // address: 9616 // zero // codestart: 0
new g_var10408[66]; // address: 9616 // zero // codestart: 0
// 10672 global address

Func1498260() // address: 1498260
{
	if (GetEngineVersion() == EngineVersion:2)
	{
		HookEvent("player_team", OnPlayerDeath, EventHookMode_Post);
		g_var7228 = 3;
	}
	else
	{
		g_var7228 = 4;
	}
	g_var7232 = FindSendPropOffs("CBasePlayer", "m_hMyWeapons");
	g_var7224 = FindStringTable("modelprecache");
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Post);
	HookEvent("bomb_planted", OnBombPlanted, EventHookMode_Post);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	for (new var4 = 1; var4 <= MaxClients; var4++)
	{
		if (IsClientConnected(var4) && IsClientInGame(var4))
		{
			OnClientPutInServer(var4);
			g_var6432[var4][0] = GetEntPropEnt(var4, Prop_Send, "m_hViewModel", 0);
			new var8 = MaxClients + 1;
			while ((var8 = FindEntityByClassname(var8, "predicted_viewmodel")) != -1)
			{
				if (Func1492128(var8) == var4)
				{
					if (Func1490860(var8) == 1)
					{
						g_var6432[var4][1] = var8; // Array
						break;
					}
				}
			}
		}
	}
	new Handle:var4 = CreateConVar("sm_weapons_restrict", "0", "Если игрок поднял оружие со скином. 0 - отключить. 1 - удалить скин в след раунде. 2 - удалить скин если умер.", 0, true, 0.0, true, 2.0);
	g_var1676 = GetConVarInt(var4);
	HookConVarChange(var4, OnConVarChangeRestrict);
	CloneHandle(var4, INVALID_HANDLE);
}

public OnConVarChangeRestrict(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1500888
{
	g_var1676 = StringToInt(newValue, 10);
}

Func1500944() // address: 1500944
{
	for (new var4 = 1; var4 <= MaxClients; var4++)
	{
		for (new var8 = 0; var8 < 2; var8++)
		{
			if (g_var9616[var4][var8] > 0 && IsValidEdict(g_var9616[var4][var8]))
			{
				AcceptEntityInput(g_var9616[var4][var8], "kill", -1, -1, 0);
			}
		}
		if (g_var7504[var4] && IsClientInGame(var4))
		{
			Func1482604(g_var6432[var4][1], 32); // Array
			Func1484924(g_var6432[var4][0], 32);
		}
	}
}

public OnEntityCreated(entity, const String:classname[]) // address: 1503416
{
	if (StrEqual(classname, "predicted_viewmodel", false))
	{
		SDKHook(entity, SDKHookType:24, OnEntitySpawned);
	}
	else
	{
		if (StrContains(classname, "_projectile", false) != -1)
		{
			SDKHook(entity, SDKHookType:24, OnProjectileSpawned);
		}
		else
		{
			if (StrContains(classname, "weapon_", false) == 0)
			{
				SDKHook(entity, SDKHookType:24, OnWeaponSpawn);
			}
		}
	}
}

public OnEntitySpawned(entity) // address: 1504884
{
	new var4 = Func1492128(entity);
	if (0 < var4 <= MaxClients)
	{
		switch (Func1490860(entity))
		{
			case 0:
			{
				g_var6432[var4][0] = entity;
			}
			case 1:
			{
				g_var6432[var4][1] = entity; // Array
			}
		}
	}
}

public OnProjectileSpawned(entity) // address: 1506620
{
	new var4 = Func1475280(entity);
	if (Func1548220(var4) && g_var7768[var4])
	{
		new var8 = Func1473928(var4);
		if (var8 != -1)
		{
			Func1516124(var8, entity);
		}
	}
}

public OnWeaponSpawn(entity) // address: 1507928
{
	Func1496576(entity, 0);
}

public OnBombPlanted(Handle:event, const String:name[], bool:dontBroadcast) // address: 1509348
{
	new var4 = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!var4 || !g_var7768[var4])
	{
		return;
	}
	new var8 = FindEntityByClassname(MaxClients + 1, "planted_c4");
	if (var8 != -1)
	{
		new var12 = Func1631052(var4);
		if (var12 != -1)
		{
			decl String:var268[256];
			var268[0] = '\0'; // Array
			ReadStringTable(g_var7224, var12, var268, 256);
			if (var268[0]) // Array
			{
				SetEntityModel(var8, var268);
			}
		}
	}
}

public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) // address: 1511448
{
	new var4 = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!var4)
	{
		return;
	}
	if (IsClientInGame(var4) && IsPlayerAlive(var4) && !IsClientObserver(var4))
	{
		g_var7240[var4] = 1;
	}
}

public OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast) // address: 1512920
{
	for (new var4 = 1; var4 <= MaxClients; var4++)
	{
		g_var10408[var4] = 0;
		for (new var8 = 0; var8 < 2; var8++)
		{
			g_var9616[var4][var8] = 0;
		}
	}
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) // address: 1514464
{
	new var4 = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!var4 || !IsClientInGame(var4) || IsPlayerAlive(var4))
	{
		return;
	}
	Func1534408(var4);
}

Func1516124(arg12, arg16) // address: 1516124
{
	new var4 = Func1495348(arg12);
	if (var4 > 0)
	{
		decl String:var260[256];
		var260[0] = '\0'; // Array
		ReadStringTable(g_var7224, var4, var260, 256);
		if (var260[0]) // Array
		{
			SetEntityModel(arg16, var260);
		}
	}
}

public OnWeaponDropPost(client, weapon) // address: 1517484
{
	if (g_var7768[client] && weapon > 0)
	{
		new var4 = Func1495348(weapon);
		decl String:var36[32];
		GetEdictClassname(weapon, var36, 32);
		new var40 = Func1546656(var36);
		new var44 = Func1646368(client, var36[var40]);
		if (g_var1676 > 0 && var4 > 0 && var44 != var4)
		{
			Func1655144(client, var36[var40]);
		}
		if (var4 > 0)
		{
			CreateTimer(0.0, Timer_SetWorldModel, EntIndexToEntRef(weapon), 2);
		}
	}
}

public Action:CS_OnCSWeaponDrop(client, weaponIndex) // address: 1519668
{
	if (g_var7768[client])
	{
		new var4 = Func1495348(weaponIndex);
		decl String:var36[32];
		GetEdictClassname(weaponIndex, var36, 32);
		new var40 = Func1546656(var36);
		new var44 = Func1646368(client, var36[var40]);
		if (g_var1676 > 0 && var4 > 0 && var44 != var4)
		{
			Func1655144(client, var36[var40]);
		}
		if (var4 > 0)
		{
			CreateTimer(0.0, Timer_SetWorldModel, EntIndexToEntRef(weaponIndex), 2);
		}
	}
}

public Action:Timer_SetWorldModel(Handle:timer, any:data) // address: 1521604
{
	new var4 = EntRefToEntIndex(data);
	if (var4 != -1)
	{
		new var8 = Func1495348(var4);
		if (var8 > 0 && GetEntProp(var4, Prop_Data, "m_iState", 4, 0) == 0)
		{
			SetEntProp(var4, Prop_Send, "m_iWorldModelIndex", var8, 4, 0);
		}
	}
	return Action:4;
}

Func1522832(arg12) // address: 1522832
{
	new var4 = Func1471064(arg12);
	new var8 = 0;
	if (var4 & 64)
	{
		if (!(g_var10408[arg12] & 64))
		{
			if (g_var9616[arg12][0] > 0 && IsValidEdict(g_var9616[arg12][0]))
			{
				AcceptEntityInput(g_var9616[arg12][0], "kill", -1, -1, 0);
			}
			g_var9616[arg12][0] = 0;
			new var12 = GetPlayerWeaponSlot(arg12, 0);
			if (var12 != -1)
			{
				Func1526428(arg12, var12, 0, "primary");
			}
		}
	}
	else
	{
		if (g_var10408[arg12] & 64)
		{
			if (g_var9616[arg12][0] > 0 && IsValidEdict(g_var9616[arg12][0]))
			{
				AcceptEntityInput(g_var9616[arg12][0], "kill", -1, -1, 0);
			}
			g_var9616[arg12][0] = 0;
		}
	}
	if (var4 & 16)
	{
		if (!(g_var10408[arg12] & 16))
		{
			if (g_var9616[arg12][1] > 0 && IsValidEdict(g_var9616[arg12][1])) // Array; Array
			{
				AcceptEntityInput(g_var9616[arg12][1], "kill", -1, -1, 0); // Array
			}
			g_var9616[arg12][1] = 0; // Array
			new var12 = GetPlayerWeaponSlot(arg12, 4);
			if (var12 != -1)
			{
				Func1526428(arg12, var12, 1, "c4");
			}
		}
	}
	else
	{
		if (g_var10408[arg12] & 16)
		{
			if (g_var9616[arg12][1] > 0 && IsValidEdict(g_var9616[arg12][1])) // Array; Array
			{
				AcceptEntityInput(g_var9616[arg12][1], "kill", -1, -1, 0); // Array
			}
			g_var9616[arg12][1] = 0; // Array
		}
	}
	if (g_var9616[arg12][0])
	{
		var8 = var8 | 64;
	}
	if (g_var9616[arg12][1]) // Array
	{
		var8 = var8 | 16;
	}
	Func1472396(arg12, var4 & ~var8);
	g_var10408[arg12] = var4;
}

Func1526428(arg12, arg16, arg20, const String:arg24[]) // address: 1526428
{
	new var4 = Func1495348(arg16);
	if (g_var7768[arg12] && var4 > 0)
	{
		if (var4 > 20000000)
		{
			Func1496576(arg16, 0);
			return;
		}
		decl String:var260[256];
		var260[0] = '\0'; // Array
		ReadStringTable(g_var7224, var4, var260, 256);
		if (var260[0]) // Array
		{
			g_var9616[arg12][arg20] = CreateEntityByName("prop_dynamic_override", -1);
			DispatchKeyValue(g_var9616[arg12][arg20], "model", var260);
			DispatchKeyValue(g_var9616[arg12][arg20], "spawnflags", "256");
			DispatchKeyValue(g_var9616[arg12][arg20], "solid", "0");
			DispatchSpawn(g_var9616[arg12][arg20]);
			SetEntPropEnt(g_var9616[arg12][arg20], Prop_Send, "m_hOwnerEntity", arg12, 0);
			SetVariantString("!activator");
			AcceptEntityInput(g_var9616[arg12][arg20], "SetParent", arg12, g_var9616[arg12][arg20], 0);
			SetVariantString(arg24);
			AcceptEntityInput(g_var9616[arg12][arg20], "SetParentAttachment", g_var9616[arg12][arg20], -1, 0);
			SDKHook(g_var9616[arg12][arg20], SDKHookType:6, OnTransmit);
		}
	}
}

public Action:OnTransmit(entity, client) // address: 1528976
{
	for (new var4 = 0; var4 < 2; var4++)
	{
		if (g_var9616[client][var4] == entity)
		{
			if (GetEntProp(client, Prop_Send, "m_iObserverMode", 4, 0))
			{
				return Action:0;
			}
			return Action:3;
		}
	}
	new var4 = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", 0);
	if (GetEntProp(client, Prop_Send, "m_iObserverMode", 4, 0) == g_var7228 && var4 == GetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0))
	{
		return Action:3;
	}
	return Action:0;
}

Func1530316(arg12) // address: 1530316
{
	if (g_var7236 == 20)
	{
		SDKHook(arg12, SDKHookType:31, OnWeaponDropPost);
	}
	SDKHook(arg12, SDKHookType:20, OnPostThinkPost);
	SDKHook(arg12, SDKHookType:32, OnWeaponEquipPost);
}

Func1532380(arg12) // address: 1532380
{
	for (new var4 = 0; var4 < 2; var4++)
	{
		if (g_var9616[arg12][var4] > 0 && IsValidEdict(g_var9616[arg12][var4]))
		{
			AcceptEntityInput(g_var9616[arg12][var4], "kill", -1, -1, 0);
		}
		g_var9616[arg12][var4] = 0;
	}
	g_var7768[arg12] = 0;
}

Func1534408(arg12) // address: 1534408
{
	if (g_var7768[arg12] && IsClientInGame(arg12))
	{
		if (g_var7236 == 20)
		{
			for (new var4 = 0, var8 = -1; var4 < 188; var4 = var4 + 4)
			{
				var8 = GetEntDataEnt2(arg12, g_var7232 + var4);
				if (var8 || !IsValidEdict(var8) || Func1495348(var8) < 1)
				{
					continue;
				}
				CreateTimer(0.0, Timer_SetWorldModel, EntIndexToEntRef(var8), 2);
			}
		}
		if (g_var1676 == 2)
		{
			Func1661392(arg12);
		}
	}
}
