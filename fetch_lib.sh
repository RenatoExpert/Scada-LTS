while read p
do
	wget "$p" -P lib
done <liblist.txt
