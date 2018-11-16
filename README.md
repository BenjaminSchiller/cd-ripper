# abcde

## resources

- [man page](https://linux.die.net/man/1/abcde)
- [github repo](https://github.com/johnlane/abcde)
- [FAQ](https://github.com/johnlane/abcde/blob/master/FAQ)
- [get album art](http://www.andrews-corner.org/linux/abcde/getalbumart.html#embedflac)
- [lossless config](http://www.andrews-corner.org/linux/abcde/abcde_lossless.html#flac)
- [Tutorial](https://somewideopenspace.wordpress.com/yet-another-headless-cd-ripper-and-mpd-on-raspberry-pi-installation-guide-yahcdramorpig/start-ripping-when-cd-is-inserted/)

## install

```
sudo apt-get install abcde flac at glyrc
```

## CD insert

### enable udev rule

```
sudo su
echo 'SUBSYSTEM=="block", KERNEL=="sr0", ACTION=="change", RUN+="/usr/bin/at -M -f /home/pi/cd-ripper/rip-nohup.sh now"' > /etc/udev/rules.d/99-cd-ripper.rules; sudo udevadm control --reload; systemctl daemon-reload; service udev restart; echo "New Rule: $(cat /etc/udev/rules.d/99-cd-ripper.rules)"
```

```
sudo su
echo 'SUBSYSTEM=="block", KERNEL=="sr0", ACTION=="change", RUN+="nohup /home/pi/cd-ripper/rip.sh &> /dev/null &"' > /etc/udev/rules.d/99-cd-ripper.rules; sudo udevadm control --reload; systemctl daemon-reload; service udev restart; echo "New Rule: $(cat /etc/udev/rules.d/99-cd-ripper.rules)"
```

### disable udev rule
```
sudo su
rm /etc/udev/rules.d/99-cd-ripper.rules; sudo udevadm control --reload; systemctl daemon-reload; service udev restart
```

### manually edit sidev config

```
nano /lib/systemd/system/systemd-udevd.service
```


## flac 2 mp3 conversion

### install dependencies
```
sudo apt-get install libav-tools
```

### convert a single file
```
avconv -i [FileName.flac] -c:a libmp3lame -b:a 320k [FileName.mp3]

export SRC="/home/pi/cd-ripper/rips/Dio/Holy_Diver/02.Holy_Diver.flac"

avconv -i $SRC -c:a libmp3lame -b:a 320k 320k.mp3
avconv -i $SRC -c:a libmp3lame -b:a 256k 256k.mp3
avconv -i $SRC -c:a libmp3lame -b:a 160k 160k.mp3
avconv -i $SRC -c:a libmp3lame -b:a 128k 128k.mp3
```