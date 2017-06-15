#!/bin/sh

exec shiny-server > /var/log/shiny-server.log 2>&1
