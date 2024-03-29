#!/bin/bash
#/ Usage: senddata.sh reads config.sh for configuration of API Path & API Key
#/ sends to generic api and/or thingspeak.com
#/ currently no parameters or options
usage() {
  grep '^#/' "$0" | cut -c4-
  exit 0
}
expr "$*" : ".*--help" > /dev/null && usage

if [ "$#" -ne 0 ]; then
  usage
fi

# losetup ist nötig, damit das (neu) mounten einfacher wird
# Der Befehl ist nur ein Mal nötig zur initalisierung.
# Das passiert schon im init script; mir sind verschiedene werte bekannt die passen können
# losetup -o 65536 /dev/loop0 /media/usbdisk.img
# losetup -o 32256 /dev/loop0 /media/usbdisk.img
# losetup -o 32768 /dev/loop0 /media/usbdisk.img
# usbdisk.img erstellen mit z.B. "dd if=/dev/zero of=/media/usbdisk.img bs=1M count=2048"
# Im Windows Partitionieren und Formatieren mit FAT(32)
# Der Richtige Wert für den Offset ergibt sich aus Startsector * 512 Byte Sectorsize
# file /media/usbdisk.img
# /media/usbdisk.img: DOS/MBR boot sector ... startsector 128, 4188160 sectors

# Todo: Error Handling
# What if - Config File doesn't exist or isn't readable
# Config variables are empty

# Funktion die einen Wert aus einer CSV Zeile holt
f_field_nr () {
  VALUE=$(echo $1 | cut -d";" -f"$2")
  echo $VALUE
}

# Timestamp Format
#$(/usr/bin/date +%y%m%d)
# Logfile mit Datum
FILENAME="/mnt/Logfile_$(/bin/date +%y%m%d).csv"

# Fsck mit automatischer Reparatur durchführen
/usr/sbin/fsck.fat -a /dev/loop0

# Mount am Pi wird nur read only durchgeführt
/bin/mount -o ro /dev/loop0  /mnt

# $LINE enthält die vorletzte Zeile. Es könnte möglich sein, dass die letzte Zeile nicht fertig geschrieben ist
LINE=$(/usr/bin/tail $FILENAME -n2 | /usr/bin/head -n 1 | /bin/sed s/,/./g )


# Laden der API Keys, siehe config.sh.sample
source /usr/local/sbin/config.sh

# Idee: nur alle 5 Minuten schreiben, ausser es tut sich was interessantes mit dem Strom
if [[ $(f_field_nr $LINE 20) -gt 5 ]] || [[ $(date +%M)%5 -eq 0 ]]; then
  echo "wir schreiben"
  #echo /usr/bin/curl "${thingspeakUrl}?api_key=${thingspeakApiKey}&field1=$(f_field_nr $LINE 3)&field2=$(f_field_nr $LINE 19)&field3=$(f_field_nr $LINE 5)&field4=$(f_field_nr $LINE 11)&field5=$(f_field_nr $LINE 39)&field6=$(f_field_nr $LINE 40)&field7=$(f_field_nr $LINE 44)"
  /usr/bin/curl "${thingspeakUrl}?api_key=${thingspeakApiKey}&field1=$(f_field_nr $LINE 3)&field2=$(f_field_nr $LINE 19)&field3=$(f_field_nr $LINE 5)&field4=$(f_field_nr $LINE 11)&field5=$(f_field_nr $LINE 39)&field6=$(f_field_nr $LINE 40)&field7=$(f_field_nr $LINE 44)"
  /usr/bin/curl "${thingspeakUrl}?api_key=${thingspeakApiKey2}&field1=$(f_field_nr $LINE 47)&field2=$(f_field_nr $LINE 49)&field3=$(f_field_nr $LINE 50)&field4=$(f_field_nr $LINE 37)&field5=$(f_field_nr $LINE 34)&field6=$(f_field_nr $LINE 35)&field7=$(f_field_nr $LINE 10)&field8=$(f_field_nr $LINE 4)"

  #echo /usr/bin/curl "${genericUrl}?key=${genericApiKey}&kt=$(f_field_nr $LINE 3)&rgt=$(f_field_nr $LINE 4)&luftzahl=$(f_field_nr $LINE 5)&rueklauftemp=$(f_field_nr $LINE 8)&rlapumpe=$(f_field_nr $LINE 9)&x35=$(f_field_nr $LINE 10)&at=$(f_field_nr $LINE 11)&ldz_ist=$(f_field_nr $LINE 12)&ldz_ziel=$(f_field_nr $LINE 13)&ldz_soll=$(f_field_nr $LINE 14)&einschubtemp=$(f_field_nr $LINE 19)&pto1=$(f_field_nr $LINE 34)&ptu1=$(f_field_nr $LINE 35)&tws=$(f_field_nr $LINE 37)&rt=$(f_field_nr $LINE 39)&vlt1=$(f_field_nr $LINE 40)&vlt1soll=$(f_field_nr $LINE 41)&hk1pumpe=$(f_field_nr $LINE 42)&vlt2=$(f_field_nr $LINE 44)&vlt2soll=$(f_field_nr $LINE 45)&hk2pumpe=$(f_field_nr $LINE 46)&kollektoremp=$(f_field_nr $LINE 47)&speichertemp_unten_regelung=$(f_field_nr $LINE 48)&speicher1solar=$(f_field_nr $LINE 49)&speicher2solar=$(f_field_nr $LINE 50)"
  /usr/bin/curl "${genericUrl}?key=${genericApiKey}&kt=$(f_field_nr $LINE 3)&rgt=$(f_field_nr $LINE 4)&luftzahl=$(f_field_nr $LINE 5)&rueklauftemp=$(f_field_nr $LINE 8)&rlapumpe=$(f_field_nr $LINE 9)&x35=$(f_field_nr $LINE 10)&at=$(f_field_nr $LINE 11)&ldz_ist=$(f_field_nr $LINE 12)&ldz_ziel=$(f_field_nr $LINE 13)&ldz_soll=$(f_field_nr $LINE 14)&einschubtemp=$(f_field_nr $LINE 19)&pto1=$(f_field_nr $LINE 34)&ptu1=$(f_field_nr $LINE 35)&tws=$(f_field_nr $LINE 37)&rt=$(f_field_nr $LINE 39)&vlt1=$(f_field_nr $LINE 40)&vlt1soll=$(f_field_nr $LINE 41)&hk1pumpe=$(f_field_nr $LINE 42)&vlt2=$(f_field_nr $LINE 44)&vlt2soll=$(f_field_nr $LINE 45)&hk2pumpe=$(f_field_nr $LINE 46)&kollektoremp=$(f_field_nr $LINE 47)&speichertemp_unten_regelung=$(f_field_nr $LINE 48)&speicher1solar=$(f_field_nr $LINE 49)&speicher2solar=$(f_field_nr $LINE 50)&iststromWMTR=$(f_field_nr $LINE 20)"

  #/usr/bin/curl "${thingspeakUrl}?api_key=${thingspeakApiKey}&filed1=$(f_field_nr $LINE 3)&field2=$(f_field_nr $LINE 19)"
else
  echo "Wir schreiben nix, Timestamp letzte Zeile aus dem Image $(f_field_nr $LINE 1) $(f_field_nr $LINE 2)"
fi

umount /mnt

