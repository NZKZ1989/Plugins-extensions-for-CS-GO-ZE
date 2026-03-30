// Decompilation by Maxim "Kailo" Telezhenko, 2018

new Handle:g_var33564 = INVALID_HANDLE; // address: 33564
new g_var33568[66]; // address: 33568
new g_var33832 = 604800; // address: 33832
// global address 33836

Func1679324() // address: 1679324
{
	decl String:var256[256];
	g_var33564 = SQL_Connect("Skins_Weapons", true, var256, 256);
	if (g_var33564 == INVALID_HANDLE)
	{
		SetFailState(var256);
		return;
	}
	decl String:var264[8];
	SQL_ReadDriver(g_var33564, var264, 7);
	if (!StrEqual(var264, "mysql", false))
	{
		SQL_TQuery(g_var33564, SQL_DefCallback, "CREATE TABLE IF NOT EXISTS `user` (custom_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, auth VARCHAR(25), lastconnect TIMESTAMP, name VARCHAR(65), status INTEGER, UNIQUE (auth));", 0, DBPrio_Normal);
		SQL_TQuery(g_var33564, SQL_DefCallback, "CREATE TABLE IF NOT EXISTS `weapons` (order_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, custom_id INTEGER, name_weapon VARCHAR(50), weapon VARCHAR(15), time TIMESTAMP, active INTEGER, FOREIGN KEY(custom_id) REFERENCES user(custom_id));", 0, DBPrio_Normal);
		SQL_TQuery(g_var33564, SQL_DefCallback, "CREATE TABLE IF NOT EXISTS `listing` (name_list VARCHAR(50) PRIMARY KEY, weapon_list VARCHAR(20));", 0, DBPrio_Normal);
	}
	else
	{
		SQL_TQuery(g_var33564, SQL_DefCallback, "CREATE TABLE IF NOT EXISTS `user` (custom_id INT(16) NOT NULL AUTOINCREMENT, auth CHAR(25), lastconnect TIMESTAMP, name CHAR(65), status TINYINT(1), PRIMARY KEY(custom_id), UNIQUE (auth));", 0, DBPrio_Normal);
		SQL_TQuery(g_var33564, SQL_DefCallback, "CREATE TABLE IF NOT EXISTS `weapons` (order_id INT(16) AUTOINCREMENT NOT NULL, custom_id INT(16), name_weapon CHAR(51), weapon CHAR(16), time TIMESTAMP, active TINYINT(1), PRIMARY KEY(order_id), FOREIGN KEY(custom_id) REFERENCES user(custom_id));", 0, DBPrio_Normal);
		SQL_TQuery(g_var33564, SQL_DefCallback, "CREATE TABLE IF NOT EXISTS `listing` (name_list CHAR(51) PRIMARY KEY, weapon_list CHAR(21));", 0, DBPrio_Normal);
	}
	HookConVarChange(CreateConVar("sm_skins_lastconnect", "7", "Удаляет игрока из базы в случае не активности n дней. 0 - Выключить", 0, false, 0.0, false, 0.0), Cvar_LastConnect_BD);
}

