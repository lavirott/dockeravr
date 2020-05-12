#!/bin/sh

PATH=/opt/simulide/SimulIDE_0.3.12-SR8/bin:$PATH
# echo "Starting SimulIDE with simu=${simu} and hex=${hex}"
cd /tmp

simulide --simu file.simu --hex file.hex --platform offscreen