#include <sourcemod>
#include <cstrike>
#include <sdktools>

#pragma semicolon 1

#define Utils_VERSION               "1.3.2"
#define CONFIG_PATH                 "configs/steam.cfg"
#define	CONFIG_KV_NAME              "steam"
#define	CONFIG_KV_API_NAME          "api"
#define CONFIG_KV_API_KEY_NAME      "key"
#define CONFIG_KV_API_ENDPOINT_NAME "endpoint"

stock void GetConfigKvSteam(KeyValues &kv, const char[] sConfigPath = CONFIG_PATH, const char[] sKvName = CONFIG_KV_NAME)
{
	kv = new KeyValues(sKvName);

	char sFile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sFile, sizeof(sFile), sConfigPath);

	if (!FileExists(sFile))
	{
		Handle hFile = OpenFile(sFile, "w");

		if (hFile == INVALID_HANDLE)
		{
			SetFailState("[Steam] Could not create %s", sFile);
			delete kv;
			return;
		}

		WriteFileLine(hFile, "\"%s\"", CONFIG_KV_NAME);
		WriteFileLine(hFile, "{");

		WriteFileLine(hFile, "\t\"%s\"", CONFIG_KV_API_NAME);
		WriteFileLine(hFile, "\t{");
		WriteFileLine(hFile, "\t\t\"endpoint\"\t\"api.steampowered.com\"");
		WriteFileLine(hFile, "\t\t\"key\"\t\t\"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\"");
		WriteFileLine(hFile, "\t}");

		WriteFileLine(hFile, "}");

		CloseHandle(hFile);
	}

	kv.ImportFromFile(sFile);
}

stock bool GetSteamAPIEndpoint(char[] sSteamAPIEndpoint, int size)
{
	static char sSteamAPIEndpointLoaded[255] = "";

	if (sSteamAPIEndpointLoaded[0] == '\0')
	{
		KeyValues kv;
		GetConfigKvSteam(kv);

		if (!kv.JumpToKey(CONFIG_KV_API_NAME))
		{
			delete kv;
			return false;
		}

		kv.GetString(CONFIG_KV_API_ENDPOINT_NAME, sSteamAPIEndpointLoaded, sizeof(sSteamAPIEndpointLoaded), "");

		delete kv;
	}

	strcopy(sSteamAPIEndpoint, size, sSteamAPIEndpointLoaded);

	return true;
}

stock bool GetSteamAPIKey(char[] sSteamAPIKey, int size)
{
	static char sSteamAPIKeyLoaded[64] = "";

	if (sSteamAPIKeyLoaded[0] == '\0')
	{
		KeyValues kv;
		GetConfigKvSteam(kv);

		if (!kv.JumpToKey(CONFIG_KV_API_NAME))
		{
			delete kv;
			return false;
		}

		kv.GetString(CONFIG_KV_API_KEY_NAME, sSteamAPIKeyLoaded, sizeof(sSteamAPIKeyLoaded), "");

		delete kv;
	}

	if (StrEqual(sSteamAPIKeyLoaded, "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"))
		return false;

	strcopy(sSteamAPIKey, size, sSteamAPIKeyLoaded);

	return true;
}

stock int GetPlayerCount(bool bCountFakes = true)
{
	int iPlayerCount = 0;
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			iPlayerCount++;
			if (IsFakeClient(client) && !bCountFakes)
				iPlayerCount--;
		}
	}
	return iPlayerCount;
}

stock bool IsValidClient(int client, bool bCheckAlive = false, bool checkTeam = true, bool bCheckBot = true)
{
	if (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) &&
		(bCheckBot == false || !IsFakeClient(client)) && (bCheckAlive == false || IsPlayerAlive(client)))
	{
		if (checkTeam)
		{
			int currentTeam = GetClientTeam(client);
			if (currentTeam == CS_TEAM_T || currentTeam == CS_TEAM_CT)
				return true;
		}
		else
			return true;
	}
	return false;
}

stock bool Steam32IDtoSteam64ID(const char[] sSteam32ID, char[] sSteam64ID, int Size)
{
	if(strlen(sSteam32ID) < 11 || strncmp(sSteam32ID[0], "STEAM_0:", 8))
	{
		sSteam64ID[0] = 0;
		return false;
	}

	int iUpper = 765611979;
	int isSteam64ID = StringToInt(sSteam32ID[10]) * 2 + 60265728 + sSteam32ID[8] - 48;

	int iDiv = isSteam64ID / 100000000;
	int iIdx = 9 - (iDiv ? (iDiv / 10 + 1) : 0);
	iUpper += iDiv;

	IntToString(isSteam64ID, sSteam64ID[iIdx], Size - iIdx);
	iIdx = sSteam64ID[9];
	IntToString(iUpper, sSteam64ID, Size);
	sSteam64ID[9] = iIdx;

	return true;
}

