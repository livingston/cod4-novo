#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include novo\_utils;

// Original Author: Duffy

init()
{
    addMenuOption( "MENU_EDITOR", "main", ::ClassEditor, undefined, true, "none" );
    addMenuOption( "MENU_LASER",  "main", ::ToggleLaser, undefined, true, "none" );

	// Admin Menu
	addSubMenu( "MENU_DEV", "dev", "super" );
		addMenuOption("Add Test Bot", "dev", ::addBot, undefined, false, "none" );
		addMenuOption("Remove All Bots", "dev", ::removeBots, undefined, false, "none" );

    // thread novo\_events::addConnectEvent( novo\_common::useConfig );
    thread onPlayerConnected();
    thread DvarCheck();

    level.shaders = StrTok( "ui_host;line_vertical;nightvision_overlay_goggles;hud_arrow_left",";" );

	for( i = 0; i < level.shaders.size; i++ )
		PreCacheShader( level.shaders[i] );
}

onPlayerConnected()
{
    for(;;)
    {
		level waittill( "connected", player );

		if( !isDefined( player.pers[ "forceLaser" ] ) )
        {
			forceLaser = player novo\_common::getCvarInt( "laser" );
			player.pers["forceLaser"] = forceLaser;

			player setClientDvar( "cg_laserForceOn", forceLaser );
		}

		player thread ToggleMenu();
		player thread openClickMenu();
		// player thread onPlayerSpawn();
	}
}

// onPlayerSpawn() {
// 	self endon( "disconnect" );

// 	while(1) {
// 		self common_scripts\utility::waittill_any( "disconnect", "spawned" );

// 		wait .05;


// 		forceLaser = self.pers[ "forceLaser" ];
// 		self setClientDvar( "cg_laserForceOn",  forceLaser );
// 	}
// }

DvarCheck()
{
	wait 6;

	while(1)
    {
		SetDvar( "menu", "" );

        while( GetDvar( "menu" ) == "" ) wait .1;

		player = novo\_common::getPlayerByNum( getDvar( "menu" ) );

        if( isDefined( player ) )
			player notify( "open_menu" );
	}
}

ToggleMenu()
{
	self endon( "disconnect" );

    while(1)
    {
		self waittill( "night_vision_on" );

		self thread endNpressTimer();
		self NpressTimer();
	}
}

endNpressTimer()
{
	self endon( "disconnect" );
	self endon( "open_menu" );

	wait 2;
	self notify( "end_menu_toggle" );
}

NpressTimer() {
	self endon( "disconnect" );
	self endon( "end_menu_toggle" );
	self endon( "night_vision_on" );
	self endon( "close_menu" );

    self waittill( "night_vision_off" );

    self notify( "open_menu" );
}

openClickMenu()
{
	self endon( "disconnect" );

	self.inmenu = false;
	wait 6;

	for(;;wait .05)
    {
		self waittill( "open_menu" );

		if( !self.inmenu )
        {
			self.inmenu = true;

			for( i = 0; self.sessionstate == "playing" && !self isOnGround() && i < 60 || game["state"] != "playing"; wait .05 )
            {
                i++;
            }

			self thread Menu();
			//self disableWeapons();

			if( self.health > 0 )
            {
				wait .05;
				self.currentWeapon = self getCurrentWeapon();
				self giveWeapon( "briefcase_bomb_mp" );
				self setWeaponAmmoStock( "briefcase_bomb_mp", 0 );
				self setWeaponAmmoClip( "briefcase_bomb_mp", 0 );

                wait .05;
				self switchToWeapon( "briefcase_bomb_mp" );
			}

			self allowSpectateTeam( "allies", false );
			self allowSpectateTeam( "axis", false );
			self allowSpectateTeam( "none", false );
		}
		else
			self endMenu();
	}
}

endMenu()
{
	self notify( "close_menu" );

	for( i = 0; i < self.menu.size; i++ )
        self.menu[i] thread FadeOut( 1, true, "right" );

	self thread Blur( 2, 0 );
	self.menubg thread FadeOut( 1 );

	self freezeControls(false);
	self maps\mp\gametypes\_spectating::setSpectatePermissions();

	/*self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "freelook", true );
	self allowSpectateTeam( "none", true );*/

    if( isDefined( self.currentWeapon ) && self.health > 0)
    {
		if( self.currentWeapon != "none" )
			self switchToWeapon( self.currentWeapon );

        wait .05;
		self TakeWeapon( "briefcase_bomb_mp" );
	}

	wait 2;
	self.inmenu = false;
}

FadeOut( time, slide, dir)
{
	if( !isDefined( self ) ) return;

	if( isdefined( slide ) && slide )
    {
		self MoveOverTime( 0.2 );

        if( isDefined( dir ) && dir == "right" )
            self.x += 600;
        else
            self.x -= 600;
	}

	self FadeOverTime(time);
	self.alpha = 0;

    wait time;
	if( isDefined( self ))
        self destroy();
}

