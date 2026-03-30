// Decompilation by Maxim "Kailo" Telezhenko, 2018
new Handle:g_var11820 = INVALID_HANDLE; // address: 11820
new Float:g_var11824[66];               // address: 11824 // zero

enum struct E2
{
    int E2_var1;        // userid
    int E2_var2;        // custom_id
    char E2_var3[15];   // weapon
    char E2_var4[50];   // skin name
} // total size 67 cells // arraysize: 17952 bytes

new E2 g_var12088[66]; // массив структур
new g_var30040[66];    // address: 30040
// 30304 global address

bool:Func1548220(arg12) // address: 1548220
{
	return 0 < arg12 <= MaxClients ? true : false;
}

Func1548308() // address: 1548308
{
	if (LibraryExists("adminmenu"))
	{
		OnAdminMenuReady(GetAdminTopMenu());
	}
	RegConsoleCmd("sm_inv", Command_Inventar, "", 0);
}

public OnAdminMenuReady(Handle:topmenu) // address: 1549664
{
	if (topmenu == INVALID_HANDLE || topmenu == g_var11820)
	{
		return;
	}
	g_var11820 = topmenu;
	new TopMenuObject:var4 = FindTopMenuCategory(g_var11820, "CategoryMuteAndGag");
	if (var4 == TopMenuObject:0)
	{
		var4 = AddToTopMenu(g_var11820, "CategoryMuteAndGag", TopMenuObjectType:0, CallBackMenuParam, TopMenuObject:0, "", 0);
	}
	AddToTopMenu(g_var11820, "addweapon", TopMenuObjectType:1, AddCallBackList, var4, "sm_add", 16384);
	AddToTopMenu(g_var11820, "delweapon", TopMenuObjectType:1, DelCallBackList, var4, "sm_del", 16384);
	AddToTopMenu(g_var11820, "infoweapon", TopMenuObjectType:1, InfoCallBackList, var4, "sm_info", 16384);
}

public CallBackMenuParam(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength) // address: 1551276
{
	if (action == TopMenuAction:0)
	{
		Format(buffer, maxlength, "Персональное оружие");
	}
	else
	{
		if (action == TopMenuAction:1)
		{
			Format(buffer, maxlength, "  Персональное оружие: \n \n");
		}
	}
}

public AddCallBackList(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength) // address: 1552792
{
	if (action == TopMenuAction:0)
	{
		Format(buffer, maxlength, "Добавить оружие \n");
	}
	else
	{
		if (action == TopMenuAction:2)
		{
			Func1557132(param, 0);
		}
	}
}

public DelCallBackList(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength) // address: 1553668
{
	if (action == TopMenuAction:0)
	{
		Format(buffer, maxlength, "Удалить оружие \n");
	}
	else
	{
		if (action == TopMenuAction:2)
		{
			Func1557132(param, 1);
		}
	}
}

public InfoCallBackList(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength) // address: 1555804
{
	if (action == TopMenuAction:0)
	{
		Format(buffer, maxlength, "Информация игроков \n");
	}
	else
	{
		if (action == TopMenuAction:2)
		{
			Func1580896(param);
		}
	}
}

Func1557132(arg12, arg16) // address: 1557132
{
	g_var30040[arg12] = arg16;
	new var4 = 1;
	decl String:var20[16];
	decl String:var88[68];
	new Handle:var92 = CreateMenu(SelectClientMenu, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var92, "Выберите Игрока:\n \n");
	SetMenuExitBackButton(var92, true);
	for (new var96 = 1; var96 <= MaxClients; var96++)
	{
		if (IsClientInGame(var96) && !IsClientSourceTV(var96))
		{
			IntToString(GetClientUserId(var96), var20, 15);
			GetClientName(var96, var88, 65);
			if (IsFakeClient(var96))
			{
				if (var4)
				{
					StrCat(var88, 65, " [BOT]");
					AddMenuItem(var92, var20, var88, 0);
					var4 = 0;
				}
				continue;
			}
			AddMenuItem(var92, var20, var88, 0);
		}
	}
	DisplayMenu(var92, arg12, 0);
}

public SelectClientMenu(Handle:menu, MenuAction:action, param1, param2) // address: 1558940
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			if (param2 == -6)
			{
				if (g_var30040[param1] == 2)
				{
					Func1580896(param1);
				}
				else
				{
					if (g_var11820)
					{
						DisplayTopMenu(g_var11820, param1, TopMenuPosition:3);
					}
				}
			}
		}
		case 4:
		{
			decl String:var16[16];
			GetMenuItem(menu, param2, var16, 16);
			g_var12088[param1][E2_var1] = StringToInt(var16, 10);
			new var20 = GetClientOfUserId(g_var12088[param1][E2_var1]);
			if (var20 > 0)
			{
				switch (g_var30040[param1])
				{
					case 0:
					{
						Func1561708(param1);
					}
					case 1:
					{
						Func1573432(param1);
					}
					case 2:
					{
						g_var12088[param1][E2_var2] = g_var1680[var20][E1_var2]; // Array; Array
						Func1701436(param1);
					}
				}
			}
			else
			{
				PrintToChat(param1, "Игрок не найден или вышел");
			}
		}
	}
}

