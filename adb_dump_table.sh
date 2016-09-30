# please first edit tablelist part in this file,then 
# "usage: $0 dbname port schema"
#
#
#
#

cat > tablelist << EOF
cardpkg_payment
cardpkg_origin
cardpkg_origin_dtl
cardpkg_sale
EOF

# 
if [ ! -f tablelist ]; then
  echo "please first create tablelist file,input the table name in the file. "
fi


if [ ! -s tablelist ]; then
  echo "the file tablelist is empty, please input the table name in the file."
fi

if [ $# -ne 3 ]; then
  echo "usage: $0 dbname port schema"
  exit 0
fi


dbname=$1
port=$2
schema=$3
#tabname=$4
#filename=$schema'.'$tabname'.sql'

cat tablelist | while read name
do
   tabname=$name
   filename=$schema'.'$tabname'.sql'
   pg_dump -d $dbname -p $port -t $schema.$tabname -f $filename &
done   

rm tablelist
