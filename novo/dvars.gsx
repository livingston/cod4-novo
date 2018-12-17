init()
{
    addDvar( "intro_text", "string", "Welcome to CoD4::Novo" ); // Big text that shows when you first spawn
	addDvar( "website", "string", "www.greasecourt.com" ); // Will show under ^ big text
	addDvar( "intro_time", "int", 6, 1, 20 ); // How long should intro big text stay?

    addDvar( "default_fps", "int", 0, 0, 1 ); // Fullbright setting, players won't be able to change it ( 1-enable ; 0-disable )
    addDvar( "default_fov", "int", 2, 0, 2 ); // Field of view setting, players won't be able to change it ( 2-FOV=100 ; 1-FOV=90 ; 0-FOV=80 )

    addDvar( "disable_gl", "int", 0, 0, 1 ); // Disable Grenade Launcher attachment ( 1-yes ; 0-no )
    addDvar( "disable_rpg", "int", 0, 0, 1 ); // Disable RPG-7 perk ( 1-yes ; 0-no )

    addDvar( "disable_laststand", "int", 1, 0, 1 ); // Disable LAST STAND perk ( 1-yes ; 0-no )
    addDvar( "disable_marty", "int", 1, 0, 1 ); // Disable MARTYDROP perk ( 1-yes ; 0-no )

    addDvar( "force_autoassign", "int", 1, 0, 1 ); // Force players to autoassign ( 1-enable ; 0-disable )

    addDvar( "gun_position", "int", 1, 0, 1 ); // More realistic gun positions on screen ( 1-yes ; 0-no )
}

// Function by OpenWarfare
/*
	addDvar( dvarName, dvarType, dvarDefault, minValue, maxValue )

	DVARNAME = Name of the dvar
	DVARTYPE = Type of the dvar ( int, float or string )
	DVARDEFAULT = Default value of the dvar
	MINVALUE = Min value of the dvar ( for int or float )
	MAXVALUE = Max value of the dvar ( for int or float )

	----------------------------------------------------------------

	Use above function to add a custom dvar, dvar value can then be accessed in "level.dvar[ dvarName ]" variable.
*/

addDvar( dvarName, dvarType, dvarDefault, minValue, maxValue )
{
	// Initialize the return value just in case an invalid dvartype is passed
	dvarValue = "";

	// Assign the default value if the dvar is empty
	if ( getdvar( dvarName ) == "" )
	{
		dvarValue = dvarDefault;
		setDvar( dvarName, dvarValue ); // initialize the dvar if it isn't in config file
	}

	else
	{
		// If the dvar is not empty then bring the value
		switch ( dvarType )
		{
			case "int":
				dvarValue = getdvarint( dvarName );
				break;

			case "float":
				dvarValue = getdvarfloat( dvarName );
				break;

			case "string":
				dvarValue = getdvar( dvarName );
				break;
		}
	}

	// Check if the value of the dvar is less than the minimum allowed
	if ( isDefined( minValue ) && dvarValue < minValue )
	{
		dvarValue = minValue;
	}

	// Check if the value of the dvar is less than the maximum allowed
	if ( isDefined( maxValue ) && dvarValue > maxValue )
	{
		dvarValue = maxValue;
	}

	level.dvar[ dvarName ] = dvarValue;
}