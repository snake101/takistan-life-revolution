private["_group_loop_i", "_pmcCheckTime", "_pmcCheckDelay", "_pmcCheckBool"];
_group_loop_i = 0;

_pmcCheckTime = 0;
_pmcCheckDelay = 3 * 60;
_pmcCheckBool = false;

while {true} do {
	if ([] call A_RESTART_CHECK) exitwith {[] spawn A_RESTART_C};
	
	if ( ((group player) == (group server)) && not(C_changing)) then {
		[player] joinSilent grpNull;
	};
	
	if (isCiv && (!isOpf) && (!isIns)) then {
			if ( ([player] call player_isPMCclothes) && !([player] call player_isPMCwhitelist) ) then {
					if (_pmcCheckBool) then {
							if (time >= _pmcCheckTime) then {
									[player] call player_PMCrevoke;
								}else{
									hintSilent format["You have %1 Seconds left to change out of your PMC Clothes or they will be removed", round(_pmcCheckTime - time)];
								};
						}else{
							_pmcCheckBool = true;
							_pmcCheckTime = time + _pmcCheckDelay;
						};
				}else{
					_pmcCheckBool = false;
				};
		};
		
	sleep 10;
	_group_loop_i =_group_loop_i + 1;
	if (_group_loop_i >= 5000) exitwith {[] execVM "Awesome\Client\client_loop.sqf";};
};