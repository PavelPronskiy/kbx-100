#!/bin/bash

#  Growbox console controller.
#  This version supports firmware Web interface only LW3.0
#  Version 0.3b
#
#  Copyright (C) pp 2014.03.06.
#  Permission is granted to copy, distribute and/or modify this document
#  under the terms of the GNU Free Documentation License, Version 1.3
#  or any later version published by the Free Software Foundation;
#  with no Invariant Sections, no Front-Cover Texts, and no Back-Cover
#  Texts.  A copy of the license is included in the section entitled ``GNU
#  Free Documentation License''.

# RELE TABLE 1-4 00001111


SUN_RELE="1"
AIR_RELE="2"

AIR_INDOOR_LEFT_COOLER="8"
AIR_INDOOR_RIGHT_COOLER="9"
AIR_INDOOR_BLOW_COOLERS=""

# HOST
HOST_TO_KBX100="192.168.3.101"


# get settings
eval `curl -4s http://${HOST_TO_KBX100}/status.xml | \
egrep -v 'response' | \
sed -e 's|/|__|g;s|>| |g;s|<| |g;s|__.*||g;s|^.||g;/[^ ]/{h}' \
-e g -e 's/\([^ ]*\)/\1=/;s/ //'`

__check_rele_status() {

	# $1 -- variable table
	# $2 -- variable numeric point (RELE №)
	
	case "$1" in
		rele_table)
			echo ${rele_table0:$((${2}-1)):1}
		;;
		out_table)
			echo ${out_table0:$((${2}-1)):1}
		;;
		in_table)
			echo ${in_table0:$((${2}-1)):1}
		;;
		*) return 1 ;;
	esac
}

__rele_set() {
	
	case "$1" in
		rele)
			output=$(curl -4s http://${HOST_TO_KBX100}/server.cgi?data=REL,${2} 2>&1)
			echo "${output}"
			return 0
		;;
		in)
			output=$(curl -4s http://${HOST_TO_KBX100}/server.cgi?data=IN,${2} 2>&1)
			echo "${output}"
			return 0
		;;
		out)
			output=$(curl -4s http://${HOST_TO_KBX100}/server.cgi?data=OUT,${2} 2>&1)
			echo "${output}"
			return 0
		;;
		pwm)
			output=$(curl -4s http://${HOST_TO_KBX100}/server.cgi?data=PWM,${2} 2>&1)
			echo "${output}"
			return 0
		;;
	esac
	
}

__rele_control() {
	
	# $1 -- rele,in,out,pwm
	# $2 -- rele number
	# $3 -- start,stop
	
	case "$1" in
		rele)
			case "$3" in
				start)
					if [[ "`__check_rele_status rele_table $2`" == "0" ]]
					then
						__rele_set $1 $2
					fi
				;;
				stop)
					if [[ "`__check_rele_status rele_table $2`" == "1" ]]
					then
						__rele_set $1 $2
					fi
				;;
			esac
		;;
		in)
			case "$3" in
				start)
					if [[ "`__check_rele_status in_table $2`" == "0" ]]
					then
						__rele_set $1 $2
					fi
				;;
				stop)
					if [[ "`__check_rele_status in_table $2`" == "1" ]]
					then
						__rele_set $1 $2
					fi
				;;
			esac
		;;
		out)
			case "$3" in
				start)
					if [[ "`__check_rele_status out_table $2`" == "0" ]]
					then
						__rele_set $1 $2
					fi
				;;
				stop)
					if [[ "`__check_rele_status out_table $2`" == "1" ]]
					then
						__rele_set $1 $2
					fi
				;;
			esac
		;;
		pwm)
			__rele_set $1 $2
		;;
		degree) echo "${temper0/\.*/}" ;;
		*)
			echo "`basename $0` rele [1-4] start|stop"
			echo "`basename $0` in [1-4] start|stop"
			echo "`basename $0` out [1-12] start|stop"
			echo "`basename $0` pwm [0-100]"
		;;
	esac
}

__rele_control "$1" "$2" "$3" "$4"

