#include "CH_Macros.h"

CH_SubTargets_AddCentre =
{
	FUN_ARGS_4(_centre,_vehicle,_target_array,_sub_classname);
	PVT_1(_target);
	if (_centre) then
	{
		_target = createVehicle [_sub_classname, CH_Spawn_Location, [], 50, "CAN_COLLIDE"];
		_target attachTo [_vehicle, [0,0,0]];
		PUSH(_target_array,_target);
	};
	_target_array;
};

CH_SubTargets_FullCube =
{
	FUN_ARGS_4(_target_classname,_vehicle,_distance,_centre);
	PVT_4(_zplane,_yplane,_xplane,_target);
	DECLARE(_target_array) = [];
	for "_zplane" from -1 to 1 do
	{
		for "_yplane" from -1 to 1 do
		{
			for "_xplane" from -1 to 1 do
			{
				_target = createVehicle [_target_classname, CH_Spawn_Location, [], 50, "CAN_COLLIDE"];
				_target attachTo [_vehicle, [(_xplane * _distance),(_yplane * _distance),(_zplane * _distance)]];
				if (SUBTARGET_CENTRESUB_PARAM && (!_centre)) then
				{
					deleteVehicle _target;
					[["Centre target removed"],true,true] call CH_LowMessage;
				};
				PUSH(_target_array,_target);
			};
		};
	};
	_target_array;
};

CH_SubTargets_Axes =
{
	FUN_ARGS_4(_target_classname,_vehicle,_distance,_centre);
	PVT_4(_zplane,_yplane,_xplane,_target);
	DECLARE(_target_array) = [];
	_target_array = [_centre,_vehicle,_target_array,_target_classname] call CH_SubTargets_AddCentre;
	_yplane = 0;
	_xplane = 0;
	for "_zplane" from -1 to 1 step 2 do
	{
		_target = createVehicle [_target_classname, CH_Spawn_Location, [], 50, "CAN_COLLIDE"];
		_target attachTo [_vehicle, [(_xplane * _distance),(_yplane * _distance),(_zplane * _distance)]];
		PUSH(_target_array,_target);
	};
	_zplane = 0;
	_xplane = 0;
	for "_yplane" from -1 to 1 step 2 do
	{
		_target = createVehicle [_target_classname, CH_Spawn_Location, [], 50, "CAN_COLLIDE"];
		_target attachTo [_vehicle, [(_xplane * _distance),(_yplane * _distance),(_zplane * _distance)]];
		PUSH(_target_array,_target);
	};
	_zplane = 0;
	_yplane = 0;
	for "_xplane" from -1 to 1 step 2 do
	{
		_target = createVehicle [_target_classname, CH_Spawn_Location, [], 50, "CAN_COLLIDE"];
		_target attachTo [_vehicle, [(_xplane * _distance),(_yplane * _distance),(_zplane * _distance)]];
		PUSH(_target_array,_target);
	};
	_target_array;
};

CH_SubTargets_Bottom9 =
{
	FUN_ARGS_4(_target_classname,_vehicle,_distance,_centre);
	PVT_3(_yplane,_xplane,_target);
	DECLARE(_target_array) = [];
	DECLARE(_zplane) = -1;
	_target_array = [_centre,_vehicle,_target_array,_target_classname] call CH_SubTargets_AddCentre;
	for "_yplane" from -1 to 1 do
	{
		for "_xplane" from -1 to 1 do
		{
			_target = createVehicle [_target_classname, CH_Spawn_Location, [], 50, "CAN_COLLIDE"];
			_target attachTo [_vehicle, [(_xplane * _distance),(_yplane * _distance),(_zplane * _distance)]];
			PUSH(_target_array,_target);
		};
	};
	_target_array;
};

CH_SubTargets_Top9 =
{
	FUN_ARGS_4(_target_classname,_vehicle,_distance,_centre);
	PVT_3(_yplane,_xplane,_target);
	DECLARE(_target_array) = [];
	DECLARE(_zplane) = 1;
	_target_array = [_centre,_vehicle,_target_array,_target_classname] call CH_SubTargets_AddCentre;
	for "_yplane" from -1 to 1 do
	{
		for "_xplane" from -1 to 1 do
		{
			_target = createVehicle [_target_classname, CH_Spawn_Location, [], 50, "CAN_COLLIDE"];
			_target attachTo [_vehicle, [(_xplane * _distance),(_yplane * _distance),(_zplane * _distance)]];
			PUSH(_target_array,_target);
		};
	};
	_target_array;
};