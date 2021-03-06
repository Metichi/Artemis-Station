

/datum/computer_file/program/power_monitor
	filename = "powermonitor"
	filedesc = "Power Monitoring"
	program_icon_state = "power_monitor"
	extended_desc = "This program connects to sensors around the station to provide information about electrical systems"
	ui_header = "power_norm.gif"
	transfer_access = access_engine
	usage_flags = PROGRAM_CONSOLE
	requires_ntnet = 0
	network_destination = "power monitoring system"
	size = 9
	var/has_alert = 0
	var/obj/structure/cable/attached
	var/list/history = list()
	var/record_size = 60
	var/record_interval = 50
	var/next_record = 0




/datum/computer_file/program/power_monitor/run_program(mob/living/user)
	. = ..(user)
	search()
	history["supply"] = list()
	history["demand"] = list()


/datum/computer_file/program/power_monitor/process_tick()
	if(!attached)
		search()
	else
		record()

/datum/computer_file/program/power_monitor/proc/search()
	var/turf/T = get_turf(computer)
	attached = locate() in T

/datum/computer_file/program/power_monitor/proc/record()
	if(world.time >= next_record)
		next_record = world.time + record_interval

		var/list/supply = history["supply"]
		supply += attached.powernet.viewavail
		if(supply.len > record_size)
			supply.Cut(1, 2)

		var/list/demand = history["demand"]
		demand += attached.powernet.viewload
		if(demand.len > record_size)
			demand.Cut(1, 2)

/datum/computer_file/program/power_monitor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
											datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)

		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)


		ui = new(user, src, ui_key, "power_monitor_prog", "Power Monitoring", 1200, 1000, master_ui, state)
		ui.open()

/datum/computer_file/program/power_monitor/ui_data()
	var/list/data = get_header_data()
	data["stored"] = record_size
	data["interval"] = record_interval / 10
	data["attached"] = attached ? TRUE : FALSE
	if(attached)
		data["supply"] = attached.powernet.viewavail
		data["demand"] = attached.powernet.viewload
	data["history"] = history

	data["areas"] = list()
	if(attached)
		for(var/obj/machinery/power/terminal/term in attached.powernet.nodes)
			var/obj/machinery/power/apc/A = term.master
			if(istype(A))
				data["areas"] += list(list(
					"name" = A.area.name,
					"charge" = A.cell.percent(),
					"load" = A.lastused_total,
					"charging" = A.charging,
					"eqp" = A.equipment,
					"lgt" = A.lighting,
					"env" = A.environ
				))

	return data