stock int Steam64toSteam3(const char[] sSteam64ID)
{
	if(strlen(sSteam64ID) != 17)
		return 0;

	// convert SteamID64 to array of integers
	int aSteam64ID[17];
	for(int i = 0; i < 17; i++)
		aSteam64ID[i] = sSteam64ID[i] - 48;

	// subtract individual SteamID64 identifier (0x0110000100000000)
	int aSteam64IDIdent[] = {7, 6, 5, 6, 1, 1, 9, 7, 9, 6, 0, 2, 6, 5, 7, 2, 8};
	int Carry = 0;
	for(int i = 16; i >= 0; i--)
	{
		if(aSteam64ID[i] < aSteam64IDIdent[i] + Carry)
		{
			aSteam64ID[i] = aSteam64ID[i] - aSteam64IDIdent[i] - Carry + 10;
			Carry = 1;
		}
		else
		{
			aSteam64ID[i] = aSteam64ID[i] - aSteam64IDIdent[i] - Carry;
			Carry = 0;
		}
	}

	char aBuf[17];
	int j = 0;
	bool ZereosDone = false;
	for(int i = 0; i < 17; i++)
	{
		if(!ZereosDone && !aSteam64ID[i])
			continue;
		ZereosDone = true;

		aBuf[j++] = aSteam64ID[i] + 48;
	}

	return StringToInt(aBuf);
}

stock void AddMenuItemTranslated(Menu menu, const char[] info, const char[] display, any ...)
{
	char buffer[128];
	VFormat(buffer, sizeof(buffer), display, 4);

	menu.AddItem(info, buffer);
}

stock void ColorStringToArray(const char[] sColorString, int aColor[3])
{
	char asColors[4][4];
	ExplodeString(sColorString, " ", asColors, sizeof(asColors), sizeof(asColors[]));

	aColor[0] = StringToInt(asColors[0]);
	aColor[1] = StringToInt(asColors[1]);
	aColor[2] = StringToInt(asColors[2]);
}

stock void RGBAColorStringToArray(const char[] sColorString, int aColor[4])
{
	char asColors[5][5];
	ExplodeString(sColorString, " ", asColors, sizeof(asColors), sizeof(asColors[]));

	aColor[0] = StringToInt(asColors[0]);
	aColor[1] = StringToInt(asColors[1]);
	aColor[2] = StringToInt(asColors[2]);
	aColor[3] = StringToInt(asColors[3]);
}

stock void AddFilesToDownloadsTable(char configName[256])
{
	char ConfigFile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, ConfigFile, sizeof(ConfigFile), "configs/%s", configName);
	Handle hFile = OpenFile(ConfigFile, "r");
	if (hFile)
	{
		char filename[PLATFORM_MAX_PATH];
		while (!IsEndOfFile(hFile) && ReadFileLine(hFile, filename, PLATFORM_MAX_PATH))
		{
			if (TrimString(filename) > 2 && IsCharAlpha(filename[0]))
				AddFileToDownloadsTable(filename);
		}
		CloseHandle(hFile);
	}
	else
		LogError("Download list file missing: %s", ConfigFile);
}

stock int GetEdictsCount()
{
	int iCount = 0;
	int MAXENTITIES = GetMaxEntities();
	for (int entity = 1; entity <= MAXENTITIES; entity++)
	{
		if(IsValidEdict(entity))
			iCount++;
	}
	
	return iCount;
}

stock void StringToLowerCase(char[] input)
{
	int i = 0;
	int x;
	while ((x = input[i]) != '\0')
	{
		if ('A' <= x <= 'Z')
			input[i] += ('a' - 'A');
		i++;
	}
}

stock void StringToUpperCase(char[] input)
{
	int i = 0;
	int x;
	while ((x = input[i]) != '\0')
	{
		if ('a' <= x <= 'z')
			input[i] -= ('a' - 'A');
		i++;
	}
}

public bool IsCharEqualIgnoreCase(int a, int b)
{
	if (a == b)
		return true;

	int toLower = ('A' <= b && b <= 'Z') ? (b + ('a' - 'A')) : b;
	if (a == toLower)
		return true;

	int toUpper = ('a' <= b && b <= 'z') ? (b - ('a' - 'A')) : b;
	if (a == toUpper)
		return true;

	return false;
}

stock int GetCurrentMapSize()
{
	char sCurrentMap[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));
	FormatEx(sPath, sizeof(sPath), "maps/%s.bsp", sCurrentMap);
	return FileSize(sPath);
}

/**
 * Efficiently extracts the display name from a map path without file system operations.
 * 
 * @param map           Map path to process
 * @param displayName   Buffer to store the display name
 * @param maxlen        Maximum length of the buffer
 * @return              True if successful, false otherwise
 */
stock bool GetMapDisplayNameOptimized(const char[] map, char[] displayName, int maxlen)
{
	if (map[0] == '\0')
		return false;

	char normalizedPath[PLATFORM_MAX_PATH];
	char fileName[PLATFORM_MAX_PATH];

	strcopy(normalizedPath, sizeof(normalizedPath), map);
	ReplaceString(normalizedPath, sizeof(normalizedPath), "\\", "/", true);

	int ilastSlashPos = FindCharInString(normalizedPath, '/', true);
	// If no slash found, use the entire path as filename
	if (ilastSlashPos == -1)
		strcopy(fileName, sizeof(fileName), normalizedPath);
	else
		strcopy(fileName, sizeof(fileName), normalizedPath[ilastSlashPos+1]);

	// Remove .ugc extension for workshop maps
	int iExtPos = StrContains(fileName, ".ugc", true);
	if (iExtPos != -1)
		fileName[iExtPos] = 0;

	strcopy(displayName, maxlen, fileName);
	return true;
}
