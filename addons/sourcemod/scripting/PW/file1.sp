// Decompilation by Maxim "Kailo" Telezhenko, 2018

new g_var1240[1]; // address: 1240// zero // codestart: 0
new g_var1244[2]; // address: 1244 // zero // codestart: 0
new g_var1252[7]; // address: 1252 // zero // codestart: 0
new g_var1280[1]; // address: 1280 // zero // codestart: 0

Func1469220() // address: 1469220
{
	g_var1244[0] = FindSendPropOffs("CCSPlayer", "m_hActiveWeapon"); // Array
	g_var1244[1] = FindSendPropOffs("CCSPlayer", "m_iAddonBits"); // Array
	g_var1240[0] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_hOwnerEntity"); // Array
	g_var1280[0] = FindSendPropOffs("CBaseCombatWeapon", "m_PredictableID"); // Array
	g_var1252[0] = FindSendPropOffs("CPredictedViewModel", "m_nSequence"); // Array
	g_var1252[1] = FindSendPropOffs("CPredictedViewModel", "m_fEffects"); // Array
	g_var1252[2] = FindSendPropOffs("CPredictedViewModel", "m_flPlaybackRate"); // Array
	g_var1252[3] = FindSendPropOffs("CPredictedViewModel", "m_nModelIndex"); // Array
	g_var1252[4] = FindSendPropOffs("CPredictedViewModel", "m_nViewModelIndex"); // Array
	g_var1252[5] = FindSendPropOffs("CPredictedViewModel", "m_hOwner"); // Array
	g_var1252[6] = FindSendPropOffs("CPredictedViewModel", "m_hWeapon"); // Array
}

Func1471064(arg12) // address: 1471064
{
	return GetEntData(arg12, g_var1244[1], 4); // Array
}

Func1472396(arg12, arg16) // address: 1472396
{
	SetEntData(arg12, g_var1244[1], arg16, 4, true); // Array
}

Func1473928(arg12) // address: 1473928
{
	return GetEntDataEnt2(arg12, g_var1244[0]); // Array
}

Func1475280(arg12) // address: 1475280
{
	return GetEntDataEnt2(arg12, g_var1240[0]); // Array
}

Func1476524(arg12) // address: 1476524
{
	return GetEntData(arg12, g_var1252[0], 4); // Array
}

Func1478124(arg12, arg16) // address: 1478124
{
	SetEntData(arg12, g_var1252[0], arg16, 4, true); // Array
}

Float:Func1479052(arg12) // address: 1479052
{
	new var4 = FindDataMapOffs(arg12, "m_flCycle");
	if (var4 != -1)
	{
		return GetEntDataFloat(arg12, var4);
	}
	return -1.0;
}

Func1479924(arg12) // address: 1479924
{
	return GetEntData(arg12, g_var1252[1], 4); // Array
}

Func1481460(arg12, arg16) // address: 1481460
{
	SetEntData(arg12, g_var1252[1], arg16, 4, true); // Array
}

Func1482604(arg12, arg16) // address: 1482604
{
	new var4 = Func1479924(arg12);
	if (var4 & arg16)
	{
		return;
	}
	var4 = var4 | arg16;
	Func1481460(arg12, var4);
}

Func1484924(arg12, arg16) // address: 1484924
{
	new var4 = Func1479924(arg12);
	if (!(var4 & arg16))
	{
		return;
	}
	var4 = var4 & ~arg16;
	Func1481460(arg12, var4);
}

Float:Func1486252(arg12) // address: 1486252
{
	return GetEntDataFloat(arg12, g_var1252[2]); // Array
}

Func1488020(arg12, Float:arg16) // address: 1488020
{
	SetEntDataFloat(arg12, g_var1252[2], arg16, true); // Array
}

Func1488988(arg12, arg16) // address: 1488988
{
	SetEntData(arg12, g_var1252[3], arg16, 4, true); // Array
}

Func1490860(arg12) // address: 1490860
{
	return GetEntData(arg12, g_var1252[4], 4); // Array
}

Func1492128(arg12) // address: 1492128
{
	return GetEntDataEnt2(arg12, g_var1252[5]); // Array
}

Func1493752(arg12, arg16) // address: 1493752
{
	SetEntDataEnt2(arg12, g_var1252[6], arg16, true); // Array
}

Func1495348(arg12) // address: 1495348
{
	return GetEntData(arg12, g_var1280[0], 4); // Array
}

Func1496576(arg12, arg16) // address: 1496576
{
	SetEntData(arg12, g_var1280[0], arg16, 4, true); // Array
}
