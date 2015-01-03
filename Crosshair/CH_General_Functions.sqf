#include "CH_Macros.h"

CH_General_UnlimitedAmmoMode =
{
	FUN_ARGS_2(_object,_override);
	if (CH_Harass_UnlimitedAmmoMode || _override) then
	{
		//(vehicle _object) addEventHandler ["Fired","[(_this select 0),(_this select 5),35] call CH_General_TopUpAmmo;"];
		//(vehicle _object) addEventHandler ["Fired","null = [(_this select 0),(_this select 5),30] execVM 'Crosshair\CH_InfiniteAmmo.sqf';"];
		(vehicle _object) addEventHandler ["Fired","null = [(_this select 0),(_this select 5),30] execVM 'Crosshair\CH_InfiniteAmmo.sqf';"];
		[["This object's current vehicle: %1 is now in unlimited ammo mode",_object],true,true] call CH_ImpMessage;
	};
};

CH_General_TopUpAmmo =
{
	FUN_ARGS_3(_unit,_magazine,_minimum);
	DECLARE(_vehicle) = vehicle _unit;
	DECLARE(_ammo) = (_vehicle ammo ((weapons _vehicle) select 0));
	//hintSilent format ["DEBUG:\n%1 current %2 ammo: %3\nMinimum: %4",_unit,_magazine,_ammo,_minimum];
	if (_ammo < _minimum) then
	{
		_vehicle setVehicleAmmo 1;
	};
};

CH_General_AttachSubTargets =
{
	// Creates the invisible targets that will be attached to the vehicle. Depends on side and size (laser,infantry,heavy,armour)
	FUN_ARGS_4(_vehicle,_side,_size,_distance);
	PVT_6(_xplane,_yplane,_zplane,_target_classname,_target,_target_array);
	_target_array = [];
	_vehicle setVariable ["CH_CanBeHarassed",true]; // unsure if public is required
	_target_classname = [_side,_size] call CH_General_ReturnSubTargetClassname;
	//_target_array = [_target_classname,_vehicle,_distance,false] call CH_SubTargets_Bottom9;
	_target_array = [_target_classname,_vehicle,_distance,true] call CH_SubTargets_Axes;
	//_target_array = [_target_classname,_vehicle,_distance,false] call CH_SubTargets_Top9;
	//_target_array = [_target_classname,_vehicle,_distance,false] call CH_SubTargets_FullCube;
	[_target_array] call CH_General_HideArrayOfObjects;
	[_target_array] call CH_General_DisallowDamageToArray;
	_vehicle setVariable ["CH_Vehicle_SubTarget_Array", _target_array, false];
};

CH_General_HideArrayOfObjects =
{
	FUN_ARGS_1(_target_array);
	if (CH_Debug_HideObjects) then
	{
		{
			[-2, {hideObject _this}, _x] call CBA_fnc_globalExecute; // Hiding has to be global
		} forEach _target_array;
	};
};

CH_General_DisallowDamageToArray =
{
	FUN_ARGS_1(_target_array);
	if (CH_Debug_InvincibleObjects) then
	{
		{
			_x allowDamage false;
		} forEach _target_array;
	};
};

