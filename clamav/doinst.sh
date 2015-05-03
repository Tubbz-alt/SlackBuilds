config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
  mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
  # toss the redundant copy
  rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

perms() {
  # Keep same perms on file
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
  cp -a $OLD $NEW.incoming
  cat $NEW > $NEW.incoming
  mv $NEW.incoming $NEW
  fi
  config $NEW
}

perms etc/rc.d/rc.clamav.new
config etc/clamav/freshclam.conf.new
config etc/clamav/clamd.conf.new
config etc/logrotate.d/clamav.new

# Remove new log if one is already present (thanks to SBo)
config var/log/clamav/clamd.log.new ; rm -f var/log/clamav/clamd.log.new
config var/log/clamav/freshclam.log.new ; rm -f var/log/clamav/freshclam.log.new

# Add user and group (uid=210 and gid=210 are SBo suggest)
if ! getent group clacmav 2>&1 > /dev/null; then
    if ! getent group 210 2>&1 > /dev/null; then
        chroot . groupadd -g 210 clamav &>/dev/null
    else
        chroot . groupadd clamav &>/dev/null
    fi
fi

if ! getent passwd clacmav 2>&1 > /dev/null; then
    if ! getent passwd 210 2>&1 > /dev/null; then
        chroot . useradd -u 210 -d /dev/null -s /bin/false -c "Clam AntiVirus" -g clamav clamav &>/dev/null
    else
        chroot . useradd -d /dev/null -s /bin/false -c "Clam AntiVirus" -g clamav clamav &>/dev/null
    fi
fi

echo "
*** NOTE ***
Run freshclam to download some virus definitions before starting clamav
"
