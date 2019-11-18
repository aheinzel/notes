#!/bin/bash

while read FN
do
   if [ $(cat "${FN}" | wc -l) -ne 1 ]
   then
      echo "skipping ${FN} - invalid number of lines"
      continue
   fi

   if [ $(awk -F "\t" '{print NF}' "${FN}") -ne 5 ]
   then
      echo "skipping ${FN} - invalid number of columns"
      continue
   fi 

   HOST1=$(cut -d "	" -f 1 "${FN}")
   USER1=$(cut -d "	" -f 2 "${FN}")
   PW_FILE1="$(dirname "${FN}")/$(cut -d "	" -f 3 "${FN}")"
   USER2=$(cut -d "	" -f 4 "${FN}")
   PW_FILE2="$(dirname "${FN}")/$(cut -d "	" -f 5 "${FN}")"


   OUT=$(imapsync \
      --host1 "${HOST1}" --user1 "${USER1}" --passfile1 "${PW_FILE1}" \
      --host2 localhost --user2 "${USER2}" --passfile2 "${PW_FILE2}" --nossl2 --notls2 \
      --pidfilelocking \
      2>&1 \
   )

    if [ $? -ne 0 ]
    then
       echo "${OUT}"
    fi
done < <(find /home/imapsync/imapsync_tasks -name "*.conf")
