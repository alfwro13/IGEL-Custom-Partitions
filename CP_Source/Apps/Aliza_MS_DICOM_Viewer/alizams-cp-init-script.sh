#! /bin/bash
#set -x
#trap read debug

ACTION="custompart-alizams_${1}"

# mount point path
MP=$(get custom_partition.mountpoint)

# custom partition path
CP="${MP}/alizams"

# output to systemlog with ID amd tag
LOGGER="logger -it ${ACTION}"

echo "Starting" | $LOGGER

case "$1" in
init)
chmod -R go+rx "${CP}/usr/local/alizams/DICOM"
# Linking files and folders on proper path
find ${CP} | while read LINE
do
  DEST=$(echo -n "${LINE}" | sed -e "s|${CP}||g")
  if [ ! -z "${DEST}" -a ! -e "${DEST}" ]; then
    # Remove the last slash, if it is a dir
    [ -d $LINE ] && DEST=$(echo "${DEST}" | sed -e "s/\/$//g") | $LOGGER
    if [ ! -z "${DEST}" ]; then
      ln -sv "${LINE}" "${DEST}" | $LOGGER
    fi
  fi
done

  # after CP installation run wm_postsetup to activate mimetypes for SSO
  if [ -d /run/user/777 ]; then
    wm_postsetup
    # delay the CP ready notification
    sleep 3
  fi

;;
stop)
# unlink linked files
find ${CP} | while read LINE
do
  DEST=$(echo -n "${LINE}" | sed -e "s|${CP}||g")
  unlink $DEST | $LOGGER
done

;;
esac

echo "Finished" | $LOGGER

exit 0
