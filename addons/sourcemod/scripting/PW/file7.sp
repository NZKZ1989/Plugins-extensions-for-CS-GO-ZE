// Decompilation by Maxim "Kailo" Telezhenko, 2018

public Native_GetIDClient(Handle:plugin, numParams) // address: 1720036
{
	new var4 = GetNativeCell(1);
	if (var4 < 1 || var4 > MaxClients)
	{
		return ThrowNativeError(1, "Invalid client index (%d)", var4);
	}
	if (!IsClientConnected(var4))
	{
		return ThrowNativeError(1, "Client %d is not connected", var4);
	}
	return g_var1680[var4][E1_var2]; // Array
}

public Native_SetWeapon(Handle:plugin, numParams) // address: 1721412
{
	new var4 = GetNativeCell(1);
	if (var4 < 1 || var4 > MaxClients)
	{
		ThrowNativeError(1, "Invalid client index (%d)", var4);
	}
	if (!IsClientConnected(var4))
	{
		ThrowNativeError(1, "Client %d is not connected", var4);
	}
	decl String:var36[32];
	GetNativeString(2, var36, 32);
	new var40 = Func1546656(var36);
	new var44 = 0;
	if (KvJumpToKey(g_var32576, var36[var40], false))
	{
		decl String:var96[52];
		GetNativeString(3, var96, 50);
		if (KvJumpToKey(g_var32576, var96, false))
		{
			KvRewind(g_var32576);
			if (!Func1626196(var4, var36[var40], var96))
			{
				Func1693328(var4, var36[var40], var96, GetNativeCell(4), true);
				Func1599824(var4, var36[var40], 0);
				var44 = 1;
			}
		}
		else
		{
			ThrowNativeError(3, "Skin - %s not found", var96);
		}
		KvRewind(g_var32576);
	}
	else
	{
		ThrowNativeError(2, "Weapon - %s not found", var36);
	}
	return var44;
}

public Native_DelWeapon(Handle:plugin, numParams) // address: 1723712
{
	new var4 = GetNativeCell(1);
	if (var4 < 1 || var4 > MaxClients)
	{
		ThrowNativeError(1, "Invalid client index (%d)", var4);
	}
	if (!IsClientConnected(var4))
	{
		ThrowNativeError(1, "Client %d is not connected", var4);
	}
	decl String:var36[32];
	GetNativeString(2, var36, 32);
	new var40 = Func1546656(var36);
	new var44 = 0;
	if (KvJumpToKey(g_var32576, var36[var40], false))
	{
		decl String:var96[52];
		GetNativeString(3, var96, 50);
		if (KvJumpToKey(g_var32576, var96, false))
		{
			if (Func1626196(var4, var36[var40], var96))
			{
				Func1632396(var4, var36[var40], var96, 1);
				Func1599824(var4, var36[var40], 1);
				var44 = 1;
			}
			KvRewind(g_var32576);
		}
		else
		{
			ThrowNativeError(3, "Skin %s not found", var96);
		}
		KvRewind(g_var32576);
	}
	else
	{
		ThrowNativeError(2, "Weapon %s not found", var36);
	}
	return var44;
}

public Native_CheckSkinWeapon(Handle:plugin, numParams) // address: 1726472
{
	new var4 = GetNativeCell(1);
	if (var4 < 1 || var4 > MaxClients)
	{
		return ThrowNativeError(1, "Invalid client index (%d)", var4);
	}
	if (!IsClientConnected(var4))
	{
		return ThrowNativeError(1, "Client %d is not connected", var4);
	}
	decl String:var36[32];
	GetNativeString(2, var36, 32);
	new var40 = Func1546656(var36);
	new var44 = 0;
	if (KvJumpToKey(g_var32576, var36[var40], false))
	{
		decl String:var96[52];
		GetNativeString(3, var96, 50);
		if (KvJumpToKey(g_var32576, var96, false))
		{
			KvRewind(g_var32576);
			if (GetNativeCell(4))
			{
				var44 = Func1622992(var4, var36[var40], var96);
			}
			else
			{
				var44 = Func1626196(var4, var36[var40], var96);
			}
		}
		else
		{
			ThrowNativeError(3, "Skin %s not found", var96);
		}
		KvRewind(g_var32576);
	}
	else
	{
		ThrowNativeError(2, "Weapon %s not found", var36);
	}
	return var44;
}

