#if defined _Spectate_included
	#endinput
#endif
#define _Spectate_included
/**
 * Called when a client switches to spec by sm_spectate.
 *
 * @param client        Client index of the caller.
 */
forward void OnPlayerSwitchedToSpectateByCommand(int client);