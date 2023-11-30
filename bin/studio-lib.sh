#!/usr/bin/env bash
# file: studio-lib.sh
# source: https://github.com/periplume/studio.git
# author: jason@bloom.us
# desc: studio shell library functions

# SCRIPT AND SHELL SETTINGS
set -o errexit
set -o nounset
set -o pipefail

# OUTPUT

# some color
red=$(tput setab 1; tput setaf 7)
boldred=$(tput setab 1 ; tput setaf 7)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
yellow=$(tput setaf 3)
label=$(tput setab 7; tput setaf 0)
prompt=$(tput setab 5; tput setaf 7)
reset=$(tput sgr0)
# TODO functionalize colorizing

##################################################
# LOGGING AND CONSOLE MESSAGES AND USER INTERFACE
##################################################

# user output: types
# name		description														display
#----------------------------------------------------------------------------
# debug		verbose																cyan
# info		information only											blue text, green bg
# warn		warning (abnormal)										black text, yellow bg
# error		not allowed														white text, red bg
# fatal		error and exiting (out of trap)				black text, red bg, bold text?
# ask			ask user for input										white text, cyan bg
#
#	always expect fresh new line
# exception...after ask...in which case, take care of that immediately
# suppress all if _studioSILENT=true
#
# call as
# _warn "message"
# _info "message"

# _fLOG creates logging functions based on runtime switches (command options)
# and static features: (defaults and global variables)
#
# the three main determinants:
# _studioSILENT= true | false
# _studioLOG= true | false
# _studioDEBUG= true | false
#
# subordinate dependencies:
# _studioLOG= true | false
# _studioLOGFILE= "path to file"
# $(tput colors)

_fLOG() {
	# collapsing function...sets up according to the static determinants
	# creates all log functions dynamically (based on defaults plus positional
	# parameters)
	# _debug
	# _info
	# _warn
	# _error
	# _ask
	# log function usage as simple as:
	# _info "the message contents" 
	local _log=0
	local _console=0
	local _color=0
	[[ "${_studioSILENT:-}" = "false" ]] && _console=1
	[[ "${_studioLOG:-}" = "true" && "${_studioLOGGING:-}" = "true" ]] && _log=1
	[[ $(tput colors) ]] && _color=1
	#
	# set up colors	
	_cDebug=$(tput setaf 6)
	_cInfo=$(tput setaf 2)
	_cWarn=$(tput setaf 11)
	_cError=$(tput setaf 1)
	_cAsk=$(tput setaf 0; tput setab 11)
	_cReset=$(tput sgr0)
	# create 5 log functions based on static determinants above
	# CONSOLE AND LOG
	if [[ $_console = 1 && $_log = 1 ]]; then
		_debug() {
			[[ "$_studioDEBUG" = "false" ]] && return
			local _timeStamp=$(date +%s.%N)
			printf '%s %s\n' "${_cDebug}DEBUG${_cReset}" "${@}"
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cDebug}DEBUG${_cReset}" "${@}" >>${_studioLOGFILE}
		}
		_info() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cInfo}INFO${_cReset}" "${@}" >>${_studioLOGFILE}
			# hack: below prints _info...multi-line messages are indented
			SAVEIFS=$IFS
			IFS=$'\n'
			_pList=(${1})
			IFS=$SAVEIFS
			if [[ ${#_pList[@]} -gt 1 ]]; then
				printf '%s %s\n' "${_cInfo}INFO${_cReset}" "${_pList[0]} "
				for (( i=1; i<${#_pList[@]}; i++ ))
				do
					printf "\t\t: %s\n" "${_pList[$i]} "
				done
			else
				printf "%s %s\n" "${_cInfo}INFO${_cReset}" "${1} "
			fi
		}
		_warn() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s\n' "${_cWarn}WARN${_cReset}" "${@}"
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cWarn}WARN${_cReset}" "${@}" >>${_studioLOGFILE}
		}
		_error() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s\n' "${_cError}ERROR${_cReset}" "${@}"
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cError}ERROR${_cReset}" "${@}" >>${_studioLOGFILE}
		}
		_ask() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s' "${_cAsk}USER${_cReset}" "${@}"
			#printf '%s %s %s\n' "$_timeStamp" "${self} ${_cAsk}USER${_cReset}" "${@}" >>${_studioLOGFILE}
			# don't log prompts...if something is important, log as debug
		}
	# LOG ONLY
	elif [[ $_console = 0 && $_log = 1 ]]; then
		_debug() {
			[[ "$_studioDEBUG" = "false" ]] && return
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cDebug}DEBUG${_cReset}" "${@}" >>${_studioLOGFILE}
		}
		_info() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cInfo}INFO${_cReset}" "${@}" >>${_studioLOGFILE}
		}
		_warn() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cWarn}WARN${_cReset}" "${@}" >>${_studioLOGFILE}
		}
		_error() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cError}ERROR${_cReset}" "${@}" >>${_studioLOGFILE}
		}
		_ask() {
			:
			#local _timeStamp=$(date +%s.%N)
			#printf '%s %s %s\n' "$_timeStamp" "${self} ${_cAsk}USER${_cReset}" "${@}" >>${_studioLOGFILE}
			# don't log _ask prompts
		}
	# CONSOLE ONLY
	elif [[ $_console = 1 && $_log = 0 ]]; then
		_debug() {
			[[ "$_studioDEBUG" = "false" ]] && return
			printf '%s %s\n' "${_cDebug}DEBUG${_cReset}" "${@}"
		}
		_info() {
			printf '%s %s\n' "${_cInfo}INFO${_cReset}" "${@}"
		}
		_warn() {
			printf '%s %s\n' "${_cWarn}WARN${_cReset}" "${@}"
		}
		_error() {
			printf '%s %s\n' "${_cError}ERROR${_cReset}" "${@}"
		}
		_ask() {
			printf '%s %s' "${_cAsk}USER${_cReset}" "${@}"
		}
	else
		# do nothing
		_debug() { : ; }
		_info() { : ; }
		_warn() { : ; }
		_error() { : ; }
		_ask() { : ; }
	fi
	export -f _debug
	export -f _info
	export -f _warn
	export -f _error
	export -f _ask
}


