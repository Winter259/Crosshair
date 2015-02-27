#include "CH_Macros.h"

// object getVariable [name, defaultValue]
// objectName setVariable [name, value, (public)]

CH_CreateHarassmentUnit =
{
	FUN_ARGS_4(_classname,_harasser_side,_static,_engagement_range);
	PVT_2(_harasser,_harasser_group);
	DECLARE(_harasser_group) = createGroup _harasser_side;
	DECLARE(_harasser) = _harasser_group createUnit [_classname,CH_Spawn_Location,[],0,"NONE"];
	DECLARE(_enemy_sides_array) = [_harasser] call CH_Harass_ReturnEnemySides;
	sleep 0.5;
	[["Harasser created: %1 on side: %2 in group: %3",_harasser,_harasser_side,_harasser_group],true,true] call CH_ImpMessage;
	_harasser moveInGunner _static;
	_harasser setVariable ["ace_sys_overheating_cbh", 0, true];
	_harasser setVariable ["ace_sys_overheating_temp", 0, true];
	_static setVariable ["ace_sys_overheating_cbh", 0, true];
	_static setVariable ["ace_sys_overheating_temp", 0, true];
	_engagement_range = [_engagement_range] call CH_Harass_ValidateEngagementRange;
	[_harasser,_engagement_range] call CH_Harass_InitHarasser;
	[_harasser,_engagement_range,_enemy_sides_array] spawn CH_Harass_Routines;
	_harasser;
};

CH_HarassThisUnit =
{
	FUN_ARGS_1(_object);
	_object setVariable ["CH_Harassable",true,false];
	[["This object: %1 is now harrassable",_object],true,true] call CH_ImpMessage;
	PUSH(CH_Harassable_Units,_object);
};

CH_Harass_Routines =
{
	FUN_ARGS_3(_harasser,_engagement_range,_enemy_sides_array);
	PVT_2(_valid_targets,_chosen_target);
	while {alive _harasser} do
	{
		sleep HARASS_CHECKTARGET_DELAY;
		_valid_targets = [_harasser,_engagement_range,_enemy_sides_array] call CH_Harass_Routine_CheckForTargets;
		_chosen_target = [_valid_targets] call CH_Harass_Routine_ChooseTarget;
		[_harasser,_chosen_target,_engagement_range] call CH_Harass_Routine_TrackandAttackTarget;
		[_harasser] call CH_Harass_Routine_ReturnToIdle;
	};
};

CH_Harass_ValidateEngagementRange =
{
	FUN_ARGS_1(_engagement_range);
	if (isNil "_engagement_range") then
	{
		_engagement_range = 600;
		[["Harasser Engagement Range was not set! Defaulting to %1m",_engagement_range],true,true] call CH_WarnMessage;
	};
	_engagement_range;
};

CH_Harass_EnableAnimationOnDamage =
{
	FUN_ARGS_1(_object);
	_object addMPEventHandler
	[
		"MPHit",
		{
			if (!(simulationEnabled (_this select 0))) then
			{
				(_this select 0) enableSimulation true;
			};
		}
	];
};

CH_Harass_InitHarasser =
{
	FUN_ARGS_2(_harasser,_engagement_range);
	[_harasser,false] call CH_General_UnlimitedAmmoMode;
	[_harasser] call CH_Harass_EnableAnimationOnDamage;
	DEBUG
	{
		[_harasser,_engagement_range] spawn CH_Debug_RangeMarker;
	};
	[_harasser,false] call CH_General_AdjustAIIntelligence;
	(group _harasser) setBehaviour "AWARE";
	_harasser setSkill CH_Harass_SkillLevel;
	//_harasser setVariable ["CH_Iterator", 0, false]; // Currently Unused
	PUSH(CH_Harass_Units,_harasser);
	[["This object: %1 is now a harasser. Target Ignore Bias: %2. Harasser Skill level: %3. Engagement Range: %4",_harasser,CH_Harass_IgnoreValidTargetBias,CH_Harass_SkillLevel,_engagement_range],true,true] call CH_ImpMessage;
};

CH_Harass_ReturnEnemySides =
{
	// Returns the sides that the harasser is an enemy to as an array.
	FUN_ARGS_1(_harasser);
	DECLARE(_enemy_sides_array) = [];
	DECLARE(_harasser_enemies) = [];
	DECLARE(_harasser_side) = side _harasser;
	PVT_1(_friend_coeff); // <0.6 means enemy, ref: https://community.bistudio.com/wiki/getFriend
	{
		_friend_coeff = _harasser_side getFriend _x;
		[["Harasser Side: %1 vs Side: %2, Friendship Coefficient: %3",_harasser_side,_x,_friend_coeff],false,true] call CH_LowMessage;
		if (_friend_coeff < 0.6) then
		{
			PUSH(_enemy_sides_array,_x);
		};
	} forEach SIDE_ARRAY;
	if ((count _enemy_sides_array) == 0) then
	{
		[["Harasser does not have any enemies to shoot at! Enemy Sides Array: %1",_enemy_sides_array],true,true] call CH_ErrMessage;
	}
	else
	{
		[["Harasser is enemy to these sides: %1",_enemy_sides_array],true,true] call CH_ImpMessage;
	};
	_enemy_sides_array;
};

