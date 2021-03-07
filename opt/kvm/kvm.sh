#!/bin/bash
set -e
python /opt/kvm/kvm.py >> /opt/kvm/logs/python.log 2>&1


DOMAIN=`cat /opt/kvm/current_vm`
if [ -z "${DOMAIN}" ]; then
  echo "Missing libvirt domain parameter." >> /opt/kvm/logs/bash.log
  exit 1
fi
# #
# # Do some sanity checking of the udev environment variables.
# #

if [ -z "${ID_VENDOR_ID}" ]; then
  echo "Missing udev ID_VENDOR_ID environment variable." >> /opt/kvm/logs/bash.log
  exit 1
fi

if [ -z "${ID_MODEL_ID}" ]; then
  echo "Missing udev ID_MODEL_ID environment variable." >> /opt/kvm/logs/bash.log
  exit 1
fi

if [ -z "${SUBSYSTEM}" ]; then
  echo "Missing udev SUBSYSTEM environment variable." >> /opt/kvm/logs/bash.log
  exit 1
fi

if [ -z "${DEVTYPE}" ]; then
  #echo "Missing udev DEVTYPE environment variable." >> /opt/kvm/logs/bash.log
  exit 1
fi

if [ "${DEVTYPE}" == "usb_interface" ]; then
  # This is normal -- sometimes the udev rule will match
  # usb_interface events as well.
  exit 0
fi
if [ "${DEVTYPE}" != "usb_device" ]; then
  echo "Invalid udev DEVTYPE: ${DEVTYPE}" >> /opt/kvm/logs/bash.log
  exit 1
fi

if [ -z "${ACTION}" ]; then
  echo "Missing udev ACTION environment variable." >> /opt/kvm/logs/bash.log
  exit 1
fi

if [ -z "${BUSNUM}" ]; then
  echo "Missing udev BUSNUM environment variable." >> /opt/kvm/logs/bash.log
  exit 1
fi
if [ -z "${DEVNUM}" ]; then
  echo "Missing udev DEVNUM environment variable." >> /opt/kvm/logs/bash.log
  exit 1
fi


#
# Action
#


if [ "${ACTION}" == 'add' ]; then
  COMMAND='attach-device'
elif [ "${ACTION}" == 'remove' ]; then
  COMMAND='detach-device'
elif [ "${ACTION}" == 'change' ]; then
  COMMAND='attach-device'
elif [ "${ACTION}" == 'bind' ]; then
  echo "virsh detach-device $DOMAIN /opt/kvm/devices/${ID_VENDOR_ID}-${ID_MODEL_ID}.xml" >> /opt/kvm/logs/bash.log
  virsh detach-device $DOMAIN /opt/kvm/devices/${ID_VENDOR_ID}-${ID_MODEL_ID}.xml >> /opt/kvm/logs/bash.log
  COMMAND='attach-device'
else
  echo "Invalid udev ACTION: ${ACTION}" >> /opt/kvm/logs/bash.log
  #exit 1
fi

#
# Now we have all the information we need to update the VM.
# Run the appropriate virsh-command, and ask it to read the
# update XML from stdin.
#
cat > "/opt/kvm/devices/${ID_VENDOR_ID}-${ID_MODEL_ID}.xml" <<END
<hostdev mode='subsystem' type='usb'>
  <source>
    <vendor id='0x${ID_VENDOR_ID}' />
    <product id='0x${ID_MODEL_ID}' />
  </source>
</hostdev>
END

echo "virsh $COMMAND $DOMAIN /opt/kvm/devices/${ID_VENDOR_ID}-${ID_MODEL_ID}.xml" >> /opt/kvm/log4.txt
virsh $COMMAND $DOMAIN /opt/kvm/devices/${ID_VENDOR_ID}-${ID_MODEL_ID}.xml >> /opt/kvm/log4.txt

#echo "virsh attach-device  /opt/kvm/devices/${ID_VENDOR_ID}-${ID_MODEL_ID}.xml" >> /opt/kvm/log4.txt
#$(virsh attach-device ${DOMAIN} /opt/kvm/devices/${ID_VENDOR_ID}:${ID_MODEL_ID}.xml) >> /opt/kvm/attach.txt

