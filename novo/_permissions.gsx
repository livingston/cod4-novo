init()
{
    thread novo\_events::addConnectEvent( ::setPlayerRoles );
}

getPermissions( role )
{
    permissions = [];
    permissions[ "superadmin" ] = "";
    permissions[ "admin" ]      = "";
    permissions[ "member" ]     = "";
    permissions[ "default" ]    = "";

    return permissions[ role ];
}

setPlayerRoles()
{
    self endon( "disconnect" );

    access = "default";

    if( isDefined( GetDvar( "nova_access" ) ) )
    {
        novaPlayersWithAccess = StrTok( GetDvar( "nova_access" ), ";" );

        for( i = 0; i < novaPlayersWithAccess.size; i++ )
        {
            novaPlayerWithAccess = StrTok( novaPlayersWithAccess[ i ], "=" );

            guid = novaPlayerWithAccess[ 0 ];
            guid = GetSubStr( guid, guid.size - 8, guid.size );

            role = getPermissions( novaPlayerWithAccess[ 1 ] );

            if( GetSubStr( self getGuid(), 24, 32 ) == guid && isDefined( role ) )
            {
                access = novaPlayerWithAccess[ 1 ];
                break;
            }
        }
    }

    self.pers[ "role" ] = access;
    self novo\_common::setCvar( "role", access );
}

hasPermission( permission )
{
    if( !isDefined( self.pers[ "status" ] ) )
    {
		waittillframeend;

		if( !isDefined( self.pers[ "status" ] ) )
			return false;
	}

    return true;
}

// // Roles
// Member
// Admin
// SuperAdmin

// // access
// *
// tweaks
// owner
// member
// admin
// only