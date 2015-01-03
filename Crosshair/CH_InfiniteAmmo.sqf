#include "CH_Macros.h"

FUN_ARGS_3(_unit,_magazine,_minimum);
DECLARE(_vehicle) = vehicle _unit;
DECLARE(_ammo) = (_vehicle ammo ((weapons _vehicle) select 0));
//hintSilent format ["DEBUG:\n%1 current %2 ammo: %3\nMinimum: %4",_unit,_magazine,_ammo,_minimum];
if (_ammo < _minimum) then
{
	_vehicle setVehicleAmmo 1;
};