CH_General_ReturnSubTargetClassname =
{
	FUN_ARGS_2(_side,_size);
	PVT_1(_classname);
	switch (_side) do
	{
		case BLU :
		{
			switch (_size) do
			{
				case SIZE_INF: {_classname = SUBTARGET_BLU_INFANTRY};
				case SIZE_ARM: {_classname = SUBTARGET_BLU_ARMOUR};
				case SIZE_HVY: {_classname = SUBTARGET_BLU_HEAVY};
				default {_classname = SUBTARGET_BLU_INFANTRY; [["Size not valid, defaulting to infantry size"],true,true] call CH_WarnMessage;};
			};
		};
		case OPF :
		{
			switch (_size) do
			{
				case SIZE_INF: {_classname = SUBTARGET_OPF_INFANTRY};
				case SIZE_ARM: {_classname = SUBTARGET_OPF_ARMOUR};
				case SIZE_HVY: {_classname = SUBTARGET_OPF_HEAVY};
				default {_classname = SUBTARGET_OPF_INFANTRY; [["Size not valid, defaulting to infantry size"],true,true] call CH_WarnMessage;};
			};
		};
		case IND :
		{
			switch (_size) do
			{
				case SIZE_INF: {_classname = SUBTARGET_IND_INFANTRY};
				case SIZE_ARM: {_classname = SUBTARGET_IND_ARMOUR};
				case SIZE_HVY: {_classname = SUBTARGET_IND_HEAVY};
				default {_classname = SUBTARGET_IND_INFANTRY; [["Size not valid, defaulting to infantry size"],true,true] call CH_WarnMessage;};
			};
		};
		case CIV :
		{
			switch (_size) do
			{
				case SIZE_INF: {_classname = SUBTARGET_CIV_INFANTRY};
				case SIZE_ARM: {_classname = SUBTARGET_CIV_ARMOUR};
				case SIZE_HVY: {_classname = SUBTARGET_CIV_HEAVY};
				default {_classname = SUBTARGET_CIV_INFANTRY; [["Size not valid, defaulting to infantry size"],true,true] call CH_WarnMessage;};
			};
		};
		default {[["Faction not valid! No Target classname was returned!"],true,true] call CH_ErrorMessage;};
	};
	if (CH_Debug_TestingObject) then
	{
		_classname = SUBTARGET_TEST;
		[["Debug is on: %1   Defaulting to testing target classname: %2",CH_Debug,SUBTARGET_TEST],true,true] call CH_WarnMessage;
	};
	_classname;
};

CH_General_ReturnSideString =
{
	FUN_ARGS_1(_object);
	PVT_1(_side_str);
	DECLARE(_side) = side _object;
	switch (_side) do
	{
		case BLU: {_side_str = BLU_STR};
		case OPF: {_side_str = OPF_STR};
		case IND: {_side_str = IND_STR};
		case CIV: {_side_str = CIV_STR};
		default {_side_str = CIV_STR; [["Side not valid, defaulting to civilian"],true,true] call CH_WarnMessage;};
	};
	_side_str;
};

CH_General_IsObjectWithinMaxRange =
{
	FUN_ARGS_3(_object1,_object2,_maximum);
	DECLARE(_within_range) = false;
	DECLARE(_distance) = _object1 distance _object2;
	if (_distance <= _maximum) then
	{
		_within_range = true;
	};
	_within_range;
};

CH_General_AdjustAIIntelligence =
{
	FUN_ARGS_2(_object,_on_off);
	if (_on_off) then
	{
		[_object] call CH_General_EnableAIBehaviour;
		CH_AIAdjustment = [_object,true]; // For the PEH
		publicVariable "CH_AIAdjustment";
	}
	else
	{
		[_object] call CH_General_DisableAIBehaviour;
		CH_AIAdjustment = [_object,false]; // For the PEH
		publicVariable "CH_AIAdjustment";
	};
	[["AI: %1 is intelligent: %2",_object,_on_off],false,true] call CH_LowMessage;
};

CH_General_DisableAIBehaviour =
{
	FUN_ARGS_1(_object);
	{
		_object disableAI _x;
	} forEach AI_BEHAVIOUR_ARRAY;
	_object enableSimulation false;
};

CH_General_EnableAIBehaviour =
{
	FUN_ARGS_1(_object);
	{
		_object enableAI _x;
	} forEach AI_BEHAVIOUR_ARRAY;
	_object enableSimulation true;
};

CH_General_IteratorToMax =
{
	FUN_ARGS_4(_start,_end,_store_location,_delay);
	DECLARE(_iterate) = false;
	DECLARE(_number) = _store_location getVariable ["CH_Iterator",0];
	sleep _delay;
	if (_number >= _end) then
	{
		_number = _start;
		[["ITERATOR: NUMBER RESET!",_start,_number,_end],true,true] call CH_LowMessage;
		_iterate = true;
		//hint "DEBUG: ITERATION!";
	}
	else
	{
		INC(_number);
	};
	_store_location setVariable ["CH_Iterator", _number, false];
	[["ITERATOR: Start: %1 Current Number: %2 Limit: %3",_start,_number,_end],false,true] call CH_LowMessage;
	_iterate;
};