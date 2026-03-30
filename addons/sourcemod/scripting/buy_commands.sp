#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#undef REQUIRE_PLUGIN
#include <zombiereloaded>

#pragma newdecls required

#define DATA "2.2"

char sConfig[PLATFORM_MAX_PATH];
Handle kv, trie_weapons[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "SM Buy weapons by commands",
	description = "",
	author = "Franc1sco franug",
	version = DATA,
	url = "http://steamcommunity.com/id/franug"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("ZR_IsClientZombie");
	return APLRes_Success;
}
 
public void OnPluginStart()
{
	CreateConVar("sm_buybycommands_version", DATA, "", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	AddCommandListener(SayC, "say");
	AddCommandListener(SayC, "say_team");
	
	HookEvent("player_spawn", PlayerSpawn);
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientConnected(client);
		}
	}
}

public Action PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    ClearTrie(trie_weapons[client]);
    return Plugin_Continue;
}

public void OnClientConnected(int client)
{
	trie_weapons[client] = CreateTrie();
}

public void OnClientDisconnect(int client)
{
	if(trie_weapons[client] != INVALID_HANDLE) CloseHandle(trie_weapons[client]);
}

public void OnMapStart()
{
	RefreshKV();
}

public void RefreshKV()
{
	BuildPath(Path_SM, sConfig, PLATFORM_MAX_PATH, "configs/franug_buybycommands.txt");
	
	if(kv != INVALID_HANDLE) CloseHandle(kv);
	
	kv = CreateKeyValues("BuyCommands");
	FileToKeyValues(kv, sConfig);
}

public Action SayC(int client, const char[] command, int args)
{
    if (!IsValidClient(client)) return Plugin_Continue;
    
    char buffer[255];
    GetCmdArgString(buffer,sizeof(buffer));
    StripQuotes(buffer);
    
    if (strlen(buffer) < 1) return Plugin_Continue;
    
    if (kv == INVALID_HANDLE) RefreshKV();
    
    KvRewind(kv);
    if (!KvJumpToKey(kv, buffer)) return Plugin_Continue;
    
    char flags[24];
    KvGetString(kv, "flags", flags, sizeof(flags), "public");
    
    if (!StrEqual(flags, "public", false) && !CheckAdminFlagsByString(client, flags))
    {
        //PrintToChat(client, " \x04You dont have access to buy this weapon");
        return Plugin_Handled;
    }
    
    int money = GetEntProp(client, Prop_Send, "m_iAccount");
    int cost = KvGetNum(kv, "price");
    
    if (money >= cost)
    {
        if (GetClientTeam(client) < 2)
        {
            //PrintToChat(client, " \x04You need to be in a team for buy weapons");
            return Plugin_Handled;
        }
        if (!IsPlayerAlive(client))
        {
            PrintToChat(client, " \x04You need to be alive for buy weapons");
            return Plugin_Handled;
        }
        if ((GetFeatureStatus(FeatureType_Native, "ZR_IsClientZombie") == FeatureStatus_Available) && ZR_IsClientZombie(client))
        {
            //PrintToChat(client, " \x04You need to be human for buy weapons");
            return Plugin_Handled;
        }
        
        char weapons[64];
        KvGetString(kv, "weapon", weapons, sizeof(weapons));
        int times = KvGetNum(kv, "times");
        int current;
        
        if (times == 0)
        {
            int drop = KvGetNum(kv, "slot", -1);
            if (drop != -1)     
            {
                int weapon = GetPlayerWeaponSlot(client, drop);
                if (weapon != -1) SDKHooks_DropWeapon(client, weapon);
            }
            
            GivePlayerItem(client, weapons);
            SetEntProp(client, Prop_Send, "m_iAccount", money - cost);
            ReplaceString(weapons, sizeof(weapons), "weapon_", "");
            //PrintToChat(client, " \x04You have bought a %s", weapons);
            return Plugin_Handled;
        }
        
        if (!GetTrieValue(trie_weapons[client], weapons, current)) current = 0;
        
        if (times <= current)
        {
            //PrintToChat(client, " \x04You cant buy more %s this round", weapons);
            return Plugin_Handled;
        }
        
        SetTrieValue(trie_weapons[client], weapons, ++current);
        
        int drop = KvGetNum(kv, "slot", -1);
        if (drop != -1)     
        {
            int weapon = GetPlayerWeaponSlot(client, drop);
            if (weapon != -1) SDKHooks_DropWeapon(client, weapon);
        }
        
        GivePlayerItem(client, weapons);
        SetEntProp(client, Prop_Send, "m_iAccount", money - cost);
        ReplaceString(weapons, sizeof(weapons), "weapon_", "");
        
        //PrintToChat(client, " \x04You have bought a %s %i/%i", weapons, current, times);
        return Plugin_Handled;
    }
    else
    {
        //PrintToChat(client, " \x04You dont have enought money. You need %i", cost);
        return Plugin_Handled;
    }
}

stock bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}

stock bool CheckAdminFlagsByString(int client, const char[] flagString)
{
    AdminId admin = view_as<AdminId>(GetUserAdmin(client));
    if (admin != INVALID_ADMIN_ID){
        int count, found, flags = ReadFlagString(flagString);
        for (int i = 0; i <= 20; i++){
            if (flags & (1<<i))
            {
                count++;

                if(GetAdminFlag(admin, view_as<AdminFlag>(i))){
                    found++;
                }
            }
        }

        if (count == found || GetUserFlagBits(client) & ADMFLAG_ROOT){
            return true;
        }
    }

    return false;
}  
