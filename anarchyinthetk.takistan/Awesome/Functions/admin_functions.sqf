if (not(isNil "admin_functions_defined")) exitWith {};

#define strM(x) ([x, ","] call format_integer)

logAdmin = {
	private["_text"];
	_text = _this select 0;
	if (isNil "_text") exitWith {};
	if (typeName _text != "STRING") exitWith {};
	
	private["_player"];
	_player = player;
	
	_text = (format["ADMIN (%1, %2): ", (name _player), (getPlayerUID _player)] + _text + toString [13,10]);
	[_text] call logThis;
};

admin_actions_list = {
	[
		["------ Admin Commands ------", {}],
		["Camera (Toggle)", {
			[] call camera_toggle;
		}],
		["Carmagedon", {
			private["_text"];
			_text = _this select 2;
			_distance = [(_text)] call parse_number;
			
			if (_distance <= 0) exitWith {};
			
			[format["Starting Carmagedon at %1 Meters", _distance]] call logAdmin;
			player groupchat format["Starting Carmagedon at a range of %1 meters", _distance];
			
			{
				{		
					if (({alive _x} count crew _x == 0)&&((count ([_x] call mounted_get_occupants)) <= 0)) then {
						deleteVehicle _x;
					};
				} foreach((getPosATL player) nearObjects [_x, _distance]);
			} forEach (droppableitems + ["LandVehicle", "Air", "Car", "Motorcycle", "Bicycle", "UAV", "Wreck", "Wreck_Base", 
						"HelicopterWreck", "UH1Wreck", "UH1_Base", "UH1H_base", "AH6_Base_EP1","CraterLong", "Ka60_Base_PMC", 
						"Ka137_Base_PMC", "A10"]);
		}],
		["Remove Statics",{
			private["_text"];
			_text = _this select 2;
			_distance = [(_text)] call parse_number;
			
			if (_distance <= 0) exitWith {};
			
			[format["Removing Statics at %1 Meters", _distance]] call logAdmin;
			player groupchat format["Removing Statics at a range of %1 meters", _distance];
			
			{
				{		
					if ((({alive _x} count (crew _x)) == 0)&&((count ([_x] call mounted_get_occupants)) <= 0)) then {
						deleteVehicle _x;
					};
				} foreach((getPosATL player) nearObjects [_x, _distance]);
			} forEach ["StaticWeapon"];
		}],
		["Remove Fortifications",{
			private["_text"];
			_text = _this select 2;
			_distance = [(_text)] call parse_number;
			
			if (_distance <= 0) exitWith {};
			
			[format["Removing Fortifications at %1 Meters", _distance]] call logAdmin;
			player groupchat format["Removing Fortifications at a range of %1 meters", _distance];
			
			{
				{
					if !(_x isKindOf "StaticWeapon") then {
						if (isNull(_x getVariable ["R3F_LOG_est_deplace_par", objNull])) then {
							deleteVehicle _x;
						};
					};
				} foreach((getPosATL player) nearObjects [_x, _distance]);
			} forEach R3F_LOG_CFG_objets_deplacables;
		}],
		["Remove Crates",{
			private["_text"];
			_text = _this select 2;
			_distance = [(_text)] call parse_number;
			
			if (_distance <= 0) exitWith {};
			
			[format["Removing Crates at %1 Meters", _distance]] call logAdmin;
			player groupchat format["Removing Crates at a range of %1 meters", _distance];
			
			{
				if (!(_x in bankflagarray) && !(_x in INV_ItemShops_IgnoreObjects)) then {
					deleteVehicle _x;
				};
			} foreach((getPosATL player) nearObjects ["ReammoBox", _distance]);
		}],
		["Remove Ammo/Weapon piles",{
			private["_text"];
			_text = _this select 2;
			_distance = [(_text)] call parse_number;
			
			if (_distance <= 0) exitWith {};
			
			[format["Wiping Gear Piles at %1 Meters", _distance]] call logAdmin;
			player groupchat format["Wiping gear at a range of %1 meters", _distance];
			
			{
				{
					clearMagazineCargoGlobal _x;
					clearWeaponCargoGlobal _x;
					clearBackpackCargoGlobal _x;
				} foreach((getPosATL player) nearObjects [_x, _distance]);
			} forEach ["ReammoBox", "LandVehicle", "Air", "Ship"];
		}],
		["Wipe Gear from Boxes/Vehicles",{
			private["_text"];
			_text = _this select 2;
			_distance = [(_text)] call parse_number;
			
			if (_distance <= 0) exitWith {};
			
			[format["Wiping Vehicle/Box Gear at %1 Meters", _distance]] call logAdmin;
			
			player groupchat format["Removing Piles at a range of %1 meters", _distance];
			
			{
				deleteVehicle _x;
			} foreach((getPosATL player) nearObjects ["WeaponHolder", _distance]);
		}],
		["Clear Bodies",{
			private["_text"];
			_text = _this select 2;
			_distance = [(_text)] call parse_number;
			
			if (_distance <= 0) exitWith {};
			
			player groupchat format["Removing Bodies at a range of %1 meters", _distance];
			
			{
				{
					if !(alive _x) then {
						deleteVehicle _x;
					};
				} foreach((getPosATL player) nearObjects [_x, _distance]);
			} forEach ["CAManBase"];
		}],
		["check player equipment", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			server globalChat format['%1-%2, Weapons: %3', _target, (name _target), weapons _target];
			server globalChat format['%1-%2, Magazines: %3', _target, (name _target), magazines _target];
		}],
		["Remove player weapons", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			[format["removed %1-%2 (%3)'s weapons", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			
			format['
				[] spawn {
					if (player != %1) exitWith {};
					[player] call player_reset_gear;
				};
			', _target] call broadcast;
		}],
		["check player total money", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			private["_money"];
			_money = [_target] call player_get_total_money;
			
			server globalChat format['%1-%2, Total money: %3', _target, (name _target), strM(_money)];
		}],
		["check player inventory money", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			private["_money"];
			_money = [_target, "money"] call INV_GetItemAmount;
			
			server globalChat format['%1-%2, Inventory money: %3', _target, (name _target), strM(_money)];
		}],
		["check player bank", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			private["_money"];
			_money = [_target] call bank_get_value;
			
			server globalChat format['%1-%2, Bank money: %3', _target, (name _target), strM(_money)];
		}],
		["check player private storage money", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			private["_money"];
			_money = [_target] call player_get_private_storage_money;
			
			server globalChat format['%1-%2, Bank money: %3', _target, (name _target), strM(_money)];
		}],
		["check player inventory", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			private["_array","_arrayDisplay","_itemArray","_item","_number"];
			_array = [];
			_arrayDisplay = [];
			
			_array = [_target] call player_get_inventory;
			{
				_itemArray = _x;
			
				_item = _itemArray select 0;
				_number = ([_target, _item] call INV_GetItemAmount);
				
				_arrayDisplay set[(count _arrayDisplay), [_item, _number]];
			} forEach _array;
			
			server globalChat format['%1-%2, Inventory: %3', _target, (name _target), _arrayDisplay];
		}],
		["Wipe player inventory", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			[format["wiped %1-%2 (%3)'s inventory", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			server globalChat format["Wiping %1-%2's Inventory", _target, (name _target)];
			
			[_target] call player_reset_side_inventory;
		}],
		["Kill player", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			[format["killed %1-%2 (%3)", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			
			format['
				[] spawn {
					if (player != %1) exitWith {};
					(player) setDamage 1; 
				};
			', _target] call broadcast;
		}],
		["Destroy player vehicle", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			[format["destroyed %1-%2 (%3)'s vehicle", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			
			format['
				[] spawn {
					if (player != %1) exitWith {};
					(vehicle player) setDamage 1; 
				};
			', _target] call broadcast;
		}],
		["Set player to ignore required playtime", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};

			[format["Set %1-%2 (%3) to ignore playtime", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			
			[_target, "ignoreFactionPlaytime", true] call player_set_bool;
			
			player groupChat format["Player %1(%2) is ignoring the required playtime now", _target, (name _target)];
			
			private["_message"];
			_message = "You are ignoring the required playtime now. Feel free to join blufor, insurent or opfor now.";
			format['if (player == %1) then {player groupChat toString(%2);};', _target, toArray(_message)] call broadcast;
		}],
		["Check Player playtime", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			[format["%1-%2 (%3): %4 Hours", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			
			private["_playTime"];
			_playTime = ([player] call ftf_getPlayTime) / 3600;
			server globalChat format["%1-%2: %3 Hours", _target, (name _target), _playTime];
			
		}],
		["Reset time(40m dy, 20m nt)", {
			player groupChat "Time reset (40-min day, 20-min night), please wait for synchronization to complete";
			[40,20] call time_reset;
		}],
		["MOTD (use input field)", {
			private["_text"];
			_text = _this select 2;
			custom_motd = _text;
			publicVariable "custom_motd";
		}],
		["Delete Target (Man)", {
			private["_target"];
			_target = cursorTarget;
			if (!(isNil "_target")) then {
				if (isPlayer _target) exitwith {};
				if (typeName _target == "OBJECT") then {
					if (_target isKindOf "Man" && !([_target] call object_shop)) then {
						[_target] call C_delete;
					};
				};
			};
		}],
		["------ White / Black Lists ------", {}],
		["COP - 1 List", {
			["COP_1"] spawn A_WBL_F_DIALOG_INIT;
		}],
		["BLANK", {}]
	]
};

admin_activate_command = { _this spawn {
	private["_player", "_command", "_text", "_target"];
	
	_player = _this select 0;
	_command = _this select 1;
	_text = _this select 2;
	_target = _this select 3;
	
	if (not([_player] call player_human)) exitWith {};
	
	if (isNil "_command") exitWith {};
	if (typeName _command != "STRING") exitWith {};
	
	_text = if (isNil "_text") then {""} else {_text};
	_text = if (typeName _text != "STRING") then {""} else {_text};
	
	private["_code"];
	_code = compile ( "_this call " + _command);
	[_player, _target, _text] spawn _code;
	sleep 1;
	hint "Code Activated";
};};

admin_functions_defined = true;