#!/bin/bash

dir="tmp"

COMMAND1="time find $dir -type f -delete"
COMMAND2="time find $dir -type f -exec rm -fr {} \;"
COMMAND3="time find $dir -type f | xargs -0 rm -fr"