Func1561708(arg12) // address: 1561708
{
	new Handle:var4 = CreateMenu(SelectWeaponList, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var4, "Выберите оружие:\n \n");
	SetMenuExitBackButton(var4, true);
	Func1634244(var4);
	if (GetMenuItemCount(var4) == 0)
	{
		AddMenuItem(var4, "", "Не найдены модели в файле", 1);
	}
	DisplayMenu(var4, arg12, 0);
}

public SelectWeaponList(Handle:menu, MenuAction:action, param1, param2) // address: 1563228
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			if (param2 == -6)
			{
				Func1557132(param1, 0);
			}
		}
		case 4:
		{
			GetMenuItem(menu, param2, g_var12088[param1][E2_var3], 15); // Array
			Func1564940(param1);
		}
	}
}

Func1564940(arg12) // address: 1564940
{
	new Handle:var4 = CreateMenu(SelectWeaponNameList, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var4, "Выберите скин:\n \n");
	SetMenuExitBackButton(var4, true);
	Func1636308(arg12, g_var12088[arg12][E2_var3], var4); // Array
	if (GetMenuItemCount(var4) == 0)
	{
		AddMenuItem(var4, "", "Не найдены модели в файле", 1);
	}
	DisplayMenu(var4, arg12, 0);
}

public SelectWeaponNameList(Handle:menu, MenuAction:action, param1, param2) // address: 1566588
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			if (param2 == -6)
			{
				Func1561708(param1);
			}
		}
		case 4:
		{
			GetMenuItem(menu, param2, g_var12088[param1][E2_var4], 50); // Array
			Func1568600(param1);
		}
	}
}

Func1568600(arg12) // address: 1568600
{
	new Handle:var4 = CreateMenu(SelectWeaponMenuTime, MENU_ACTIONS_DEFAULT);
	SetMenuExitBackButton(var4, true);
	SetMenuTitle(var4, "Выберите время:\n \n");
	AddMenuItem(var4, "0", "Навсегда", 0);
	AddMenuItem(var4, "5", "5 сек(тест)", 0);
	AddMenuItem(var4, "3600", "1 час", 0);
	AddMenuItem(var4, "86400", "1 день", 0);
	AddMenuItem(var4, "604800", "7 дней", 0);
	AddMenuItem(var4, "2592000", "30 дней", 0);
	AddMenuItem(var4, "5184000", "60 дней", 0);
	AddMenuItem(var4, "7776000", "90 дней", 0);
	DisplayMenu(var4, arg12, 0);
}

public SelectWeaponMenuTime(Handle:menu, MenuAction:action, param1, param2) // address: 1570852
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			if (param2 == -6)
			{
				Func1564940(param1);
			}
		}
		case 4:
		{
			new var4 = GetClientOfUserId(g_var12088[param1][E2_var1]);
			if (var4 > 0)
			{
				decl String:var16[12];
				decl String:var44[28];
				GetMenuItem(menu, param2, var16, 9, _, var44, 25);
				new var48 = StringToInt(var16, 10);
				Func1693328(var4, g_var12088[param1][E2_var3], g_var12088[param1][E2_var4], var48, true); // Array; Array
				Func1599824(var4, g_var12088[param1][E2_var3], 0); // Array
				Func1564940(param1);
				if (var48)
				{
					PrintToChat(var4, "[P.W] Администратор добавил в ваш инвентарь < %s > на %s", g_var12088[param1][E2_var4], var44); // Array
				}
				else
				{
					PrintToChat(var4, "[P.W] Администратор добавил в ваш инвентарь < %s > навсегда", g_var12088[param1][E2_var4]); // Array
				}
			}
			else
			{
				PrintToChat(param1, "Игрок не найден (Вышел с сервера)");
			}
		}
	}
}

Func1573432(arg12) // address: 1573432
{
	new var4 = GetClientOfUserId(g_var12088[arg12][E2_var1]);
	if (var4 < 1)
	{
		PrintToChat(var4, "Игрок не найден (Вышел с сервера)");
		return;
	}
	new Handle:var8 = CreateMenu(SelectWeaponDelete, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var8, "Выберите оружие:\n \n");
	SetMenuExitBackButton(var8, true);
	Func1640440(var4, var8);
	if (GetMenuItemCount(var8) == 0)
	{
		AddMenuItem(var8, "", "У игрока нет оружия", 1);
	}
	DisplayMenu(var8, arg12, 0);
}

