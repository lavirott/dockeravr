#!/bin/sh

PATH=/opt/simulide/bin:$PATH

echo "Starting SimulIDE with simu=${simu} and hex=${hex}"

simulide --simu /tmp/file.simu --hex /tmp/file.hex --platform offscreen