public SQL_DefCallback(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1681532
{
	if (hndl == INVALID_HANDLE)
	{
		LogError(error);
	}
}

public Cvar_LastConnect_BD(Handle:convar, const String:oldValue[], const String:newValue[]) // address: 1683040
{
	new var4 = StringToInt(newValue, 10);
	g_var33832 = var4 > 0 ? (var4 * 86400) : 0;
}

Func1685040(arg12, const String:arg16[]) // address: 1685040
{
	if (arg12 < 1 || IsClientSourceTV(arg12))
	{
		return;
	}
	Func1610108(arg12);
	g_var33568[arg12] = 0;
	decl String:var72[72];
	FormatEx(var72, 70, "SELECT * FROM user WHERE `auth` = '%s'", arg16);
	SQL_TQuery(g_var33564, OnClientPutInServer_ConnectBD, var72, GetClientUserId(arg12), DBPrio_Normal);
}

public OnClientPutInServer_ConnectBD(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1687056
{
	new var4 = GetClientOfUserId(data);
	if (var4 < 1 || hndl == INVALID_HANDLE)
	{
		return;
	}
	decl String:var184[180];
	decl String:var252[68];
	decl String:var320[68];
	GetClientName(var4, var252, 65);
	SQL_EscapeString(g_var33564, var252, var320, 65);
	if (!SQL_FetchRow(hndl))
	{
		g_var33568[var4] = 1;
		decl String:var348[28];
		GetClientAuthString(var4, var348, 28, true);
		FormatEx(var184, 180, "INSERT INTO user (auth, lastconnect, name, status) VALUES ('%s', %d, '%s', '1')", var348, GetTime(), var320);
		SQL_TQuery(g_var33564, SQL_OnClientPutInServer_Insert, var184, GetClientUserId(var4), DBPrio_Normal);
		return;
	}
	g_var1680[var4][E1_var2] = SQL_FetchInt(hndl, 0); // Array
	IntToString(g_var1680[var4][E1_var2], g_var1680[var4][E1_var1], 16); // Array
	g_var7768[var4] = SQL_FetchInt(hndl, 4);
	FormatEx(var184, 180, "UPDATE `user` SET `lastconnect` = %d, `name` = '%s' WHERE `custom_id` = %d", GetTime(), var320, g_var1680[var4][E1_var2]); // Array
	SQL_TQuery(g_var33564, SQL_DefCallback, var184, 0, DBPrio_Normal);
	FormatEx(var184, 180, "SELECT name_weapon, weapon, time, active FROM weapons WHERE `custom_id` = %d", g_var1680[var4][E1_var2]); // Array
	SQL_TQuery(g_var33564, OnClientPutInServer_ConnectWeaponsDB, var184, GetClientUserId(var4), DBPrio_Normal);
}

public SQL_OnClientPutInServer_Insert(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1689856
{
	new var4 = GetClientOfUserId(data);
	if (var4 < 1 || hndl == INVALID_HANDLE)
	{
		return;
	}
	decl String:var32[28];
	GetClientAuthString(var4, var32, 28, true);
	decl String:var104[72];
	FormatEx(var104, 70, "SELECT * FROM `user` WHERE `auth` = '%s'", var32);
	SQL_TQuery(g_var33564, OnClientPutInServer_ConnectBD, var104, GetClientUserId(var4), DBPrio_Normal);
}

public OnClientPutInServer_ConnectWeaponsDB(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1691564
{
	new var4 = GetClientOfUserId(data);
	if (var4 < 1 || hndl == INVALID_HANDLE)
	{
		return;
	}
	decl String:var56[52];
	decl String:var72[16];
	while (SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, var56, 50);
		SQL_FetchString(hndl, 1, var72, 15);
		Func1611648(var4, var72, var56, SQL_FetchInt(hndl, 2), SQL_FetchInt(hndl, 3));
	}
}

Func1693328(arg12, const String:arg16[], const String:arg20[], arg24, bool:arg28) // address: 1693328
{
	new var4 = arg24 > 0 ? (GetTime() + arg24) : 0;
	decl String:var208[204];
	new var212 = (!Func1621172(arg12, arg16)) ? 1 : 0;
	if (arg28)
	{
		FormatEx(var208, 201, "INSERT INTO weapons (custom_id, name_weapon, weapon, time, active) VALUES (%d,'%s','%s',%d,%d)", g_var1680[arg12][E1_var2], arg20, arg16, var4, var212); // Array
	}
	else
	{
		if (var4 > 0)
		{
			var4 = Func1628244(arg12, arg16, arg20);
			var4 = var4 > 0 ? (var4 + arg24) : 0;
		}
		FormatEx(var208, 201, "UPDATE `weapons` SET `time` = %d WHERE `custom_id` = %d AND `name_weapon` = '%s'", var4, g_var1680[arg12][E1_var2], arg20); // Array
	}
	Func1611648(arg12, arg16, arg20, var4, var212);
	SQL_TQuery(g_var33564, SQL_DefCallback, var208, 0, DBPrio_Normal);
}

Func1695224(arg12, const String:arg16[]) // address: 1695224
{
	decl String:var132[132];
	FormatEx(var132, 131, "DELETE FROM `weapons` WHERE `custom_id` = %d AND `name_weapon` = '%s'", g_var1680[arg12][E1_var2], arg16); // Array
	SQL_TQuery(g_var33564, SQL_DefCallback, var132, 0, DBPrio_Normal);
}

Func1696900(arg12, const String:arg16[], const String:arg20[]) // address: 1696900
{
	decl String:var152[152];
	new bool:var156 = false;
	if (Func1621172(arg12, arg16))
	{
		decl String:var208[51];
		Func1629704(arg12, arg16, var208);
		if (!strcmp(var208, arg20, true))
		{
			var156 = true;
		}
		Func1615784(arg12, arg16);
		FormatEx(var152, 150, "UPDATE `weapons` SET `active` = 0 WHERE `custom_id` = %d AND `name_weapon` = '%s'", g_var1680[arg12][E1_var2], var208); // Array
		SQL_TQuery(g_var33564, SQL_DefCallback, var152, 0, DBPrio_Normal);
	}
	new var160 = Func1628244(arg12, arg16, arg20);
	if (var160 != -1 && !var156)
	{
		Func1613552(arg12, arg16, arg20, var160);
		FormatEx(var152, 150, "UPDATE `weapons` SET `active` = 1 WHERE `custom_id` = %d AND `name_weapon` = '%s'", g_var1680[arg12][E1_var2], arg20); // Array
		SQL_TQuery(g_var33564, SQL_DefCallback, var152, 0, DBPrio_Normal);
	}
}

Func1698916(arg12) // address: 1698916
{
	SQL_TQuery(g_var33564, Info_PlayerList_CallBack, "SELECT custom_id, name FROM `user`", GetClientUserId(arg12), DBPrio_Normal);
}

public Info_PlayerList_CallBack(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1699716
{
	new var4 = GetClientOfUserId(data);
	if (var4 < 1 || hndl == INVALID_HANDLE)
	{
		return;
	}
	new Handle:var8 = CreateMenu(SelectPlayerList_DatabaseMenu, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var8, "Выберите Игрока:\n \n");
	SetMenuExitBackButton(var8, true);
	decl String:var76[68];
	decl String:var92[16];
	while (SQL_FetchRow(hndl))
	{
		IntToString(SQL_FetchInt(hndl, 0), var92, 16);
		SQL_FetchString(hndl, 1, var76, 64);
		AddMenuItem(var8, var92, var76, 0);
	}
	DisplayMenu(var8, var4, 0);
}

Func1701436(arg12) // address: 1701436
{
	decl String:var96[96];
	FormatEx(var96, 96, "SELECT auth, name, lastconnect, status FROM user WHERE custom_id = %d;", g_var12088[arg12][E2_var2]); // Array
	SQL_TQuery(g_var33564, InfoPlayerList_Database, var96, GetClientUserId(arg12), DBPrio_Normal);
}

public InfoPlayerList_Database(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1702772
{
	new var4 = GetClientOfUserId(data);
	if (var4 < 1 || hndl == INVALID_HANDLE)
	{
		return;
	}
	decl String:var32[28];
	decl String:var100[68];
	SQL_FetchString(hndl, 0, var32, 28);
	SQL_FetchString(hndl, 1, var100, 65);
	Func1586740(var4, var100, var32, SQL_FetchInt(hndl, 2), SQL_FetchInt(hndl, 3));
}

Func1704704(const String:arg12[], const String:arg16[]) // address: 1704704
{
	decl String:var104[104];
	new Handle:var108 = CreateDataPack();
	WritePackString(var108, arg12);
	WritePackString(var108, arg16);
	FormatEx(var104, 101, "SELECT * FROM listing WHERE `name_list` = '%s'", arg12);
	SQL_TQuery(g_var33564, SetFile_ConnectBD, var104, var108, DBPrio_Normal);
}

public SetFile_ConnectBD(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1706212
{
	ResetPack(data, false);
	if (hndl && !SQL_FetchRow(hndl))
	{
		decl String:var52[52];
		decl String:var68[16];
		decl String:var220[152];
		ReadPackString(data, var52, 50);
		ReadPackString(data, var68, 15);
		FormatEx(var220, 150, "INSERT INTO listing (name_list, weapon_list) VALUES ('%s', '%s')", var52, var68);
		SQL_TQuery(g_var33564, SQL_DefCallback, var220, 0, DBPrio_Normal);
	}
	CloseHandle(data);
}

Func1707620() // address: 1707620
{
	SQL_TQuery(g_var33564, CheckFile_ConnectBD, "SELECT * FROM listing", 0, DBPrio_Normal);
}

public CheckFile_ConnectBD(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1708988
{
	if (hndl == INVALID_HANDLE)
	{
		return;
	}
	decl String:var52[52];
	decl String:var68[16];
	decl String:var204[136];
	while (SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, var52, 50);
		SQL_FetchString(hndl, 1, var68, 15);
		if (Func1675440(var52, var68))
		{
			FormatEx(var204, 135, "DELETE FROM weapons WHERE `name_weapon` = '%s'", var52);
			SQL_TQuery(g_var33564, SQL_DefCallback, var204, 0, DBPrio_Normal);
			FormatEx(var204, 135, "DELETE FROM listing WHERE `name_list` = '%s'", var52);
			SQL_TQuery(g_var33564, SQL_DefCallback, var204, 0, DBPrio_Normal);
		}
	}
}

Func1710740() // address: 1710740
{
	if (g_var33832 > 0)
	{
		Func1712044();
	}
	Func1717108();
}

Func1712044() // address: 1712044
{
	decl String:var76[76];
	FormatEx(var76, 75, "SELECT custom_id FROM user WHERE `lastconnect` < %d", GetTime() - g_var33832);
	SQL_TQuery(g_var33564, CheckTimeClient_ConnectBD, var76, 0, DBPrio_Normal);
}

public CheckTimeClient_ConnectBD(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1713220
{
	if (hndl == INVALID_HANDLE)
	{
		return;
	}
	while (SQL_FetchRow(hndl))
	{
		Func1715456(SQL_FetchInt(hndl, 0));
	}
}

Func1715456(arg12) // address: 1715456
{
	decl String:var68[68];
	FormatEx(var68, 66, "DELETE FROM weapons WHERE `custom_id` = %d", arg12);
	SQL_TQuery(g_var33564, SQL_DefCallback, var68, 0, DBPrio_Normal);
	FormatEx(var68, 66, "DELETE FROM user WHERE `custom_id` = %d", arg12);
	SQL_TQuery(g_var33564, SQL_DefCallback, var68, 0, DBPrio_Normal);
	FormatEx(var68, 66, "DELETE FROM free WHERE `custom_id` = %d", arg12);
	SQL_TQuery(g_var33564, SQL_DefCallback, var68, 0, DBPrio_Normal);
}

Func1717108() // address: 1717108
{
	decl String:var100[100];
	FormatEx(var100, 98, "SELECT order_id FROM weapons WHERE `time` < %d AND `time` <> 0", GetTime());
	SQL_TQuery(g_var33564, CheckTimeWeapons_ConnectBD, var100, 0, DBPrio_Normal);
}

public CheckTimeWeapons_ConnectBD(Handle:owner, Handle:hndl, const String:error[], any:data) // address: 1718224
{
	if (hndl == INVALID_HANDLE)
	{
		return;
	}
	while (SQL_FetchRow(hndl))
	{
		decl String:var72[72];
		FormatEx(var72, 70, "DELETE FROM weapons WHERE `order_id` = %d", SQL_FetchInt(hndl, 0));
		SQL_TQuery(g_var33564, SQL_DefCallback, var72, 0, DBPrio_Normal);
	}
}
