#include "CH_Macros.h"

CH_DebugMessage =
{
	FUN_ARGS_4(_message,_level,_rpt,_screen);
	if (CH_Debug) then
	{
		if (((_level == DEBUG_LOW) && CH_Debug_LowLevel) || ((_level == DEBUG_WARN) && CH_Debug_WarnLevel) || ((_level == DEBUG_ERR) && CH_Debug_ErrorLevel) || (_level == DEBUG_IMP)) then
		{
			if (_rpt) then
			{
				diag_log format ["%1-[%2]: %3",DEBUG_HEADER,_level,(format _message)];
			};
			if (_screen) then
			{
				player sideChat format ["%1-[%2]: %3",DEBUG_HEADER,_level,(format _message)];
			};
		};
	};
};

CH_ErrorMessage =
{
	FUN_ARGS_3(_message,_rpt,_screen);
	[_message,DEBUG_ERR,_rpt,_screen] call CH_DebugMessage;
};

CH_LowMessage =
{
	FUN_ARGS_3(_message,_rpt,_screen);
	[_message,DEBUG_LOW,_rpt,_screen] call CH_DebugMessage;
};

CH_ImpMessage =
{
	FUN_ARGS_3(_message,_rpt,_screen);
	[_message,DEBUG_IMP,_rpt,_screen] call CH_DebugMessage;
};

CH_WarnMessage =
{
	FUN_ARGS_3(_message,_rpt,_screen);
	[_message,DEBUG_WARN,_rpt,_screen] call CH_DebugMessage;
};

CH_Debug_CheckHarasserStatus =
{
	FUN_ARGS_2(_object,_delay);
	while {true} do
	{
		hintSilent format ["CH DEBUG\nTime: %1\n%2 is alive: %3\nVeh %4 is alive: %5\nCurrent Harassment Units:\n%6",time,_object,(alive _object),(vehicle _object),(alive (vehicle _object)),CH_Harass_Units];
		sleep _delay;
	};
};

CH_Debug_CheckHarassableStatus =
{
	FUN_ARGS_2(_object,_delay);
	while {true} do
	{
		hintSilent format ["CH DEBUG\nTime: %1\n%2 is alive: %3\nVeh %4 is alive: %5\nCurrent Harassable Units:\n%6",time,_object,(alive _object),(vehicle _object),(alive (vehicle _object)),CH_Harassable_Units];
		sleep _delay;
	};
};

CH_Debug_TrackAltitude =
{
	FUN_ARGS_2(_object,_delay);
	DECLARE(_altitude) = ALTITUDE(_object);
	while {true} do
	{
		_altitude = floor ALTITUDE(_object);
		hintSilent format ["CH DEBUG\nTime: %1\n%2 Altitude: %3m\nMinimum: %4m\nAbove minimum: %5",time,_object,_altitude,CH_Harass_MinimumTargetAltitude,(_altitude >= CH_Harass_MinimumTargetAltitude)];
		sleep _delay;
	};
};

CH_Debug_CompareTargetVsEyePos =
{
	FUN_ARGS_3(_harasser,_target,_delay);
	while {true} do
	{
		hintSilent format ["CH DEBUG\nTime: %1\n%2 Eye Pos: %3\n%4 Pos: %5",time,_harasser,(eyePos _harasser),_target,(getposASL _target)];
		sleep _delay;
	};
};

CH_Debug_TrackKnowsAbout =
{
	FUN_ARGS_3(_harasser,_target,_delay);
	while {true} do
	{
		hintSilent format ["CH DEBUG\nTime: %1\n%2 knows target: %3\n%4 knows harasser: %5",time,_harasser,(_harasser knowsAbout _target),_target,(_target knowsAbout _harasser)];
		sleep _delay;
	};
};

CH_Debug_TrackEyePos =
{
	FUN_ARGS_2(_object,_delay);
	while {true} do
	{
		hintSilent format ["CH DEBUG\nTime: %1\n%2 eyePos: %3",time,_object,(eyePos _object)];
		sleep _delay;
	};
};

CH_Debug_TrackAimPos =
{
	FUN_ARGS_2(_object,_delay);
	while {true} do
	{
		hintSilent format ["CH DEBUG\nTime: %1\n%2 AimPos: %3",time,_object,(aimPos _object)];
		sleep _delay;
	};
};

