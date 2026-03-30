public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int clientIndex = GetClientOfUserId(event.GetInt("userid"));
    if (!IsValidClient(clientIndex)) return;

    if (ZR_IsClientZombie(clientIndex))
    {
        ResetPlayerGloves(clientIndex); // сброс на стандартные перчатки
    }
    else
    {
        GivePlayerGloves(clientIndex); // выдаём кастомные перчатки
    }
}

public Action ChatListener(int client, const char[] command, int args)
{
    char msg[128];
    GetCmdArgString(msg, sizeof(msg));
    StripQuotes(msg);

    // Проверяем все варианты команд
    if (StrContains(msg, "!gloves") != -1 
        || StrContains(msg, "!glove") != -1 
        || StrContains(msg, "!eldiven") != -1 
        || StrContains(msg, "!gllang") != -1)
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}
