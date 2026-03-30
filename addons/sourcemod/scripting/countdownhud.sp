#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#define MAXLENGTH_INPUT 128
#define PLUGIN_VERSION "1.7"

int number, onumber;
Handle timerHandle = INVALID_HANDLE;
Handle g_hHudSyncCountdown;

public Plugin myinfo = 
{
    name = "Countdown HUD",
    author = "AntiTeal + Modified",
    description = "Countdown timers based on messages from maps.",
    version = PLUGIN_VERSION,
    url = "http://antiteal.com"
}

ConVar g_cVHudPosition, g_cVHudColor, g_cVHudSymbols;

float HudPos[2];
int HudColor[3];
bool HudSymbols;

public void OnPluginStart()
{
    CreateConVar("sm_cdhud_version", PLUGIN_VERSION, "CountdownHUD Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

    AddCommandListener(Chat, "say");
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);

    DeleteTimer();

    // создаём отдельный HUD‑синхронизатор для таймера плагина
    g_hHudSyncCountdown = CreateHudSynchronizer();

    g_cVHudPosition = CreateConVar("sm_cdhud_position", "-1.0 0.125", "The X and Y position for the hud.");
    g_cVHudColor = CreateConVar("sm_cdhud_color", "0 255 0", "RGB color value for the hud.");
    g_cVHudSymbols = CreateConVar("sm_cdhud_symbols", "1", "Determines whether >> and << are wrapped around the text.");

    g_cVHudPosition.AddChangeHook(ConVarChange);
    g_cVHudColor.AddChangeHook(ConVarChange);
    g_cVHudSymbols.AddChangeHook(ConVarChange);

    AutoExecConfig(true);
    GetConVars();
}

public void ColorStringToArray(const char[] sColorString, int aColor[3])
{
    char asColors[4][4];
    ExplodeString(sColorString, " ", asColors, sizeof(asColors), sizeof(asColors[]));

    aColor[0] = StringToInt(asColors[0]);
    aColor[1] = StringToInt(asColors[1]);
    aColor[2] = StringToInt(asColors[2]);
}

public void GetConVars()
{
    char StringPos[2][8];
    char PosValue[16];
    g_cVHudPosition.GetString(PosValue, sizeof(PosValue));
    ExplodeString(PosValue, " ", StringPos, sizeof(StringPos), sizeof(StringPos[]));

    HudPos[0] = StringToFloat(StringPos[0]);
    HudPos[1] = StringToFloat(StringPos[1]);

    char ColorValue[64];
    g_cVHudColor.GetString(ColorValue, sizeof(ColorValue));

    ColorStringToArray(ColorValue, HudColor);

    HudSymbols = g_cVHudSymbols.BoolValue;
}

public void ConVarChange(ConVar convar, char[] oldValue, char[] newValue)
{
    GetConVars();
}

public void Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    DeleteTimer();
}

public void DeleteTimer()
{
    if(timerHandle != INVALID_HANDLE)
    {
        KillTimer(timerHandle);
        timerHandle = INVALID_HANDLE;
    }
}

char Blacklist[][] = {
    "recharge", "recast", "cooldown", "cool"
};

char Keywords[][] = {
    "door", "open", "close", "gate", "bridge", "teleport", "elevator", "lift", "barricade", "wall"
};

bool CheckString(char[] string)
{
    for (int i = 0; i < sizeof(Blacklist); i++)
    {
        if(StrContains(string, Blacklist[i], false) != -1)
        {
            return true;
        }
    }
    return false;
}

bool HasKeyword(char[] text)
{
    for (int i = 0; i < sizeof(Keywords); i++)
    {
        if(StrContains(text, Keywords[i], false) != -1)
        {
            return true;
        }
    }
    return false;
}

