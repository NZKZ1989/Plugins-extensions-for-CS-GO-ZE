#include <sourcemod>

#pragma newdecls required
#pragma tabsize 0

int g_iAuthorizedFlags[32] = { -1, ...};

int g_iAdminFlags[6][2] = {
	{'b', ADMFLAG_GENERIC},
	{'o', ADMFLAG_CUSTOM1},
	{'p', ADMFLAG_CUSTOM2},
	{'h', ADMFLAG_CONVARS},
	{'m', ADMFLAG_RCON},
	{'z', ADMFLAG_ROOT}
};

ConVar g_cAdminHelper_AuthorizedFlags;

stock void AdminHelper_SetupAuthorizedFlags(ConVar cAuthorizedFlags)
{
    g_cAdminHelper_AuthorizedFlags = cAuthorizedFlags;
    g_cAdminHelper_AuthorizedFlags.AddChangeHook(AdminHelper_ConVarChanged_AuthorizedFlags);
}

stock void AdminHelper_ConVarChanged_AuthorizedFlags(ConVar cvar, const char[] sOldValue, const char[] sNewValue)
{
    AdminHelper_GetAuthorizedFlags();
}

stock void AdminHelper_GetAuthorizedFlags()
{
    char sAuthorizedFlags[64];
	g_cAdminHelper_AuthorizedFlags.GetString(sAuthorizedFlags, sizeof(sAuthorizedFlags));

	char sSplitedFlags[32][3];
	int iSentences = ExplodeString(sAuthorizedFlags, ",", sSplitedFlags, sizeof(sSplitedFlags), 3);
	for (int j = 0; j < sizeof(g_iAuthorizedFlags); j++)
		g_iAuthorizedFlags[j] = -1;

	if (strlen(sAuthorizedFlags) <= 0)
		return;

	int i = 0;
	while (i < iSentences)
	{
		if (strlen(sSplitedFlags[i]) == 1)
			g_iAuthorizedFlags[i] = sSplitedFlags[i][0];
		else
			g_iAuthorizedFlags[i] = 0;
		i++;
	}
	if (i < sizeof(g_iAuthorizedFlags))
		g_iAuthorizedFlags[i] =  -1;
}

stock bool AdminHelper_IsClientAuthorized(int client)
{
    bool bAuthorized = false;

	// If cvar is empty, all clients are authorized
	if (g_iAuthorizedFlags[0] == -1)
		bAuthorized = true;

    for (int i = 0; i < sizeof(g_iAuthorizedFlags); i++)
    {
        for (int j = 0; j < sizeof(g_iAdminFlags); j++)
        {
            if (g_iAuthorizedFlags[i] == g_iAdminFlags[j][0] && 
                (CheckCommandAccess(client, "adminflaghelper", g_iAdminFlags[j][1])))
            {
                bAuthorized = true;
                break;
            }
        }
        if (bAuthorized || g_iAuthorizedFlags[i] == -1)
            break;
    }
    return bAuthorized;
}