###########################
# trap and signal catching
###########################

_irishExit() {
	echo #to clear line...this is a bit ugly
	# this function does not behave as desired
  _ask "ctrl-c detected; to resume, press R, to quit, press ENTER"
  while read -s -t 15 -n 1 _ANS; do
		echo
  	if [[ ${_ANS:-n} = 'R' ]]; then
			_info "resuming"
    	return
  	else
   	#_error "user requested exit with ctrl-c"
			_error "goodbye"
			exit 1
		# this seems to fuck up my terminal???
  	fi
	done
}

# semi-reliable way of knowing the term emulator
_termDetect() {
  # return the name of the detected terminal emulator type
  # return 1 and "unknown" if failed
  test -t || { echo "unknown"; return 1; }
  ppid=$(ps --no-headers -p $$ -o args,ppid)
    ppid_name=$(echo $ppid | awk '{print $1}')
    ppid_pid=$(echo $ppid | awk '{print $NF}')
    if [[ $ppid_name == bash ]]
    then
      pppid=${ppid_pid##*,}
      ppid=$(ps --no-headers -p $pppid -o args,ppid)
      ppid_name=$(echo $ppid | awk '{print $1}')
      ppid_pid=$(echo $ppid | awk '{print $NF}')
      finally=$(ps --no-headers -p $ppid_pid -o args)
    fi
    echo $finally
}

_isOnline () {
  # arg 1: mode (simple or full, default=simple)
  mode=${1:-simple}
  if [[ $mode = "simple" ]]
	then
		attempt=0
		testsites=(http://www.google.com http://www.amazon.com http://www.microsoft.com)
		while [ $attempt -lt 3 ]
		do
			testHTTP ${testsites[$attempt]} $mode
			if [ $? = 0 ]
			then
				# can reach google on port 80, we are online
				declare -g STUDIO_MODE_OFFLINE=false
				_debug "${FUNCNAME[0]}: test mode: $mode; result: ONLINE"
				return 0
			else
				# can not reach google, try the next in $testsites list
				# this is broken...will set only based on last test
				attempt=$(( $attempt + 1 ))
			fi
		done
		if [ -z ${STUDIO_MODE_OFFLINE} ]
		then
			declare -g STUDIO_MODE_OFFLINE=true
			_debug "${FUNCNAME[0]}: test mode: $mode; result: OFFLINE"
		fi
  else
		# mode is full
		declare -A testList
	for sTest in testRoute testLink testPing testLocalDNS testRemoteDNS
	do
		eval $sTest
		if [ $? = 0 ]
		then
			testList[$sTest]="pass"
		else
			testList[$sTest]="fail"
		fi
	done
	if testHTTP "http://www.google.com" $mode
	then
		# add another check here as sometimes google will time out
		testList[testHTTP]="pass"
	else
		testList[testHTTP]="fail"
	fi
	fi
	passCount=0
	failCount=0
	warnCount=0
	for k in "${!testList[@]}"
	do
		if [ ${testList[$k]} = "pass" ]
		then
			passCount=$(( $passCount + 1 ))
		elif [ ${testList[$k]} = "fail" ]
		then
			failCount=$(( $failCount + 1 ))
		elif [ ${testList[$k]} = "warn" ]
		then
			warnCount=$(( $warnCount + 1 ))
		fi
	done
	if [ $failCount -eq 0 ]
	then
		declare -g STUDIO_MODE_OFFLINE=false
		_debug "${FUNCNAME[0]}: test mode: $mode; pass=$passCount fail=$failCount: ONLINE"
		return 0
	elif [ $failCount -le $passCount ]
	then
		declare -g STUDIO_MODE_OFFLINE=false
		declare -g STUDIO_ONLINE_WARN=true
		_debug "${FUNCNAME[0]}: test mode: $mode; pass=$passCount fail=$failCount: ONLINE (with WARNINGS)"
		return 0
	else
		declare -g STUDIO_MODE_OFFLINE=true
		_debug "${FUNCNAME[0]}: test mode: $mode; pass=$passCount fail=$failCount: OFFLINE (improve this heuristic)"
		return 1
	fi
}

testRoute () {
  # desc: sub-function to test for internet gateways
  # no args
  # figure out the most likely default route and set STUDIO_NET_ROUTE
  # return 0 for gateways, set globals $STUDIO_NET_ VARs
  # return 1 for none
  local ip_route=$(ip -4 route)
  local default_routes=$(echo "$ip_route" | grep ^default)
  local gateway_count=$(echo "$default_routes" | wc -l)
  if [ -z "$default_routes" ]
  then
    return 1
  elif [ $gateway_count -gt "1" ]
  then
    local trimmed=$(echo "$default_routes" | awk '$9!=""')
    local sorted=$(echo "$trimmed" | sort -g -k1,9)
    local default_route=$(echo "$sorted" | head -1)
  elif [ $gateway_count = "1" ]
  then
    local default_route=$default_routes
  fi
  _debug "${FUNCNAME[0]}: routes detected: [$gateway_count]: $default_route"
  declare -g STUDIO_NET_ROUTE=$default_route
  declare -g STUDIO_NET_ADAPTER=$(echo "$default_route" | awk '{print $5}')
  declare -g STUDIO_NET_ADAPTERMAC=$(ip link show $STUDIO_NET_ADAPTER | grep "link/ether" | awk '{print $2}')
  declare -g STUDIO_NET_IP=$(ip -4 addr show $STUDIO_NET_ADAPTER | grep inet | awk '{print  $2}')
  declare -g STUDIO_NET_GATEWAY=$(echo "$default_route" | awk '{print $3}')
  return 0
}
 
testLink () {
  # desc: test adapter link status
	# arg1: adapter name (optional)
	# uses $STUDIO_NET_ADAPTER as default
  # return 0 if UP
  # return 1 if DOWN
  adapter=${1:-$STUDIO_NET_ADAPTER}
  link_status=$(ip link show $adapter | awk '{print $9}')
  if [ "$link_status" != "UP" ]
  then
    _debug "${FUNCNAME[0]}: the link on $adapter is $link_status"
    return 1
  else
    _debug "${FUNCNAME[0]}: the link on $adapter is $link_status"
    return 0
  fi
}

testHostProbe () {
  # desc: use nmap to probe host when, eg, it is filtering icmp
  # arg: host ip to probe
  # return 0 if host appears up
  # return 1 if host appears down
  nmap_output=temp/nmap.$(date +%s).out
  nmap -oG ${nmap_output} -Pn $1 >/dev/null
  grep -q "Status: Up" ${nmap_output}
  if [ $? -eq "0" ]
  then
    _debug "${FUNCNAME[0]}: nmap reports host at $1 is up"
    return 0
  else
    _debug "${FUNCNAME[0]}: nmap reports host at $1 is down"
    return 1
  fi
}

testPing () {
  # desc: sub-function wrapper for ping
	# args: one IP address (uses STUDIO_NET_GATEWAY if empty)
  # return 0 if success
  # return 1 if not
  # reporting if host is up or down (uses nmap as 2nd check)
  ip=${1:-$STUDIO_NET_GATEWAY}
  ping_output=$(ping -n -c1 -W3 "$ip")
  if [ $? -ne "0" ]
  then
    # figure out if device is filtering ICMP (ie alive)
    icmp_filtered=$(echo "$ping_output" | head -2 | tail -1 | cut -d' ' -f5)
    if [[ $icmp_filtered = "filtered" ]]
    then
      _debug "${FUNCNAME[0]}: ping to $ip appears to be filtered"
      testHostProbe $ip
      if [ $? -eq "0" ]
      then
        _debug "${FUNCNAME[0]}: ping filtering detected, nmap reports: host is up"
        return 0
      fi
    else
      _debug "${FUNCNAME[0]}: no ping response, nmap also reports: host is down"
      return 1
    fi
    ping_output=$(ping -n -c1 -W5 "$ip")
    if [ $? -ne "0" ]
    then
      _debug "${FUNCNAME[0]}: ping to $ip failed: check networking"
      return 1
    else
      ping_latency=$(echo "$ping_output" | grep ^rtt | cut -d/ -f5)
      _debug "${FUNCNAME[0]}: ping to $ip success: latency $ping_latency"
      return 0
    fi
  else
    ping_latency=$(echo "$ping_output" | grep ^rtt | cut -d/ -f5)
    _debug "${FUNCNAME[0]}: ping to $ip success: latency $ping_latency"
    return 0
  fi
}

testLocalDNS () {
  # desc: test DNS resolution with local resolver
	# arg1: adapter name (STUDIO_NET_ADAPTER is default)
  # return 0 on success
  # return 1 on failure
  adapter=${1:-$STUDIO_NET_ADAPTER}
  nmcli_output=$(nmcli -t device show $adapter)
  # figure out how many local resolvers we have so we can enumerate if we see
  # fail on the first inquiry
  # declare -g DNS1 DNS2
  dns_primary=$(echo "$nmcli_output" | grep ^IP4.DNS | head -1 | cut -d: -f2)
  if [ $? -ne "0" ]
  then
    # try another if possible, otherwise return 1
    echo "FIX"
    return 1
  else
    dig_output=$(dig @$dns_primary www.google.com)
    dig_returncode=$?
    dig_answer=$(echo "$dig_output" | grep ^www.google.com | awk '{print $5}')
    dig_latency=$(echo "$dig_output" | grep "^;; Query time:" | awk '{print $4}')
    declare -g STUDIO_NET_DNS=$dns_primary
    _debug "${FUNCNAME[0]}: dns query to $dns_primary for www.google.com is $dig_answer latency $dig_latency"
    return 0
  fi
}

testRemoteDNS () {
  # desc: sub-function to test name resolution
  # args: none 
  # success: return 0 (we can reach name servers and resolve names)
  # failure: return 1
  googleDNS1="8.8.8.8"
  googleDNS2="9.9.9.9"
  testPing "$googleDNS1"
  if [ $? -ne "0" ]
  then
    testPing "$googleDNS2"
    if [ $? -ne "0" ]
    then
      echo "${RED}FAIL${RESET} can't reach any google public DNS"
      return 1
    else
      dig_output=$(dig @$googleDNS2 www.google.com)
      dig_returncode=$?
      dig_answer=$(echo "$dig_output" | grep ^www.google.com | awk '{print $5}')
      dig_latency=$(echo "$dig_output" | grep "^;; Query time:" | awk '{print $4}')
      _debug "${FUNCNAME[0]}: query to $googleDNS2 for www.google.com is $dig_answer latency  $dig_latency"
      return 0
    fi
  else
    dig_output=$(dig @$googleDNS1 www.google.com)
    dig_returncode=$?
    dig_answer=$(echo "$dig_output" | grep ^www.google.com | awk '{print $5}')
    dig_latency=$(echo "$dig_output" | grep "^;; Query time:" | awk '{print $4}')
    _debug "${FUNCNAME[0]}: query to $googleDNS1 for www.google.com is $dig_answer latency    $dig_latency"
  fi
}

testHTTP () {
  # desc: function to test http connectivity
  # arg 1: http server to test
  # arg 2: mode (simple|full) default=simple
  #   simple mode: return 0 as soon as HTTP STATUS=200, else return 1
  #   full mode: get to 200 and collect details
  # note, we will follow only ONE redirect
	# TODO need much better logic here...rethink how this is done
	# eg, when one test fails (eg google http fetch) it throws it all off
  mode=${2-simple}
  getHTTPheaders so "$1"
  # return 1 if we cannot get the http headers
  if [[ ! $? = "0" ]]
  then
    _debug "${FUNCNAME[0]}: failed http fetch at $1 with curl"
		return 1
  fi
  # print the headers
  #for h in ${!so[@]}
  #do
  # printf "${BLUE}%s=${RESET}${GREEN}%s${RESET}\n" $h "${so[$h]}"
  #done
	if [[ ${so["Status"]} =~ 30? ]]
	then
		# got a redirect, follow it once
    redirect=${so["location"]}
    getHTTPheaders so "$redirect"
		if [[ ${so["Status"]} = 200 ]]
		then
			# got a status 200
			_debug "${FUNCNAME[0]}: http alive at $1"
			return 0
		else
			# failed after http redirect
			_debug "${FUNCNAME[0]}: http redirect failed, giving up on $1"
			return 1
		fi
	elif [[ ${so["Status"]} = 200 ]]
	then
		_debug "${FUNCNAME[0]}: http fetch success at $1"
		return 0
	else
		_debug "${FUNCNAME[0]}: http fetch failed at $1"
		return 1
	fi
  #if [[ ${so["Status"]} = "200" ]] && [[ $mode = "simple" ]]
  #then
  #  logEvent 0 $FUNCNAME "http alive at $1"
  #  return 0
  #elif [[ ${so["Status"]} =~ 30? ]]
  #then
  #  redirect=${so["location"]}
  #  getHTTPheaders so "$redirect"
  #  if [[ ${so["Status"]} = "200" ]] && [[ $mode = "simple" ]]
  #  then
  #    logEvent 1 $FUNCNAME "http redirect from $1; http alive at $redirect"
  #    return 0
  #  else
  #    echo WHAT
  #  fi
  #else
  #  echo WHATWHAT
  #fi
  # enumerate through the array:
  #for h in ${!so[@]}; do printf "%s=%s\n" $h "${so[$h]}"; done | sort
}

# curl timeouts need to be handled better
# also capture curl timer data
# https://stackoverflow.com/questions/18215389/how-do-i-measure-request-and-response-times-at-once-using-curl

getHTTPheaders () {
  # Call this as: headers ARRAY URL
  # modified from: https://stackoverflow.com/questions/24943170/how-to-parse-http-headers-using-bash
  {
    # (Re)define the specified variable as an associative array.
    unset $1;
    declare -gA $1;
    local line rest
    # Get the first line, assuming HTTP/1.0 or above. Note that these fields
    # have Capitalized names.
    IFS=$' \t\n\r' read -r $1[Proto] $1[Status] rest
    # if we only get curl non-zero exit code we have a problem
    if [[ ${so[Proto]} =~ ^[1-9] ]] && [[ -z ${so[Status]} ]]
    then
      #logEvent 2 $FUNCNAME "curl non-zero error ${so[Proto]} for $2"
      return 1
    fi
    # Drop the CR from the message, if there was one.
    declare -gA $1[Message]="${rest%$'\r'}"
    # Now read the rest of the headers. 
    while true; do
      # Get rid of the trailing CR if there is one.
      IFS=$'\r' read line rest;
      # Stop when we hit an empty line
      if [[ -z $line ]]; then break; fi
      # Make sure it looks like a header
      # This regex also strips leading and trailing spaces from the value
      if [[ $line =~ ^([[:alnum:]_-]+):\ *(( *[^ ]+)*)\ *$ ]]; then
        # Force the header to lower case, since headers are case-insensitive,
        # and store it into the array
        declare -gA $1[${BASH_REMATCH[1],,}]="${BASH_REMATCH[2]}"
      else
        _debug "${FUNCNAME[0]}: ignoring non-header line: %q\n' '$line"
        printf "Ignoring non-header line: %q\n" "$line" >> /dev/stderr
      fi
    done
    # use process substitution and capture curl's exit code in case of failure
  } < <(curl --connect-timeout 3 -Is "$2"; printf "$?")
}

# collect curl timer data
# see https://stackoverflow.com/questions/18215389/how-do-i-measure-request-and-response-times-at-once-using-curl
# see curl_format.txt
# curl -w "@curl_format.txt" -o /dev/null -s "http://wordpress.com/"

# check out chrony for time sync

# check out lazydocker

# check out lazygit

### UNIFIED EDITOR
_studioEdit() {
	# given path ($1)
	[[ -z "${1}" ]] && { _error "full path is required"; return 1; }
  local _file=${1}
	vim -u "${_studioDir}/.config/vimrc" -c 'set syntax=markdown' "${_file}"
}

# FUN
_superJob() {
	# cribbed from the internet somewhere
	local x		# time in seconds
	local z		# message
	x=${1:-1}
	z=${2:-studiofun}
	progressbar() {
 		local loca=$1; local loca2=$2;
		declare -a bgcolors; declare -a fgcolors;
		for i in {40..46} {100..106}; do
    	bgcolors+=("$i")
		done
		for i in {30..36} {90..96}; do
			fgcolors+=("$i")
		done
		local u=$(( 50 - loca ));
		local y; local t;
		local z; z=$(printf '%*s' "$u");
		local w=$(( loca * 2 ));
		local bouncer=".oO°Oo.";
		for ((i=0;i<loca;i++)); do
			t="${bouncer:((i%${#bouncer})):1}"
			bgcolor="\\E[${bgcolors[RANDOM % 14]}m \\033[m"
			y+="$bgcolor";
		done
		fgcolor="\\E[${fgcolors[RANDOM % 14]}m"
		echo -ne " $fgcolor$t$y$z$fgcolor$t \\E[96m(\\E[36m$w%\\E[96m)\\E[92m            $fgcolor$loca2\\033[m\r"
	}
	timeprogress() {
		local loca="$1"; local loca2="$2";
		loca=$(bc -l <<< scale=2\;"$loca/50")
		for i in {1..50}; do
			progressbar "$i" "$loca2"; 
				sleep "$loca";
			done
			echo -e "\n"
	}
	#timeprogress "$1" "$2"
	timeprogress "$x" "$z"
}