public SelectWeaponDelete(Handle:menu, MenuAction:action, param1, param2) // address: 1575092
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			if (param2 == -6)
			{
				Func1557132(param1, 1);
			}
		}
		case 4:
		{
			GetMenuItem(menu, param2, g_var12088[param1][E2_var3], 15); // Array
			Func1576708(param1);
		}
	}
}

Func1576708(arg12) // address: 1576708
{
	new var4 = GetClientOfUserId(g_var12088[arg12][E2_var1]);
	if (var4 < 1)
	{
		PrintToChat(var4, "Игрок не найден (Вышел с сервера)");
		return;
	}
	new Handle:var8 = CreateMenu(SelectWeaponNameDelete, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var8, "Выберите скин:\n \n");
	SetMenuExitBackButton(var8, true);
	Func1642004(var4, g_var12088[arg12][E2_var3], var8, false); // Array
	if (GetMenuItemCount(var8) == 0)
	{
		AddMenuItem(var8, "", "У игрока нет скинов", 1);
		Func1618504(arg12, g_var12088[arg12][E2_var3]); // Array
	}
	DisplayMenu(var8, arg12, 0);
}

public SelectWeaponNameDelete(Handle:menu, MenuAction:action, param1, param2) // address: 1578548
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			if (param2 == -6)
			{
				Func1573432(param1);
			}
		}
		case 4:
		{
			new var4 = GetClientOfUserId(g_var12088[param1][E2_var1]);
			if (var4 > 0)
			{
				GetMenuItem(menu, param2, g_var12088[param1][E2_var4], 51); // Array
				Func1632396(var4, g_var12088[param1][E2_var3], g_var12088[param1][E2_var4], 1); // Array; Array
				Func1576708(param1);
				Func1599824(var4, g_var12088[param1][E2_var3], 1); // Array
				PrintToChat(var4, "[P.W] Администратор удалил из вашего инвентаря < %s >", g_var12088[param1][E2_var4]); // Array
			}
			else
			{
				PrintToChat(param1, "Игрок не найден (Вышел с сервера)");
			}
		}
	}
}

Func1580896(arg12) // address: 1580896
{
	new Handle:var4 = CreateMenu(Info_PlayerListName, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var4, "Каких игроков отобразить?:\n \n");
	SetMenuExitBackButton(var4, true);
	AddMenuItem(var4, "", "Игроков из онлайн", 0);
	AddMenuItem(var4, "", "Игроков из БД", 0);
	DisplayMenu(var4, arg12, 0);
}

public Info_PlayerListName(Handle:menu, MenuAction:action, param1, param2) // address: 1582852
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			if (param2 == -6 && g_var11820)
			{
				DisplayTopMenu(g_var11820, param1, TopMenuPosition:3);
			}
		}
		case 4:
		{
			switch (param2)
			{
				case 0:
				{
					Func1557132(param1, 2);
				}
				case 1:
				{
					g_var30040[param1] = 3;
					Func1698916(param1);
				}
			}
		}
	}
}

public SelectPlayerList_DatabaseMenu(Handle:menu, MenuAction:action, param1, param2) // address: 1584972
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			if (param2 == -6)
			{
				Func1580896(param1);
			}
		}
		case 4:
		{
			decl String:var16[16];
			GetMenuItem(menu, param2, var16, 16);
			g_var12088[param1][E2_var2] = StringToInt(var16, 10); // Array
			Func1701436(param1);
		}
	}
}

Func1586740(arg12, const String:arg16[], const String:arg20[], arg24, arg28) // address: 1586740
{
	new Handle:var4 = CreateMenu(SelectInfoMenu, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var4, "Информация игрока%s:\n \n", Func1591292(g_var12088[arg12][E2_var2]) > 0 ? " (online)" : ""); // Array
	SetMenuExitBackButton(var4, true);
	AddMenuItem(var4, arg16, "Удалить из Базы Данных \n \n", 0);
	decl String:var84[80];
	FormatEx(var84, 80, "Имя игрока: %s", arg16);
	AddMenuItem(var4, "", var84, 1);
	FormatEx(var84, 80, "Стим игрока: %s", arg20);
	AddMenuItem(var4, "", var84, 1);
	FormatEx(var84, 80, "Модельки %s", arg28 ? "включены" : "выключены");
	AddMenuItem(var4, "", var84, 1);
	FormatTime(var84, 80, "Последняя активность: %d/%m/%Y-%H:%M", arg24);
	AddMenuItem(var4, "", var84, 1);
	DisplayMenu(var4, arg12, 0);
}