CH_Harass_Routine_CheckForTargets =
{
	FUN_ARGS_3(_harasser,_engagement_range,_enemy_sides_array);
	PVT_1(_nearby_units);
	DECLARE(_valid_targets) = [];
	if (alive _harasser) then
	{
		//[["Harasser: %1, initiating a target check.",_harasser],false,true] call CH_LowMessage;
		_nearby_units = nearestObjects [(getPosATL _harasser),["CAManBase","AllVehicles"],_engagement_range];
		_nearby_units = _nearby_units - [_harasser]; // remove the harasser from the list.
		_nearby_units = _nearby_units - [(vehicle _harasser)];
		[["Harasser: %1, units within range: %2",_harasser,_nearby_units],false,true] call CH_LowMessage;
		_valid_targets = [_nearby_units,_enemy_sides_array] call CH_Harass_FilterTargets;
		[["Harasser: %1, valid targets within range: %2",_harasser,_valid_targets],false,true] call CH_LowMessage;
	};
	_valid_targets;
};

CH_Harass_FilterTargets =
{
	FUN_ARGS_2(_nearby_units,_enemy_sides_array);
	DECLARE(_valid_targets) = [];
	PVT_1(_i);
	{
		//[["Current Target being checked: %1 Side: %2",_x,side _x],false,true] call CH_LowMessage;
		if ((side _x) in _enemy_sides_array) then
		{
			_valid_targets set [(count _valid_targets),_x];
			//[["Valid Target: %1",_x],false,true] call CH_LowMessage;
		};
	} forEach _nearby_units;
	_valid_targets;
};

CH_Harass_ValidateTargetArray =
{
	FUN_ARGS_1(_prevalidated_targets_array);
	DECLARE(_validated_targets_array) = [];
	DECLARE(_validated_buffer) = [];
	//[["Prevalidated array: %1",_prevalidated_targets_array],false,true] call CH_LowMessage;
	if (CH_Harass_TargetOnlyHarrasableUnits) then
	{
		FILTER_PUSH_ALL(_validated_buffer,_prevalidated_targets_array,{_x in CH_Harassable_Units});
	}
	else
	{
		_validated_buffer = _prevalidated_targets_array;
	};
	if (CH_Harass_MinimumAltitudeRequired) then
	{
		FILTER_PUSH_ALL(_validated_targets_array,_validated_buffer,{ALTITUDE(_x) >= CH_Harass_MinimumTargetAltitude});
	}
	else
	{
		PUSH_ALL(_validated_targets_array,_validated_buffer);
	};
	if ((count _validated_targets_array) == 0) then
	{
		_validated_targets_array = [objNull];
		[["No valid targets are current within range"],false,true] call CH_LowMessage;
	}
	else
	{
		[["Validated array: %1",_validated_targets_array],false,true] call CH_LowMessage;
	};
	_validated_targets_array;
};

CH_Harass_Routine_ChooseTarget =
{
	FUN_ARGS_1(_valid_targets);
	PVT_2(_random_number,_chosen_target);
	_valid_targets = [_valid_targets] call CH_Harass_ValidateTargetArray;
	_chosen_target = _valid_targets select 0;
	// If more than one valid target is available, then a random one will be chosen.
	if ((count _valid_targets) > 1) then
	{
		_random_number = random 1;
		[["More than one valid target is available. One will be chosen at random: %1",(_random_number < CH_Harass_ChooseRandomTargetBias)],false,true] call CH_LowMessage;
		if (_random_number < CH_Harass_ChooseRandomTargetBias) then
		{
			_chosen_target = SELECT_RAND(_valid_targets);
		};
	};
	// If random < CH_Harass_IgnoreValidTargetBias, The harasser will not fire at the target. This is run every time there is a check for targets.
	if (CH_Harass_IgnoreTargets && (!isNull _chosen_target)) then
	{
		_random_number = random 1;
		[["Ignore Level: %1, AI Level: %2, Target: %3 Ignored: %4",CH_Harass_IgnoreValidTargetBias,_random_number,_chosen_target,(_random_number < CH_Harass_IgnoreValidTargetBias)],false,true] call CH_LowMessage;
		if (_random_number < CH_Harass_IgnoreValidTargetBias) then
		{
			_chosen_target = ObjNull;
		};
	};
	if (!(isNull _chosen_target)) then
	{
		[["Final chosen target: %1",_chosen_target],false,true] call CH_LowMessage;
	};
	_chosen_target;
};

CH_Harass_ValidateSubtargets =
{
	FUN_ARGS_1(_target);
	DECLARE(_array) = _target getVariable ["CH_Vehicle_SubTarget_Array",[]];
	DECLARE(_valid) = true;
	if ((count _array) == 0) then
	{
		_valid = false;
		[["This target: %1 lacks a subtarget array: %2",_target,_array],true,true] call CH_ErrMessage;
	};
	_valid;
};

