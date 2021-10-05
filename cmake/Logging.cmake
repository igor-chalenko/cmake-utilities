cmake_policy(SET CMP0057 NEW)
cmake_policy(SET CMP0011 NEW)

include(${CMAKE_CURRENT_LIST_DIR}/GlobalMap.cmake)

set(_term "$ENV{TERM}")
if (_term)
    execute_process(COMMAND tput colors OUTPUT_VARIABLE _colours OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(COMMAND tput bold OUTPUT_VARIABLE BOLD OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (VERBOSE)
        message(STATUS "Terminal supports ${_colours} colours")
    endif()
else()
    if (VERBOSE)
        message(STATUS "Terminal doesn't support ANSI colour sequences")
    endif()
    unset(_colours)
endif()

if(_colours)
    string(ASCII 27 Esc)
    set(ColourReset "${Esc}[m")
    #set(ColourBold  "${Esc}[1m")
    set(Red         "${Esc}[31m")
    set(Green       "${Esc}[32m")
    set(Yellow      "${Esc}[33m")
    set(Blue        "${Esc}[34m")
    set(Magenta     "${Esc}[35m")
    set(Cyan        "${Esc}[36m")
    set(White       "${Esc}[37m")
    set(BoldRed     "${Esc}[1;31m")
    set(BoldGreen   "${Esc}[1;32m")
    set(BoldYellow  "${Esc}[1;33m")
    set(BoldBlue    "${Esc}[1;34m")
    set(BoldMagenta "${Esc}[1;35m")
    set(BoldCyan    "${Esc}[1;36m")
    set(BoldWhite   "${Esc}[1;37m")
else()
    set(ColourReset "")
    #set(ColourBold  "")
    set(Red         "")
    set(Green       "")
    set(Yellow      "")
    set(Blue        "")
    set(Magenta     "")
    set(Cyan        "")
    set(White       "")
    set(BoldRed     "")
    set(BoldGreen   "")
    set(BoldYellow  "")
    set(BoldBlue    "")
    set(BoldMagenta "")
    set(BoldCyan    "")
    set(BoldWhite   "")
endif()

function(_log_levels _out_var)
    set(${_out_var} "TRACE;DEBUG;INFO;WARN;ERROR" PARENT_SCOPE)
endfunction()

function(log_message _level _context _message)
    _log_levels(_levels)
    list(FIND _levels ${_level} _ind)
    global_get(log.context.${_context} logging.level _current_level)
    if (NOT _current_level OR _current_level LESS_EQUAL ${_ind})
        set(_index 3)
        foreach(_arg ${ARGN})
            math(EXPR _base_index "${_index} - 2")
            string(REPLACE "{${_base_index}}" "${Green}${ARGV${_index}}${ColourReset}" _message "${_message}")
            math(EXPR _index "${_index} + 1")
        endforeach()
        string(TIMESTAMP _timestamp)
        if (_level STREQUAL FATAL)
            message(FATAL_ERROR "[${_timestamp}][${_context}][${_level}] ${_message}")
        else()
            message("[${_timestamp}][${_context}][${_level}] ${_message}")
        endif()
    endif()
endfunction()


function(log_level _context _level)
    _log_levels(_levels)
    list(FIND _levels ${_level} _ind)
    if (_ind GREATER -1)
        global_set(log.context.${_context} logging.level ${_ind})
    endif()
endfunction()

function(log_debug _context _message)
    log_message(DEBUG "${_context}" "${_message}" ${ARGN})
endfunction()

function(log_trace _context _message)
    log_message(TRACE "${_context}" "${_message}" ${ARGN})
endfunction()

function(log_info _context _message)
    log_message(INFO "${_context}" "${_message}" ${ARGN})
endfunction()

function(log_error _context _message)
    log_message(ERROR "${_context}" "${Red}${_message}${ColourReset}" ${ARGN})
endfunction()

function(log_fatal _context _message)
    log_message(FATAL "${_context}" "${Red}${_message}${ColourReset}" ${ARGN})
endfunction()

function(log_warn _context _message)
    log_message(WARNING "${_context}" "${Cyan}${_message}${ColourReset}" ${ARGN})
endfunction()