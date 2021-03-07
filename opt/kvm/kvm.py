#!/usr/bin/python
import subprocess
import re
import os

###
# Params
###
USBHUB_DEVICE_ID="214b:7250"

USB_NO_SWAP={
  '1d6b': ['0002', '0003'], # Linux Foundation [3.0, 2.0] root hub
  '05e3': ['0608', '0610'], # Genesys Logic, Inc. Hub
  '1b1c': ['0c10'],         # Corsair Commander PRO
  '048d': ['8297'],         # Integrated Technology Express, Inc. IT8297 RGB LED Controller
  '0414': ['a002'],         # Giga-Byte Technology Co., Ltd USB Audio
  '8087': ['0029'],         # Intel Corp. AX200 Bluetooth
  '214b': ['7250'],         # USB Hub Device Thing
  '1d6b': ['0003'],
#  '074d': ['0002'],         # Micronas GmbH BLUE USB Audio 2.0
#  '0b05': ['1898']          # Asus Mouse
}

USB_VIDEO_MATRIX={
  # USB Bus => Video Card
  '001': '4b',        # Button 1
  '003': '4a',        # Button 2
}

def no_switch_device():
  global USB_NO_SWAP
  if os.environ['ID_VENDOR'] not in USB_NO_SWAP.keys():
    return False
  
  return os.environ['ID_MODEL_ID'] in USB_NO_SWAP[os.environ['ID_VENDOR']]


###################
####           ####
## START OF CODE ##
####           ####
###################

# IF WE SWITCH THE HUB GET THE NEW VM AND SAVE TO FILE

if 'ID_VENDOR' not in os.environ:
  exit(1)
if 'ID_MODEL_ID' not in os.environ:
  exit(1)

#if os.environ['ACTION'] != "add":
#  exit(1)

if os.environ['ID_VENDOR'] == '214b' and os.environ['ID_MODEL_ID'] == '7250':
  print("HUB")
  # Figure out what VM we should be attaching to
  ## Get List of all RUNNING VM's
  vm_list = subprocess.run(
    ["virsh", "list"], 
    stdout=subprocess.PIPE, 
    text=True
  ).stdout.split("\n")[2:-2]

  for vm in vm_list:
    vm_name = re.findall(r" [0-9]+[\ ]*([a-zA-Z0-9\ \-\_]*[a-zA-Z0-9])[\ ]*running", vm)[0]
    print("Checking if we should connect the hub to %s" % vm_name)
    # Check if VM has the video card associated w/ current USB bus
    vm_config = subprocess.run(
      ["virsh", "dumpxml", vm_name],
      stdout=subprocess.PIPE, 
      text=True
    ).stdout

    regexp = re.compile(r"<source>[\s]*<address (?:.*) bus=\'0x%s\' slot=" % USB_VIDEO_MATRIX[os.environ['BUSNUM']])    

    if regexp.search(vm_config):
      print("Found!")
      try:
        with open("/opt/kvm/current_vm", "w+") as f:
          f.write(vm_name)
          f.close()
      except IOError as e:
        print("I/O error({0}): {1}".format(e.errno, e.strerror))
      except:
        print("Unexpected error:", sys.exc_info()[0])
    else:
      print("Nope")
if no_switch_device():
  print("CAN'T SWAP THIS DEVICE")
  exit(1)