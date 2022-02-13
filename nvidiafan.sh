#!/bin/bash
MSGS=/dev/null

echo "start fan profiler" >$MSGS
GPUCTRL=$(/usr/bin/nvidia-settings -q "GPUFanControlState" | head -n 2 | tail -n 1 | awk '{ print substr( $0, length($0)-1, 1) }')

if [ $? -eq 0 ]; then
	if [ "$GPUCTRL" -eq "0" ]; then
		echo "Enabling control state" >$MSGS
		/usr/bin/nvidia-settings -V none -a "GPUFanControlState=1" >/dev/null 2>&1
	fi

	GPUTMP=$(/usr/bin/nvidia-settings -q GPUCoreTemp | head -n 2 | tail -n 1 | awk '{ print substr( $0, length($0)-2, 2) }')
	GPUFANSPEED=$(/usr/bin/nvidia-settings -q "[fan:0]/GPUCurrentFanSpeed" | head -n 2 | tail -n 1 | grep -Po ': \K[0-9]*' )

	if [ "$GPUTMP" -gt "50" ]; then
		SETSPEED=100
	elif [ "$GPUTMP" -gt "45" ]; then
		SETSPEED=80
	elif [ "$GPUTMP" -gt "40" ]; then
		SETSPEED=60
	elif [ "$GPUTMP" -gt "35" ]; then
		SETSPEED=50
	elif [ "$GPUTMP" -gt "30" ]; then
		SETSPEED=40
	else
		SETSPEED=30
	fi

	if [ "$(( $GPUFANSPEED+1 )) " -lt "$SETSPEED" ] || [ "$(( $GPUFANSPEED-1 ))" -gt "$SETSPEED" ]; then
		echo "changing fan speed" >$MSGS
		echo "Fan 0 speed $SETSPEED" >$MSGS
		/usr/bin/nvidia-settings -V none -a "[fan:0]/GPUTargetFanSpeed=$SETSPEED" >/dev/null 2>&1
		echo "Fan 1 speed $SETSPEED" >$MSGS
		/usr/bin/nvidia-settings -V none -a "[fan:1]/GPUTargetFanSpeed=$SETSPEED" >/dev/null 2>&1
		echo "speed set" >$MSGS
	fi
fi

echo "exit fan profiler" >$MSGS
