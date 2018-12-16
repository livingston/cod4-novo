GloballogicInit()
{
    thread novo\dvars::init();
	thread novo\events::init();
}

startGameType()
{
    thread setupServerDvars();
}

setupServerDvars()
{
    exec( "sets _mod CoD4:Novo" );
	exec( "sets _modVer 1.0.0-alpha" );
}