CH_Harass_Routine_ChooseSubTarget =
{
	FUN_ARGS_2(_chosen_target,_previous_subtarget);
	DECLARE(_subtarget_array) = _chosen_target getVariable ["CH_Vehicle_SubTarget_Array",[]];
	DECLARE(_valid) = [_chosen_target] call CH_Harass_ValidateSubtargets;
	PVT_1(_chosen_subtarget);
	//hintSilent format ["DEBUG: Array Valid: %1",_valid];
	//hintSilent format ["DEBUG: Previous Target: %1",_previous_subtarget];
	if (_valid) then
	{
		if (CH_Harass_RandomSubTarget || (isNull _previous_subtarget)) then
		{
			_chosen_subtarget = SELECT_RAND(_subtarget_array);
		}
		else
		{
			_chosen_subtarget = _previous_subtarget;
		};
		[["Target: %1 Chosen Subtarget: %2",_chosen_target,_chosen_subtarget],true,true] call CH_LowMessage;
	}
	else
	{
		_chosen_subtarget = _chosen_target;
		[["No subtargets are available, the target itself is being used instead"],true,true] call CH_WarnMessage;
	};
	_chosen_subtarget;
};

CH_Harass_Routine_TrackandAttackTarget =
{
	FUN_ARGS_3(_harasser,_chosen_target,_engagement_range);
	DECLARE(_subtarget_array) = _chosen_target getVariable ["CH_Vehicle_SubTarget_Array",[]];
	DECLARE(_chosen_subtarget) = ObjNull;
	PVT_1(_relative_dir);
	if ((count _subtarget_array) == 0) then
	{
		[["Harasser: %1 chose a target: %2 that lacks subtargets!: %3",_harasser,_chosen_target,_subtarget_array],true,true] call CH_ErrMessage;
		_chosen_target = ObjNull;
	};
	DEBUG
	{
		[_chosen_target,_harasser,_engagement_range] spawn CH_Debug_TrackTarget;
	};
	if (!isNull _chosen_target) then
	{
		[["Harasser: %1 behaviour: ATTACKING TARGET: %2",_harasser,_chosen_target],false,true] call CH_LowMessage;
	};
	while 
	{
		(!isNull _chosen_target) && ([_harasser,_chosen_target,_engagement_range] call CH_General_IsObjectWithinMaxRange) && (alive _chosen_target) && (alive _harasser)
	}
	do
	{
		// attack, only if the target is not null & it is still within engagement range.
		_chosen_subtarget = [_chosen_target,_chosen_subtarget] call CH_Harass_Routine_ChooseSubTarget;
		_relative_dir = [_harasser,_chosen_subtarget] call BIS_fnc_relativeDirTo;
		_harasser reveal [_chosen_subtarget,CH_Harass_KnowsAbout];
		//_harasser reveal [_chosen_target,0];
		_harasser reveal [_chosen_subtarget,4];
		_harasser setDir _relative_dir;
		_harasser lookAt (getposATL _chosen_subtarget);
		sleep HARASS_ALIGNTARGET_DELAY;
		[_harasser,_chosen_subtarget,CH_Harass_ChangeTargetCap] call CH_Harass_Routine_FireBurstAtTarget;
	};
};

CH_Harass_Routine_FireBurstAtTarget =
{
	FUN_ARGS_3(_harasser,_target,_limit);
	PVT_1(_i);
	for "_i" from 0 to _limit do
	{
		_harasser doTarget _target;
		_harasser doWatch (getposATL _target);
		(vehicle _harasser) fireAtTarget [_target,(weapons (vehicle _harasser) select 0)];
		sleep HARASS_ATTACKTARGET_DELAY;
	};
	//_harasser doWatch objNull;
	_harasser doTarget objNull;
	_harasser lookAt (getposATL _target);
	sleep HARASS_ATTACKCOOLDOWN_DELAY;
};

CH_Harass_Routine_ReturnToIdle =
{
	FUN_ARGS_1(_harasser);
	if (alive _harasser) then
	{
		_harasser doWatch objNull; // removes any targets from the harasser
		[["Harasser: %1 behaviour: IDLE",_harasser],false,true] call CH_LowMessage;
	}
	else
	{
		[_harasser] call CH_Harass_HarasserDeath;
	};
};

CH_Harass_HarasserDeath =
{
	FUN_ARGS_1(_harasser);
	if (!(alive _harasser)) then
	{
		CH_Harass_Units = CH_Harass_Units - [_harasser];
		[["Harasser: %1 has been killed",_harasser],true,true] call CH_ImpMessage;
	};
};

CH_Harass_HarassableDeath =
{
	FUN_ARGS_1(_harassable);
	if (!(alive _harassable)) then
	{
		CH_Harassable_Units = CH_Harassable_Units - [_harassable];
		[["Harassable: %1 has been killed",_harassable],true,true] call CH_ImpMessage;
	};
};

CH_Harass_TrackHarassableStatus =
{
	FUN_ARGS_1(_object);
	[_object,0.5] spawn CH_Debug_CheckHarassableStatus;
	while {alive _object} do
	{
		sleep 2;
	};
	//hint "DEBUG: Test unit dead";
	[_object] call CH_Harass_HarassableDeath;
};