FadeIn( time, slide, dir )
{
	if( !isDefined( self ) ) return;

	if( isdefined( slide ) && slide)
    {
		if( isDefined( dir ) && dir == "right" )
            self.x += 600;
		else
            self.x -= 600;

		self MoveOverTime( 0.2 );

        if( isDefined( dir ) && dir == "right")
            self.x -= 600;
		else
            self.x += 600;
	}

	alpha = self.alpha;
	self.alpha = 0;

    self FadeOverTime(time);
	self.alpha = alpha;
}

Blur( start, end )
{
	self notify( "newblur" );

    self endon( "newblur" );
	self endon( "disconnect" );

	start = start * 10;
	end = end * 10;


    if( start <= end )
    {
		for( i = start; i < end; i++ )
        {
			self SetClientDvar( "r_blur", i / 10 );
			wait .05;
		}
	}
	else
    {
        for( i = start; i>= end; i-- )
        {
		    self SetClientDvar( "r_blur", i / 10 );
            wait .05;
        }
	}
}

GetMenuStuct( menu )
{
	itemlist = "";

    for( i = 0; i < level.menuoption[ "name" ][ menu ].size; i++ )
    {
        menuItemLabel = level.menuoption[ "name" ][ menu ][ i ];

        itemlist = itemlist + self novo\_common::translate( menuItemLabel ) + "\n";
	}

	return itemlist;
}

// Author BraXi
addTextHud( who, x, y, alpha, alignX, alignY, vert, fontScale, sort )
{
	if( isPlayer( who ) )
        hud = NewClientHudElem( who );
	else
        hud = NewHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;

	if( isdefined( vert ) )
		hud.horzAlign = vert;

	if( fontScale != 0 )
		hud.fontScale = fontScale;

	hud.archived = false;

    return hud;
}

addMenuOption( displayname, menu, script, args, end, permission )
{
	if( !isDefined( level.menuoption ) )
        level.menuoption[ "name" ] = [];

	if( !isDefined( level.menuoption["name"][menu]) )
        level.menuoption[ "name" ][ menu ] = [];

	index = level.menuoption[ "name" ][ menu ].size;
	level.menuoption[ "name" ][ menu ][ index ] = displayname;
	level.menuoption[ "script" ][ menu ][ index ] = script;
	level.menuoption[ "arguments" ][ menu ][ index ] = args;
	level.menuoption[ "end" ][ menu ][ index ] = end;
	level.menuoption[ "permission" ][ menu ][ index ] = permission;
}

addSubMenu( displayname, name, permission)
{
	addMenuOption( displayname, "main", name, "", false, permission);
}

