GloballogicInit()
{
    thread novo\dvars::init();
	thread novo\events::init();
}

startGameType()
{
    thread novo\player::init();

    thread setupServerDvars();
}

setupServerDvars()
{
    exec( "seta sv_consayname ^3C^14^3N: ^7" );
    exec( "seta sv_contellname ^3C^14^3N^7->^5PM: ^7" );

    exec( "sets _mod CoD4:Novo" );
	exec( "sets _modVer 1.0.0-alpha" );
}