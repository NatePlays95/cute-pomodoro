class_name TimerResource
extends Resource

## Timer resource
## meant to be used with a global Timer loaded from game files,
## but can be instantiated on a case-by-case basis.

## if negative mode is on, this triggers when ticks reach zero.
signal finished

## How many in_game frames have been measured. More precise than 
## Is correctly updated by calling update inside _physics_process.
var ticks : int = 0

## How much time has been measured. For precision use [code]ticks[/code] instead.
## Is correctly updated by calling update inside normal _process.
var seconds : float = 0.0

## If set to true, this timer counts down.
var negative_mode := false


static func ticks_from_seconds(seconds_in:float) -> int:
	return floor(seconds_in * Engine.physics_ticks_per_second)

static func seconds_from_ticks(ticks_in:int) -> float:
	return float(ticks_in) / float(Engine.physics_ticks_per_second)

static func string_from_ticks(ticks_in:int, no_milliseconds:=false) -> String:
	return string_from_seconds(seconds_from_ticks(ticks_in), no_milliseconds)

static func string_from_seconds(seconds_in:float, no_milliseconds:=false) -> String:
	
	var int_seconds : int = int(seconds_in)
	var int_minutes : int = int(int_seconds / 60)
	var int_millis : int = int((seconds_in - int_seconds)*1000)
	int_seconds = int_seconds % 60
	
	var time_string = "%02d:%02d" % [int_minutes, int_seconds]
	if not no_milliseconds:
		time_string += ".%03d" % int_millis
	return time_string



func reset() -> void:
	ticks = 0
	seconds = 0.0


func set_time_from_ticks(new_ticks:int) -> void:
	ticks = new_ticks
	seconds = seconds_from_ticks(new_ticks)

func set_time_from_seconds(new_seconds:float) -> void:
	seconds = new_seconds
	ticks = ticks_from_seconds(new_seconds)


## Call inside a level's process or physics process functions.
func update(delta:float) -> void:
	if negative_mode:
		if ticks > 0:
			ticks -= 1
			seconds -= delta
			if ticks <= 0:
				finished.emit()
		else:
			ticks = 0
			seconds = 0.0
		
	else:
		ticks += 1
		seconds += delta


## Useful shorthand for records.
func get_frames_in_seconds() -> float:
	return float(ticks) / float(Engine.physics_ticks_per_second)

func timer_as_string(no_milliseconds:=false) -> String:
	return string_from_ticks(ticks, no_milliseconds)