Action Chat(int client, const char[] command, int argc)
{
    if(client)
    {
        return Plugin_Continue;
    }

    char ConsoleChat[MAXLENGTH_INPUT], FilterText[sizeof(ConsoleChat)+1], ChatArray[32][MAXLENGTH_INPUT];
    int consoleNumber, filterPos;
    bool isCountable;

    GetCmdArgString(ConsoleChat, sizeof(ConsoleChat));

    // фильтрация текста
    for (int i = 0; i < sizeof(ConsoleChat); i++) 
    {
        if (IsCharAlpha(ConsoleChat[i]) || IsCharNumeric(ConsoleChat[i]) || IsCharSpace(ConsoleChat[i])) 
        {
            FilterText[filterPos++] = ConsoleChat[i];
        }
    }
    FilterText[filterPos] = '\0';
    TrimString(FilterText);

    int words = ExplodeString(FilterText, " ", ChatArray, sizeof(ChatArray), sizeof(ChatArray[]));

    for(int i = 0; i < words; i++)
    {
        int val = StringToInt(ChatArray[i]);

        if(val > 0)
        {
            // проверка единиц времени
            if(i + 1 < words)
            {
                if(StrEqual(ChatArray[i + 1], "s", false) ||
                   StrEqual(ChatArray[i + 1], "sec", false) ||
                   StrEqual(ChatArray[i + 1], "second", false) ||
                   StrEqual(ChatArray[i + 1], "seconds", false))
                {
                    consoleNumber = val; // секунды как есть
                    isCountable = true;
                }
                else if(StrEqual(ChatArray[i + 1], "min", false) ||
                        StrEqual(ChatArray[i + 1], "mins", false) ||
                        StrEqual(ChatArray[i + 1], "minute", false) ||
                        StrEqual(ChatArray[i + 1], "minutes", false))
                {
                    consoleNumber = val * 60; // минуты переводим в секунды
                    isCountable = true;
                }
            }
            // проверка ключевых слов
            if(!isCountable && HasKeyword(FilterText))
            {
                consoleNumber = val;
                isCountable = true;
            }
        }

        // 🔽 дополнительная проверка формата "10s"
        if(!isCountable)
        {
            char word[MAXLENGTH_INPUT];
            strcopy(word, sizeof(word), ChatArray[i]);
            int len = strlen(word);

            if(len > 1 && IsCharNumeric(word[0]) && (word[len-1] == 's' || word[len-1] == 'S'))
            {
                word[len-1] = '\0'; // убираем 's'
                consoleNumber = StringToInt(word);
                if(consoleNumber > 0)
                {
                    isCountable = true;
                }
            }
        }

        if(isCountable && !CheckString(FilterText))
        {
            number = consoleNumber;
            onumber = consoleNumber;
            InitCountDown(FilterText);
            break;
        }
    }

    return Plugin_Continue;
}

public void InitCountDown(char[] text)
{
    if(timerHandle != INVALID_HANDLE)
    {
        KillTimer(timerHandle);
        timerHandle = INVALID_HANDLE;
    }

    DataPack TimerPack;
    timerHandle = CreateDataTimer(1.0, RepeatMSG, TimerPack, TIMER_REPEAT);
    char text2[MAXLENGTH_INPUT + 10];
    if(HudSymbols)
    {
        Format(text2, sizeof(text2), ">> %s <<", text);
    }
    else
    {
        Format(text2, sizeof(text2), "%s", text);
    }

    TimerPack.WriteString(text2);

    for (int i = 1; i <= MAXPLAYERS + 1; i++)
    {
        if(IsValidClient(i))
        {
            SendHudMsg(i, text2);
        }
    }
}

public Action RepeatMSG(Handle timer, Handle pack)
{
    number--;
    if(number <= 0)
    {
        DeleteTimer();
        for (int i = 1; i <= MAXPLAYERS + 1; i++)
        {
            if(IsValidClient(i))
            {
                ClearSyncHud(i, g_hHudSyncCountdown);
            }
        }
        return Plugin_Handled;
    }
    
    char string[MAXLENGTH_INPUT + 10], sNumber[8], sONumber[8];
    ResetPack(pack);
    ReadPackString(pack, string, sizeof(string));

    IntToString(onumber, sONumber, sizeof(sONumber));
    IntToString(number, sNumber, sizeof(sNumber));

    ReplaceString(string, sizeof(string), sONumber, sNumber);

    for (int i = 1; i <= MAXPLAYERS + 1; i++)
    {
        if(IsValidClient(i))
        {
            SendHudMsg(i, string);
        }
    }
    return Plugin_Handled;
}

public void SendHudMsg(int client, char[] szMessage)
{
    SetHudTextParams(HudPos[0], HudPos[1], 1.0, HudColor[0], HudColor[1], HudColor[2], 255, 0, 0.0, 0.0, 0.0);
    ShowSyncHudText(client, g_hHudSyncCountdown, szMessage);
}

bool IsValidClient(int client, bool nobots = true)
{ 
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
    {
        return false; 
    }
    return IsClientInGame(client); 
}
