#!/bin/bash

ME=`readlink -f $BASH_SOURCE`
P=`dirname $ME`

export LUA_PATH="$P/../?.lua;$P/../lib/?.lua;;"
export LUA_CPATH="$P/../lib/?.so;;"

$P/spec.lua
