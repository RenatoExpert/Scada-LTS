mkdir -p /tmp/lib	&& \
while read p
do
	wget "$p" -P /tmp/lib
#	curl -o /tmp/lib "$p"
done <liblist.txt