public Native_CheckWeapon(Handle:plugin, numParams) // address: 1728700
{
	new var4 = GetNativeCell(1);
	if (var4 < 1 || var4 > MaxClients)
	{
		ThrowNativeError(1, "Invalid client index (%d)", var4);
	}
	if (!IsClientConnected(var4))
	{
		ThrowNativeError(1, "Client %d is not connected", var4);
	}
	decl String:var36[32];
	GetNativeString(2, var36, 32);
	new var40 = Func1546656(var36);
	new var44 = 0;
	if (KvJumpToKey(g_var32576, var36[var40], false))
	{
		new var48 = GetNativeCell(3);
		if (var48)
		{
			var44 = Func1621172(var4, var36[var40]);
		}
		else
		{
			var44 = Func1624584(var4, var36[var40]);
		}
		KvRewind(g_var32576);
	}
	else
	{
		ThrowNativeError(2, "Weapon %s not found", var36);
	}
	return var44;
}

public Native_EnableWeapon(Handle:plugin, numParams) // address: 1731360
{
	new var4 = GetNativeCell(1);
	if (var4 < 1 || var4 > MaxClients)
	{
		ThrowNativeError(1, "Invalid client index (%d)", var4);
	}
	if (!IsClientConnected(var4))
	{
		ThrowNativeError(1, "Client %d is not connected", var4);
	}
	new var8 = GetNativeCell(2);
	switch (var8)
	{
		case 0, 1:
		{
			return Func1732860(var4, var8);
		}
		case 2:
		{
			return g_var7768[var4];
		}
	}
	return 0;
}

Func1732860(arg12, arg16) // address: 1732860
{
	if (g_var7768[arg12] != arg16)
	{
		g_var7768[arg12] = arg16;
		new var4 = Func1473928(arg12);
		if (var4 > 0)
		{
			Func1541204(arg12, var4, Func1476524(g_var6432[arg12][0]));
			g_var10408[arg12] = 0;
		}
		decl String:var76[72];
		FormatEx(var76, 70, "UPDATE `user` SET `status` = %d WHERE `custom_id` = %d", arg16, g_var1680[arg12][E1_var2]); // Array
		SQL_TQuery(g_var33564, SQL_DefCallback, var76, 0, DBPrio_Normal);
	}
	return 1;
}

public Native_CheckNewClient(Handle:plugin, numParams) // address: 1734772
{
	new var4 = GetNativeCell(1);
	if (var4 < 1 || var4 > MaxClients)
	{
		return ThrowNativeError(1, "Invalid client index (%d)", var4);
	}
	if (!IsClientConnected(var4))
	{
		return ThrowNativeError(1, "Client %d is not connected", var4);
	}
	return g_var33568[var4];
}

public Native_SequenceClient(Handle:plugin, numParams) // address: 1736028
{
	new var4 = GetNativeCell(1);
	if (var4 < 1 || var4 > MaxClients)
	{
		ThrowNativeError(1, "Invalid client index (%d)", var4);
	}
	if (!IsClientConnected(var4))
	{
		ThrowNativeError(1, "Client %d is not connected", var4);
	}
	g_var9352[var4] = GetNativeCell(2);
}

public Native_AddTimeWeapon(Handle:plugin, numParams) // address: 1738004
{
	new var4 = GetNativeCell(1);
	if (var4 < 1 || var4 > MaxClients)
	{
		return ThrowNativeError(1, "Invalid client index (%d)", var4);
	}
	if (!IsClientConnected(var4))
	{
		return ThrowNativeError(1, "Client %d is not connected", var4);
	}
	decl String:var36[32];
	GetNativeString(2, var36, 32);
	new var40 = Func1546656(var36);
	new var44 = 0;
	if (KvJumpToKey(g_var32576, var36[var40], false))
	{
		decl String:var96[52];
		GetNativeString(3, var96, 50);
		if (KvJumpToKey(g_var32576, var96, false))
		{
			if (Func1626196(var4, var36[var40], var96))
			{
				Func1693328(var4, var36[var40], var96, GetNativeCell(4), false);
				var44 = 1;
			}
			KvRewind(g_var32576);
		}
		else
		{
			ThrowNativeError(3, "Skin %s not found", var96);
		}
		KvRewind(g_var32576);
	}
	else
	{
		ThrowNativeError(2, "Weapon %s not found", var36);
	}
	return var44;
}
