#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
    level.callbackPermission = ::hasPermission;
    thread novo\_events::addConnectEvent( ::onConnect );
}

onConnect()
{
    self endon( "disconnect" );

    self setClientDvar("cg_drawCrosshair", 1);

    dvar = "firstTime_" + self getEntityNumber();
    if( getDvar( dvar ) != self getGuid() )
    {
        self.pers[ "firstTime" ] = true;
        setDvar( dvar, self getGuid() );
    }

    self waittill( "spawned_player" );

    if( !isDefined( self.pers[ "firstSpawnTime" ] ) )
        self.pers[ "firstSpawnTime" ] = getTime();

    if( !isDefined( game[ "firstPlayerSpawnTime" ] ) )
    {
        game[ "firstPlayerSpawnTime" ] = true;
        game[ "firstSpawnTime" ] = self.pers[ "firstSpawnTime" ];
    }

    if( isDefined( self.pers[ "firstTime" ] ) )
        self thread welcome();

    waittillframeend;

    if( level.dvar[ "gun_position" ] ) {
        self setClientDvars( "cg_gun_move_u", "1.5",
                             "cg_gun_move_f", "-1",
                             "cg_gun_ofs_u", "1",
                             "cg_gun_ofs_r", "-1",
                             "cg_gun_ofs_f", "-2" );
    }

    waittillframeend;
}

userSettings()
{
    if( isDefined( self.pers[ "laser" ] ) )
        self setClientDvar( "cg_laserForceOn", self.pers[ "laser" ] );

    waittillframeend;
    if( isDefined( self.pers[ "bright" ] ) )
        self setClientDvar( "r_fullbright", self.pers[ "bright" ] );

    waittillframeend;
    if( isDefined( self.pers[ "fov" ] ) )
    {
        switch( self.pers[ "fov" ] )
        {
            case 0:
                self setClientDvar( "cg_fovscale", 1.0 );
                self setClientDvar( "cg_fov", 80 );
                break;
            case 1:
                self setClientDvar( "cg_fovscale", 1.125 );
                self setClientDvar( "cg_fov", 80 );
                break;
            case 2:
            default:
                self setClientDvar( "cg_fovscale", 1.25 );
                self setClientDvar( "cg_fov", 80 );
                break;
        }
    }
}

hasPermission( permission )
{
    if( !isDefined( self.pers[ "role" ] ) )
    {
        waittillframeend;

        if( !isDefined( self.pers[ "role" ] ) )
            return false;
    }

    playerPermissions = novo\_permissions::getPermissions( self.pers[ "role" ] );
    if( !isDefined( playerPermissions ) )
        return false;

    if( playerPermissions == "*" )
        return true;

    return IsSubStr( playerPermissions, permission );
}

welcome()
{
    // Visit Count
    playerVisitCount = self novo\_common::getCvarInt( "visit_count" );
    playerVisitCount = playerVisitCount + 1;

    self novo\_common::setCvar( "visit_count", playerVisitCount );

    if( playerVisitCount == 1 )
        visitInfo = "First Visit!";
    else
        visitInfo = playerVisitCount + " ^2visits";


    // Last Visit
    playerLastVisit = self novo\_common::getCvar( "last_visit" );
    t = getRealTime();

    self novo\_common::setCvar( "last_visit", t );
    self novo\_common::setCvar( "name", self.name );


    // Geolocation
    country = self getGeoLocation( 2 );
    welcomeMessage = self.name;


    if( !isSubStr( country, "N/" ) || !isDefined( country ) )
        welcomeMessage = self.name + " ^7from ^1" + country;


    exec( "say Welcome^3 "+ welcomeMessage +"^7! ^4( ^7"+ visitInfo +" ^4)");


    if( playerLastVisit != "" )
    {
        formattedLastVisit = TimeToString( int( playerLastVisit ), 0, "%b %d %G ^1%r");
        exec( "say Last visit:^2 "+ formattedLastVisit );
    }
}
