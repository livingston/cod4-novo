updateSettings()
{

}

enableHighJump()
{
    IPrintLnBold( "High Jump ^2ON" );
    fallDamageMinHeight = level.dvar[ "scr_novo_falldamage_minheight" ];
    fallDamageMaxHeight = level.dvar[ "scr_novo_falldamage_maxheight" ];
    jumpHeight = level.dvar[ "scr_novo_jump_height" ];

    SetDvar( "bg_falldamageminheight", fallDamageMinHeight );
    SetDvar( "bg_falldamagemaxheight", fallDamageMaxHeight );
    SetDvar( "jump_height", jumpHeight );
    SetDvar( "jump_slowdownEnable", 0 );

    SetDvar( "scr_novo_highjump", 1 );
}

disableHighJump()
{
    IPrintLnBold( "High Jump ^1OFF" );

    SetDvar( "bg_falldamageminheight", 128 );
    SetDvar( "bg_falldamagemaxheight", 300 );
    SetDvar( "jump_height", 39 );
    SetDvar( "jump_slowdownEnable", 1 );

    SetDvar( "scr_novo_highjump", 0 );
}
