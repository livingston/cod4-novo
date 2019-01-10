#include novo\_common;
#include maps\mp\_helicopter;

setup()
{
    PreCacheModel( "com_plasticcase_beige_big" );
    PreCacheShader( "hud_suitcase_bomb" );
    level.fx[1] = loadFx( "fire/tank_fire_engine" );
    level.chopper_fx[ "explode" ][ "medium" ] = loadFx( "explosions/aerial_explosion" );

    if( !isDefined( level.carePackageLocations ))
        level.carePackageLocations = [];

    level.carePackageLocations[ "mp_bloc"        ] = 2400;
    level.carePackageLocations[ "mp_crossfire"   ] = 2200;
    level.carePackageLocations[ "mp_citystreets" ] = 2000;
    level.carePackageLocations[ "mp_creek"       ] = 2100;
    level.carePackageLocations[ "mp_bog"         ] = 2200;
    level.carePackageLocations[ "mp_overgrown"   ] = 2500;
    level.carePackageLocations[ "mp_nuketown"    ] = 1700;
    level.carePackageLocations[ "mp_strike"      ] = 2100;
    level.carePackageLocations[ "mp_crash"       ] = 2100;
}

canCallPackage()
{
    if( isDefined( level.carpackageInUse ) )
        return false;

    currentMap = getDvar( "mapname" );
    location = 2000;

    if( isDefined( level.carePackageLocations[ currentMap ] ) )
        location = level.carePackageLocations[ currentMap ];

    heliorigin = (self.origin[0], self.origin[1], location);
    playerorigin = self.origin;
    surface = BulletTrace(playerorigin + (0,0,50), playerorigin - (0,0,50), false, self)[ "surfacetype" ];

    for( i = 0; i < 360; i += 36 )
    {
        add = (( 50 * cos( i ) ), ( 50 * sin( i ) ), 30);
        if( !BulletTracePassed( heliorigin + add, playerorigin + add, true, self ) )
        {
            self iPrintlnBold( self translate( "PACKAGE_POSITION" ) );
            return false;
        }
    }

    level.carpackageInUse = true;

    self thread CarePackage( heliorigin, playerorigin, surface );

    return true;
}

CarePackage( heliorigin, playerorigin, surface )
{
    self endon( "disconnect" );

    vector = anglesToForward( (0, randomint(360) , 0) );
    start = heliorigin + ( vector[0] * 10600, vector[1] * 10600, 0 );

    model = "vehicle_mi24p_hind_desert";
    sound = "mp_hind_helicopter";

    if ( self.pers["team"] == "allies" )
    {
        model = "vehicle_cobra_helicopter_fly";
        sound = "mp_cobra_helicopter";
    }

    chopper = spawnHelicopter( self, start, (0,0,-10), "cobra_mp", model );
    chopper playLoopSound( sound );
    chopper.currentstate = "ok";
    chopper.laststate = "ok";
    chopper setdamagestage( 3 );
    chopper setspeed( 1000, 25, 10 );
    chopper setvehgoalpos( heliorigin, 1 );

    box = spawn( "script_model", heliorigin );
    box setmodel( "com_plasticcase_beige_big" );
    box LinkTo( chopper, "tag_ground" , (0,0,-10) , (0,0,0) );

    while(distance( chopper.origin, heliorigin ) >= 50 )
        wait .05;

    box Unlink();
    box.angles = (0, box.angles[1], 0);
    box MoveTo( playerorigin, distance( playerorigin, box.origin ) / 900 );

    chopper setvehgoalpos( start, 1 );
    chopper thread deleteChopper( start );

    box waittill ( "movedone" );

    if( isDefined( surface ) )
        box thread Bounce( surface );

    players = getAllPlayers();

    for( k = 0; k < 10; k++ )
    {
        for( i = 0; i < players.size; i++ )
        {
            if( distance( players[i].origin, box.origin ) < 65 )
                players[i] suicide();
        }

        wait .05;
    }

    solid = spawn( "trigger_radius", box.origin, 0, 64, 50 );
    solid setContents(1);
    solid.targetname = "script_collision";

    level thread endOnDisconnect( self, box, solid, chopper );
    box thread TriggerMsg();
    box thread Trigger( self );

    content = newHudElem();
    content.x = box.origin[0];
    content.y = box.origin[1];
    content.z = box.origin[2]+55;
    content.alpha = .75;
    content.archived = true;
    content setShader( "hud_suitcase_bomb", 25, 25 );
    content setWaypoint( true, "hud_suitcase_bomb" );

    box waittill( "death" );

    solid notify( "deleted" );
    solid delete();

    content destroy();
}

endOnDisconnect( player, box, solid, chopper )
{
    solid endon("deleted");
    player waittill("disconnect");

    if( isDefined( box ) )
        box delete();

    if( isDefined( solid ) )
        solid delete();

    if( isDefined( chopper ) )
        chopper delete();

    level.carpackageInUse = undefined;
}

deleteChopper(start)
{
    self endon( "death" );

    while( distance( self.origin, start ) >= 200 )
        wait .05;

    level.carpackageInUse = undefined;
    self delete();
}

