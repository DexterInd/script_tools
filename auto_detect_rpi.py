'''
## License

The MIT License (MIT)

GrovePi for the Raspberry Pi: an open source platform for connecting Grove Sensors to the Raspberry Pi.
Copyright (C) 2017  Dexter Industries

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
'''

import subprocess

# RPI_VARIANTS was inspired from http://www.raspberrypi-spy.co.uk/2012/09/checking-your-raspberry-pi-board-version/
# This module is meant for retrieving the Raspberry Pi's generation model, PCB model (dimension-wise) and PCB revision
# Works with Python 3 & 2 !!!

# Each key represents the hardware revision number
# This isn't the same as the RaspberryPi revision
# Having the hardware revision number is useful when working with hardware or software.

RPI_VARIANTS = {
"0002" : ["Model B Rev 1", "RPI1"],

"0003" : ["Model B Rev 1 ECN0001 (no fuses, D14 removed)", "RPI1"],

"0004" : ["Model B Rev 2", "RPI1"],
"0005" : ["Model B Rev 2", "RPI1"],
"0006" : ["Model B Rev 2", "RPI1"],

"0007" : ["Model A", "RPI1"],
"0008" : ["Model A", "RPI1"],
"0009" : ["Model A", "RPI1"],

"000d" : ["Model B Rev 2", "RPI1"],
"000e" : ["Model B Rev 2", "RPI1"],
"000f" : ["Model B Rev 2", "RPI1"],

"0010" : ["Model B+", "RPI1"],
"0013" : ["Model B+", "RPI1"],
"900032" : ["Model B+", "RPI1"],

"0011" : ["Compute Module", "RPI-COMPUTE-MODULE"],
"0014" : ["Compute Module", "RPI-COMPUTE-MODULE"],

"0012" : ["Model A+", "RPI1"],
"0015" : ["Model A+", "RPI1"],

"a01041" : ["Pi 2 Model B v1.1", "RPI2"],
"a21041" : ["Pi 2 Model B v1.1", "RPI2"],

"a22042" : ["Pi 2 Model B v1.2", "RPI2"],

"900092" : ["Pi Zero v1.2", "RPI0"],

"900093" : ["Pi Zero v1.3", "RPI0"],

"0x9000C1" : ["Pi Zero W", "RPI0"],

"a02082" : ["Pi 3 Model B", "RPI3"],
"a22082" : ["Pi 3 Model B", "RPI3"],
}

# represents indexes for each corresponding key in the above dictionary
RPI_MODEL_AND_PCBREV = 0
RPI_GENERATION_MODEL = 1

# returns slightly more descriptive information on the hardware revision of the Raspberry Pi
# e.g. "Pi 2 Model B v1.1" etc
def getRPIHardwareRevCode():
    bash_command = "sudo cat /proc/cpuinfo | grep Revision | awk '{print $3}'"
    revision = sendBashCommand(bash_command)
    rpi_description = ""

    # if stdout has something
    if not revision is None:
        rpi_description = RPI_VARIANTS[revision][RPI_MODEL_AND_PCBREV]

    return rpi_description

# returns the Raspberry Pi's generation Model
# e.g. "RPI2", "RPI3" etc
def getRPIGenerationCode():

    bash_command = "sudo cat /proc/cpuinfo | grep Revision | awk '{print $3}'"
    revision = sendBashCommand(bash_command)
    rpi_description = ""

    # if stdout has something
    if not revision is None:
        rpi_description = RPI_VARIANTS[revision][RPI_GENERATION_MODEL]

    return rpi_description

# takes a string of commands and spawns commands inside linux's environment
# and returns the output of that process, if provided
def sendBashCommand(bash_command)

	process = subprocess.Popen(bash_command.split(), stdout = subprocess.PIPE)

    # use communicate to read data from stdout - index 0 is for stdout and 1 is for stderr
    # don't use this function if the data size is large or unlimited
    # useeful when trying to avoid deadlocks
	output = process.communicate()[0]
	return output
