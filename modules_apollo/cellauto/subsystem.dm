var/global/datum/subsystem/cell_auto/cell_auto_manager = new()
var/global/datum/cell_auto_handler/v_wave_handler = new(2)
var/global/datum/cell_auto_handler/sm_crystal_handler = new(600)
var/global/datum/cell_auto_handler/explosion_handler = new(1)

/datum/subsystem/cell_auto
	name = "Cell_Auto"
	wait = 1
	priority = 100
	name = "Cellular Automata"			//name of the subsystem
	var/list/datum/cell_auto_handler/handlers = null

//used to initialize the subsystem BEFORE the map has loaded
/datum/subsystem/cell_auto/New()
	NEW_SS_GLOBAL(cell_auto_manager)
	handlers = list( v_wave_handler, sm_crystal_handler)//,explosion_handler)

/datum/subsystem/cell_auto/stat_entry(msg)
	..("C:[handlers.len]")

//previously, this would have been named 'process()' but that name is used everywhere for different things!
//fire() seems more suitable. This is the procedure that gets called every 'wait' deciseconds.
//fire(), and the procs it calls, SHOULD NOT HAVE ANY SLEEP OPERATIONS in them!
//YE BE WARNED!
/datum/subsystem/cell_auto/fire()
	world << "FIRING Cell Auto"
	if( !handlers )
		return
	var/c = 1

	for( var/datum/cell_auto_handler/handler in handlers )
		if(!(c++ % 2))			//Stops explosions and stuff taking more than 70% CPU
			if (world.tick_usage > 70)		sleep(world.tick_lag)

		if( handler.shouldProcess() )
			handler.process()