// Viking
Bounce( type)
{
    self endon("death");

    BounceTargets[0][0] = 32;
    BounceTargets[0][1] = 0.4;
    BounceTargets[0][2] = 0;
    BounceTargets[0][3] = 0.4;

    BounceTargets[1][0] = -32;
    BounceTargets[1][1] = 0.425;
    BounceTargets[1][2] = 0.425;
    BounceTargets[1][3] = 0;

    BounceTargets[2][0] = 0.16;
    BounceTargets[2][1] = 0.25;
    BounceTargets[2][2] = 0;
    BounceTargets[2][3] = 0.25;

    BounceTargets[3][0] = -0.16;
    BounceTargets[3][1] = 0.275;
    BounceTargets[3][2] = 0.275;
    BounceTargets[3][3] = 0;

    for( i = 0; i < BounceTargets.size; i++ )
    {
        self PlaySound( "grenade_bounce_" + type );
        self MoveZ( BounceTargets[i][0], BounceTargets[i][1], BounceTargets[i][2], BounceTargets[i][3] );
        wait BounceTargets[i][1];
    }
}

Explode()
{
    if( !isDefined( self ) )
        return;

    TriggerEarthquake( 0.4, 1, self.origin, 1000 );
    playfx( level.chopper_fx["explode"]["medium"], self.origin );

    level thread SoundOnOrigin( "detpack_explo_main", self.origin );

    if( isPlayer( self ) && self isRealyAlive() )
        self Suicide();
    else
        self delete();
}

Trigger( owner )
{
    owner endon( "disconnect" );

    num = level.carepackage.size;

    triggerrange = 80;

    while( isDefined( self ) )
    {
        wait .05;
        players = getAllPlayers();

        for( i = 0; i < players.size; i++ )
        {
            player = players[i];

            if( player isRealyAlive() && distance( player.origin, self.origin ) < triggerrange )
            {
                if( player UseButtonPressed() )
                {
                    level.carepackage[num] = true;

                    timer = 2.5;

                    if( player.pers["team"] != owner.pers["team"] )
                        timer = 6;
                    else if( player != owner )
                        timer = 4.5;

                    player DisableWeapons();
                    player FreezeControls( true );
                    player.opening = player maps\mp\gametypes\_hud_util::createBar((1,1,1), 128, 8);

                    player.opening maps\mp\gametypes\_hud_util::setPoint("CENTER", 0, 0, 0);
                    player.opening maps\mp\gametypes\_hud_util::updateBar(0, 1/timer );

                    for( i = 0; i < ( timer * 20 + 1 ); i++ )
                    {
                        if( !isDefined( player ) )
                        {
                            level.carepackage[num] = false;
                            i = 999999;
                        }

                        if( !player UseButtonPressed() || !player isRealyAlive() || distance( player.origin, self.origin ) > ( triggerrange + 10 ) )
                        {
                            if( isDefined( player.opening ) )
                                player.opening maps\mp\gametypes\_hud_util::destroyElem();

                            player EnableWeapons();
                            player freezeControls( false );
                            level.carepackage[num] = false;
                            i = 999999;
                        }

                        wait .05;

                        if( i == ( timer * 20 ) )
                        {
                            if( isDefined( player.opening ) )
                                player.opening maps\mp\gametypes\_hud_util::destroyElem();

                            player EnableWeapons();
                            player freezeControls( false );

                            if( player.pers["team"] != owner.pers["team"] && randomint(1) == 0 )
                                player thread Explode();
                            else
                                player thread Rewards();

                            self delete();

                            return;
                        }
                    }
                }
            }
        }
    }
}

TriggerMsg()
{
    if( !isDefined( level.carepackage ))
    {
        level.carepackage = [];
    }

    num = level.carepackage.size;

    wait .05;
    level.carepackage[num] = false;

    triggerrange = 80;

    while( isDefined( self ) )
    {
        players = getAllPlayers();
        for( i = 0; i < players.size; i++ )
        {
            player = players[i];
            if( player isRealyAlive() && distance( player.origin, self.origin ) < triggerrange && !level.carepackage[num] )
            {
                player.carepackagemsg = true;
                player maps\mp\_utility::setLowerMessage( player translate( "PACKAGE_PICKUP" ) );
            }
            else if( isDefined( player.carepackagemsg ) && player.carepackagemsg && ( level.carepackage[num] || distance( player.origin, self.origin ) > triggerrange ) )
            {
                player.carepackagemsg = false;
                player maps\mp\_utility::clearLowerMessage( .3 );
            }
        }

        wait .05;
    }

    players = getAllPlayers();
    for( i = 0; i < players.size; i++ )
        if( isDefined( players[i].carepackagemsg ) && players[i].carepackagemsg )
            players[i] maps\mp\_utility::clearLowerMessage( .3 );
}

Rewards() {
    self endon( "disconnect" );
    random = randomint(3);

    switch(random)
    {
        case 0:
            self NotifyMsg( level.hardpointHints["helicopter_mp"] );
            self maps\mp\gametypes\_hardpoints::giveHardpointItem( "helicopter_mp" );
        break;
        case 1:
            self NotifyMsg( level.hardpointHints["airstrike_mp"] );
            self maps\mp\gametypes\_hardpoints::giveHardpointItem( "airstrike_mp" );
        break;
        case 2:
            self NotifyMsg( level.hardpointHints["radar_mp"] );
            self maps\mp\gametypes\_hardpoints::giveHardpointItem( "radar_mp" );
        break;
        default: return;
    }
}