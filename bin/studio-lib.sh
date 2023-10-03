#!/usr/bin/env bash
# file: studio-lib.sh
# source: https://github.com/periplume/studio.git
# author: jason@bloom.us
# desc: shell library functions

# SCRIPT AND SHELL SETTINGS
set -o errexit
set -o nounset
set -o pipefail

# BEHAVIOR
# debugging and logging settings
# script debug toggle (set to true to enable default global debugging)
_DEBUG=false
# silent mode for scripting (supresses all output)
_SILENT=false
# logging facility
_LOG=false


# OUTPUT

# some color
red=$(tput setab 1; tput setaf 7)
boldred=$(tput setab 1 ; tput setaf 7)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
yellow=$(tput setaf 3)
reset=$(tput sgr0)
label=$(tput setab 7; tput setaf 0)
prompt=$(tput setab 5; tput setaf 7)

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
# suppress all if _SILENT=true
#
# call as
# _warn "message"
# _info "message"

# _fLOG creates logging functions based on runtime switches (command options)
# and static features: (defaults and global variables)
#
# the three main determinants:
# _SILENT= true | false
# _LOG= true | false
# _DEBUG= true | false
#
# subordinate dependencies:
# _canLog= true | false
# _logFile= "path to file"
# $(tput colors)

_fLOG() {
	# collapsing function...sets up according to the static determinants
	# creates all log functions dynamically
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
	[[ "$_SILENT" = "false" ]] && _console=1
	[[ "$_LOG" = "true" && "${_canLog:-}" = "true" ]] && _log=1
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
	# TODO use eval, assoc arrays and loops to build these functions with less
	# code...someday...for now, it works just fine
	# CONSOLE AND LOG
	if [[ $_console = 1 && $_log = 1 ]]; then
		_debug() {
			[[ "$_DEBUG" = "false" ]] && return
			local _timeStamp=$(date +%s.%N)
			printf '%s %s\n' "${_cDebug}DEBUG${_cReset}" "${@}"
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cDebug}DEBUG${_cReset}" "${@}" >>${_logFile}
		}
		_info() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cInfo}INFO${_cReset}" "${@}" >>${_logFile}
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
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cWarn}WARN${_cReset}" "${@}" >>${_logFile}
		}
		_error() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s\n' "${_cError}ERROR${_cReset}" "${@}"
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cError}ERROR${_cReset}" "${@}" >>${_logFile}
		}
		_ask() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s' "${_cAsk}USER${_cReset}" "${@}"
			#printf '%s %s %s\n' "$_timeStamp" "${self} ${_cAsk}USER${_cReset}" "${@}" >>${_logFile}
			# don't log prompts...if something is important, log as debug
		}
	# LOG ONLY
	elif [[ $_console = 0 && $_log = 1 ]]; then
		_debug() {
			[[ "$_DEBUG" = "false" ]] && return
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cDebug}DEBUG${_cReset}" "${@}" >>${_logFile}
		}
		_info() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cInfo}INFO${_cReset}" "${@}" >>${_logFile}
		}
		_warn() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cWarn}WARN${_cReset}" "${@}" >>${_logFile}
		}
		_error() {
			local _timeStamp=$(date +%s.%N)
			printf '%s %s %s\n' "$_timeStamp" "${self} ${_cError}ERROR${_cReset}" "${@}" >>${_logFile}
		}
		_ask() {
			:
			#local _timeStamp=$(date +%s.%N)
			#printf '%s %s %s\n' "$_timeStamp" "${self} ${_cAsk}USER${_cReset}" "${@}" >>${_logFile}
			# don't log _ask prompts
		}
	# CONSOLE ONLY
	elif [[ $_console = 1 && $_log = 0 ]]; then
		_debug() {
			[[ "$_DEBUG" = "false" ]] && return
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