CH_Debug_CreateObjectOnEyePos =
{
	FUN_ARGS_2(_harasser,_delay);
	DECLARE(_eyepos_object) = createVehicle ["Sign_sphere100cm_EP1", (getposASL _harasser), [], 0,"CAN_COLLIDE"];
	while {true} do
	{
		_eyepos_object setposASL (eyePos _harasser);
		sleep _delay;
	};
};

CH_Debug_CreateObjectOnAimPos =
{
	FUN_ARGS_2(_harasser,_delay);
	DECLARE(_aimpos_object) = createVehicle ["Sign_sphere100cm_EP1", (getposASL _harasser), [], 0,"CAN_COLLIDE"];
	while {true} do
	{
		_aimpos_object setposASL (aimPos _harasser);
		sleep _delay;
	};
};

CH_Debug_TrackHarasserAmmo =
{
	FUN_ARGS_2(_harasser,_delay);
	while {true} do
	{
		hintSilent format ["Harasser: %1\nVehicle Weapon: %2\nAmmo Level: %3",_harasser,(weapons (vehicle _harasser)),((vehicle _harasser) ammo ((weapons (vehicle _harasser)) select 0))];
		sleep _delay;
	};
};

CH_Debug_TrackRelativeDirection =
{
	FUN_ARGS_3(_harasser,_target,_delay);
	PVT_1(_relative_dir);
	while {true} do
	{
		_relative_dir = [_harasser,_target] call BIS_fnc_relativeDirTo;
		hintSilent format ["Harasser: %1\nPos: %2\nTarget: %3\nPos: %4\nRelative Dir: %5",_harasser,(getposASL _harasser),_target,(getposASL _target),_relative_dir];
		sleep _delay;
	};
};

CH_Debug_Marker =
{
	FUN_ARGS_7(_object,_size,_shape,_type,_text,_colour,_alpha);
	DECLARE(_position) = getposATL _object;
	DECLARE(_direction) = direction _object;
	PVT_1(_marker);
	_marker = createMarker [(str (floor time) + "Marker" + str(floor random 1000)),_position];
	_marker setMarkerAlpha _alpha;
	_marker setMarkerPos _position;
	_marker setMarkerText _text;
	_marker setMarkerSize _size;
	_marker setMarkerShape _shape;
	if (_shape == "ICON") then
	{
		_marker setMarkerType _type;
	};
	_marker setMarkerDir _direction;
	_marker setMarkerColor _colour;
	_marker setMarkerBrush "Solid";
	PUSH(CH_DebugMarkers,_marker);
	_marker;
};

CH_Debug_DeleteMarker =
{
	FUN_ARGS_1(_marker);
	deleteMarker _marker;
	CH_DebugMarkers = CH_DebugMarkers - [_marker];
};

CH_Debug_DeleteAllMarkers =
{
	{
		deleteMarker _x;
	} forEach CH_DebugMarkers;
	CH_DebugMarkers = [];
};

CH_Debug_RangeMarker =
{
	FUN_ARGS_2(_object,_size);
	PVT_1(_marker);
	_marker = [_object,[_size,_size],"ELLIPSE","","","ColorOrange",1] call CH_Debug_Marker;
	waitUntil
	{
		!alive _object;
		sleep DEBUG_UNIT_ALIVE_MARKER_DELAY;
	};
	[_marker] call CH_Debug_DeleteMarker;
};

CH_Debug_TargetMarker =
{
	FUN_ARGS_1(_object);
	PVT_1(_marker);
	_marker = [_object,[1,1],"ICON","mil_triangle","Target","ColorRed",1] call CH_Debug_Marker;
	_marker;
};

CH_Debug_TrackTarget =
{
	FUN_ARGS_3(_object,_point_of_reference,_max_range);
	PVT_1(_marker);
	if (!isNull _object) then
	{
		_marker = [_object] call CH_Debug_TargetMarker;
		while {(alive _object) && ([_object,_point_of_reference,_max_range] call CH_General_IsObjectWithinMaxRange)} do
		{
			_marker setMarkerPos [((getposATL _object) select 0),((getposATL _object) select 1)];
			_marker setMarkerDir (direction _object);
			sleep DEBUG_TARGET_MARKER_DELAY;
		};
		[_marker] call CH_Debug_DeleteMarker;
	};
};