public SelectInfoMenu(Handle:menu, MenuAction:action, param1, param2) // address: 1589208
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			switch (g_var30040[param1])
			{
				case 2:
				{
					Func1557132(param1, 2);
				}
				case 3:
				{
					Func1698916(param1);
				}
			}
		}
		case 4:
		{
			Func1715456(g_var12088[param1][E2_var2]); // Array
			decl var4;
			if ((var4 = Func1591292(g_var12088[param1][E2_var2])) > 0) // Array
			{
				Func1619800(var4);
				decl String:var36[32];
				GetClientAuthString(param1, var36, 32, true);
				Func1685040(var4, var36);
				new var40 = Func1473928(var4);
				decl String:var72[32];
				if (var40 != -1 && GetEdictClassname(var40, var72, 32))
				{
					Func1599824(var4, var72[Func1546656(var72)], 0);
				}
				PrintToChat(var4, "[P.W] Администратор %N удалил у вас все оружия!", param1);
			}
			decl String:var68[64];
			GetMenuItem(menu, param2, var68, 64);
			PrintToChat(param1, "[P.W] Вы удалили из базы данных игрока %s!", var68);
			Func1580896(param1);
		}
	}
}

Func1591292(arg12) // address: 1591292
{
	for (new var4 = 1; var4 <= MaxClients; var4++)
	{
		if (IsClientInGame(var4) && arg12 == g_var1680[var4][E1_var2]) // Array
		{
			return var4;
		}
	}
	return -1;
}

public Action:Command_Inventar(client, args) // address: 1592884
{
	if (client > 0)
	{
		Func1594148(client);
	}
	return Action:3;
}

Func1594148(arg12) // address: 1594148
{
	new Handle:var4 = CreateMenu(SelectWeaponInventar, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var4, "Выберите оружие:\n \n");
	Func1640440(arg12, var4);
	if (GetMenuItemCount(var4) == 0)
	{
		AddMenuItem(var4, "", "У вас нет оружия", 1);
	}
	DisplayMenu(var4, arg12, 0);
}

public SelectWeaponInventar(Handle:menu, MenuAction:action, param1, param2) // address: 1595284
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 4:
		{
			GetMenuItem(menu, param2, g_var12088[param1][E2_var3], 15); // Array
			Func1596488(param1);
		}
	}
}

Func1596488(arg12) // address: 1596488
{
	new Handle:var4 = CreateMenu(SelectInventarMenuWeaponName, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(var4, "Выберите скин:\n \n");
	SetMenuExitBackButton(var4, true);
	Func1642004(arg12, g_var12088[arg12][E2_var3], var4, true); // Array
	if (GetMenuItemCount(var4) == 0)
	{
		AddMenuItem(var4, "", "У вас нет скинов", 1);
		Func1618504(arg12, g_var12088[arg12][E2_var3]); // Array
	}
	DisplayMenu(var4, arg12, 0);
}

public SelectInventarMenuWeaponName(Handle:menu, MenuAction:action, param1, param2) // address: 1597816
{
	switch (action)
	{
		case 16:
		{
			CloseHandle(menu);
		}
		case 8:
		{
			if (param2 == -6)
			{
				Func1594148(param1);
			}
		}
		case 4:
		{
			new Float:var4 = GetGameTime();
			if (g_var11824[param1] < var4)
			{
				GetMenuItem(menu, param2, g_var12088[param1][E2_var4], 51); // Array
				Func1696900(param1, g_var12088[param1][E2_var3], g_var12088[param1][E2_var4]); // Array; Array
				Func1599824(param1, g_var12088[param1][E2_var3], 0); // Array
			}
			else
			{
				PrintToChat(param1, "[P.W] Флуд, переключение недоступно!");
			}
			g_var11824[param1] = 0.5 + var4;
			Func1596488(param1);
		}
	}
}

Func1599824(arg12, const String:arg16[], arg20) // address: 1599824
{
	new var4 = Func1473928(arg12);
	if (!arg20 && var4 > 0)
	{
		SetEntPropEnt(var4, Prop_Send, "m_PredictableID", 0, 0);
	}
	if (Func1601612(var4, arg16))
	{
		Func1541204(arg12, var4, Func1476524(g_var6432[arg12][0]));
	}
	else
	{
		for (new var8 = 0; var8 < 2; var8++)
		{
			if (g_var9616[arg12][var8] > 0)
			{
				switch (var8)
				{
					case 0:
					{
						var4 = GetPlayerWeaponSlot(arg12, 0);
					}
					case 1:
					{
						var4 = GetPlayerWeaponSlot(arg12, 4);
					}
				}
				if (Func1601612(var4, arg16))
				{
					OnWeaponEquipPost(arg12, var4);
					g_var10408[arg12] = 0;
				}
			}
		}
	}
}

bool:Func1601612(arg12, const String:arg16[]) // address: 1601612
{
	decl String:var32[32];
	if (arg12 != -1 && GetEdictClassname(arg12, var32, 32))
	{
		new var36 = Func1546656(var32);
		if (StrEqual(var32[var36], arg16, true))
		{
			return true;
		}
	}
	return false;
}
