while read p
do
	wget "$p" -P /tmp/lib
done <liblist.txt
