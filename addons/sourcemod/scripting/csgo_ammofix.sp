#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#define PLUGIN_VERSION "1.1"

public Plugin myinfo =
{
    name        = "SM Franug CSGO Ammo fix",
    author      = "Franc1sco franug",
    description = "Fixes ammo reserve issues in CS:GO",
    version     = PLUGIN_VERSION,
    url         = "http://www.zeuszombie.com"
};

Handle g_ArrayWeapons;
Handle g_ArrayAmmo;

public void OnPluginStart()
{
    g_ArrayWeapons = CreateArray();
    g_ArrayAmmo    = CreateArray();

    HookEvent("round_prestart", Event_RoundPreStart, EventHookMode_Post);

    // Хукаем всех игроков при старте
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            OnClientPutInServer(i);
        }
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHookType:32, OnPostWeaponEquip);
}

public Action Event_RoundPreStart(Event event, const char[] name, bool dontBroadcast)
{
    ClearArray(g_ArrayWeapons);
    ClearArray(g_ArrayAmmo);
    return Plugin_Continue;
}

public Action CS_OnCSWeaponDrop(int client, int weapon)
{
    int ref = EntIndexToEntRef(weapon);
    int idx = FindValueInArray(g_ArrayWeapons, ref);

    if (idx != -1)
    {
        SetArrayCell(g_ArrayAmmo, idx, GetReserveAmmo(client, weapon));
    }
    return Plugin_Continue;
}

public Action OnPostWeaponEquip(int client, int weapon)
{
    char classname[64];
    GetEdictClassname(weapon, classname, sizeof(classname));

    int defIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

    // Фильтруем ненужные предметы
    if (StrContains(classname, "weapon_healthshot") != -1 ||
        StrContains(classname, "weapon_tagrenade") != -1 ||
        StrContains(classname, "weapon_knife") != -1 ||
        (defIndex > 42 && defIndex < 50))
    {
        return Plugin_Continue;
    }

    int ammo = GetReserveAmmo(client, weapon);
    if (ammo == -1 || ammo > 100)
    {
        return Plugin_Continue;
    }

    int ref = EntIndexToEntRef(weapon);
    int idx = FindValueInArray(g_ArrayWeapons, ref);

    if (idx != -1)
    {
        SetReserveAmmo(client, weapon, GetArrayCell(g_ArrayAmmo, idx));
    }
    else
    {
        SetReserveAmmo(client, weapon, 9999);
        PushArrayCell(g_ArrayWeapons, ref);
        PushArrayCell(g_ArrayAmmo, 9999);
    }

    return Plugin_Continue;
}

int GetReserveAmmo(int client, int weapon)
{
    int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (ammoType == -1)
    {
        return -1;
    }
    return GetEntProp(client, Prop_Send, "m_iAmmo", _, ammoType);
}

void SetReserveAmmo(int client, int weapon, int ammo)
{
    int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (ammoType == -1)
    {
        return;
    }
    SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammoType);
}
