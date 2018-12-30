init()
{
    thread novo\_events::addConnectEvent( ::setPlayerRoles );
}

// Roles :: Member, Admin, SuperAdmin
// Permissions :: * (all), tweaks, owner, member, admin, only, debug
getPermissions( role )
{
    permissions = [];
    permissions[ "superadmin" ] = "*";
    permissions[ "admin" ]      = "tweaks,member,admin,only";
    permissions[ "member" ]     = "tweaks,member";
    permissions[ "default" ]    = "";

    return permissions[ role ];
}

setPlayerRoles()
{
    self endon( "disconnect" );

    access = "default";

    if( isDefined( GetDvar( "scr_novo_access" ) ) )
    {
        novaPlayersWithAccess = StrTok( GetDvar( "scr_novo_access" ), ";" );

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