#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
    thread novo\events::addConnectEvent( ::onConnect );
}

onConnect()
{
    self endon( "disconnect" );

	self setClientDvar("cg_laserForceOn", 1);
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

welcome()
{
	country = self getGeoLocation( 2 );
	if( !isSubStr( country, "N/" ) || !isDefined( country ) )
	{
        exec( "say Welcome^5 " + self.name + " ^7from ^5" + country );
	}
	else
	{
        exec( "say Welcome^5 " + self.name );
	}
}