Menu()
{
	self endon( "close_menu" );
	self endon( "disconnect" );

	self thread Blur( 0, 2 );

    submenu = "main";

    self.menu[0] = addTextHud( self, -200, 0, .6, "left", "top", "right", 0, 101 );
    self.menu[0] SetShader( "nightvision_overlay_goggles", 400, 650 );
    self.menu[0] thread FadeIn( .5, true, "right" );

	self.menu[1] = addTextHud( self, -200, 0, .5, "left", "top", "right", 0, 101 );
    self.menu[1] SetShader( "black", 400, 650 );
    self.menu[1] thread FadeIn( .5, true, "right" );

	self.menu[2] = addTextHud( self, -200, 89, .5, "left", "top", "right", 0, 102 );
	self.menu[2] SetShader( "line_vertical", 600, 22 );
    self.menu[2] thread FadeIn( .5, true, "right" );

	self.menu[3] = addTextHud( self, -190, 93, 1, "left", "top", "right", 0, 104 );
	self.menu[3] SetShader( "ui_host", 14, 14 );
    self.menu[3] thread FadeIn( .5, true, "right" );

	self.menu[4] = addTextHud( self, -165, 100, 1, "left", "middle", "right", 1.4, 103 );
	self.menu[4] Settext( self GetMenuStuct( submenu ) );
    self.menu[4] thread FadeIn( .5, true, "right" );
	self.menu[4].glowColor = ( 0.4, 0.4, 0.4 );
	self.menu[4].glowAlpha = 1;

	self.menu[5] = addTextHud( self, -170, 400, 1, "left", "middle", "right" ,1.4, 103 );
	self.menu[5] SetText( "^7Select: ^3[Right or Left Mouse]^7\nUse: ^3[[{+activate}]]^7\nLeave: ^3[[{+melee}]]" );
    self.menu[5] thread FadeIn( .5, true, "right" );

	self.menu[6] = addTextHud( self, -170, 380, 1, "left", "middle", "right", 1.4, 103 );
	self.menu[6] SetText( self.name + " : " + self.pers[ "role" ] );
	self.menu[6] thread FadeIn( .5, true, "right" );


    self.menubg = addTextHud( self, 0, 0, .5, "left", "top", undefined , 0, 101 );
	self.menubg.horzAlign = "fullscreen";
	self.menubg.vertAlign = "fullscreen";
	self.menubg setShader( "black", 640, 480 );
	self.menubg thread FadeIn( .2 );

    wait .5;
	self freezeControls( true );

    while( self FragButtonPressed() || self UseButtonPressed() ) wait .05;

    oldads = self adsbuttonpressed();

    for( selected = 0; !self meleebuttonpressed(); wait .05 )
    {
        if( self Attackbuttonpressed() )
        {
			if( selected == level.menuoption[ "name" ][ submenu ].size - 1 )
                selected = 0;
			else
                selected++;
		} else if( self adsbuttonpressed() != oldads )
        {
			if(selected == 0)
                selected = level.menuoption[ "name" ][ submenu ].size - 1;
			else
                selected--;
		}

        if( self adsbuttonpressed() != oldads || self Attackbuttonpressed() )
        {
			self playLocalSound( "mouse_over" );
			if( submenu == "main" ) {
				self.menu[2] moveOverTime( .05 );
				self.menu[2].y = 89 + ( 16.8 * selected );
				self.menu[3] moveOverTime( .05 );
				self.menu[3].y = 93 + ( 16.8 * selected );
			}
			else
            {
				self.menu[8] moveOverTime( .05 );
				self.menu[8].y = 10 + self.menu[7].y + ( 16.8 * selected );
			}
		}

        if( self Attackbuttonpressed() && !self useButtonPressed() ) wait .15;

        if( self useButtonPressed() )
        {
            hasPermission = self novo\_player::hasPermission( level.menuoption[ "permission" ][ submenu ][ selected ] );

            if( level.menuoption[ "permission" ][ submenu ][ selected ] != "none" && !hasPermission )
            {
				self iPrintlnBold( self novo\_common::translate( "NO_PERMISSION" ) );
				while(self UseButtonPressed()) wait .05;
			}
            else if( !isString( level.menuoption[ "script" ][ submenu ][ selected ]))
            {
                selectedMenuItem = level.menuoption[ "script" ][ submenu ][ selected ];
                selectedMenuItemArguments = level.menuoption[ "arguments" ][ submenu ][ selected ];

                if( isDefined( selectedMenuItemArguments ) )
                    self thread [[ selectedMenuItem ]]( selectedMenuItemArguments );
                else
                    self thread [[ selectedMenuItem ]]();

                if( level.menuoption[ "end" ][ submenu ][ selected ])
                    self thread endMenu();
                else
                    while(self useButtonPressed()) wait .05;
            }
            else
            {
                abstand = ( 16.8 * selected );
                submenu = level.menuoption[ "script" ][ submenu ][ selected ];

                self.menu[7] = addTextHud( self, -430, abstand + 50, .5, "left", "top", "right", 0, 101 );
                self.menu[7] SetShader( "black", 200, 300 );
                self.menu[7] thread FadeIn( .5, true, "left" );

                self.menu[8] = addTextHud( self, -430, abstand + 60, .5, "left", "top", "right", 0, 102 );
                self.menu[8] SetShader( "line_vertical", 200, 22 );
                self.menu[8] thread FadeIn( .5, true, "left" );

                self.menu[9] = addTextHud( self, -219, 93 + (16.8 * selected), 1, "left", "top", "right", 0, 104 );
                self.menu[9] SetShader( "hud_arrow_left", 14, 14 );
                self.menu[9] thread FadeIn( .5, true, "left" );

                self.menu[10] = addTextHud( self, -420, abstand + 71, 1, "left", "middle", "right", 1.4, 103 );
                self.menu[10] SetText( self GetMenuStuct( submenu ) );
                self.menu[10] thread FadeIn( .5, true, "left" );
                self.menu[10].glowColor = ( 0.4, 0.4, 0.4 );
                self.menu[10].glowAlpha = 1;

                selected = 0;
                wait .2;
            }
        }
        oldads = self adsbuttonpressed();
    }

    self thread endMenu();
}




// Menu Actions

ClassEditor() {
	self openMenu( game[ "menu_eog_main" ] );
}

ToggleLaser()
{
	self cleanScreen();

    if( !self.pers[ "forceLaser" ] )
    {
        self IPrintLnBold( "Laser reflex On" );
        self.pers[ "forceLaser" ] = 1;
    }
    else
    {
        self IPrintLnBold( "Laser reflex Off" );
        self.pers[ "forceLaser" ] = 0;
    }

	self novo\_common::setCvar( "laser",  self.pers[ "forceLaser" ] );
	self setClientDvar( "cg_laserForceOn", self.pers[ "forceLaser" ] );
}

addBot()
{
	if ( isDefined( level.scr_allow_testclients ) && level.scr_allow_testclients == 1 )
		SetDvar( "scr_testclients", 2 );
	else
		self IPrintLnBold( "Enable Test Clients in OpenWarfare Config" );
}

removeBots() {
	removeAllTestClients();
}