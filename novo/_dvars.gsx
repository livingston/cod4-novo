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

    addDvar( "scr_novo_testmap", "string", "mp_killhouse" );
    addDvar( "scr_novo_highjump", "int", 0, 0, 1 );

    addDvar( "scr_novo_jump_height", "int", 180, 0, 999 );
    addDvar( "scr_novo_falldamage_minheight", "int", 200, 0, 9999 );
    addDvar( "scr_novo_falldamage_maxheight", "int", 350, 0, 9999 );

    addDvar( "old_hardpoints", "int", 0, 0, 1 ); // Hardpoints based off killstreak ( 1-yes ; 0-no )

    // Hardpoints shop - required credits
    addDvar( "shop_radar", "int", 20, 1 );
    addDvar( "shop_airstrike", "int", 70, 1 );
    addDvar( "shop_helicopter", "int", 180, 1 );
    addDvar( "shop_artillery", "int", 70, 1 );
    addDvar( "shop_asf", "int", 100, 1 );
    addDvar( "shop_agm", "int", 100, 1 );
    addDvar( "shop_predator", "int", 280, 1 );
    addDvar( "shop_ac130", "int", 380, 1 );
    addDvar( "shop_mannedheli", "int", 500, 1 );
    addDvar( "shop_nuke", "int", 600, 1 );
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
