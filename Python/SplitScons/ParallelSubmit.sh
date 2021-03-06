#!/bin/bash

# Smart submission - submit jobs in parallel, based on cluster utilization
# Philip Brodrick (brodrick)
# 12/19/2014
# Modified by Lewis Li 2/28/2015

#######################  User Inputs #########################
 ## maximum fraction of cluster your jobs occupy
my_max_frac=.27

## maximum fraction of cluster total occupied
total_max_frac=.95

## maximum jobs allowed to stack in que (safety only)
my_max_que=20

## number of jobs in que (keep constant)
total_que=944

## file to read jobs to submit from
list_file=$1
echo "Reading from ${list_file}"

## file to write running output to
report_file=OutputLog.txt

## jobs to submit at a time
num_to_submit=2

# store job ids
job_list=$2
##############################################################

## record date
date >> ${report_file}

# get user
user=`id | awk '{print $1}' | awk -F "[()]" '{print $2}'`

## initialize outer counter
outer_count=0
IFS=$'\n'
for next in `cat ${list_file}`
do
  # always submit in groups of num_to_submit
  if [ ${outer_count} -gt ${num_to_submit} ]
  then 
    outer_count=0
    count=0

    # check to see if jobs are finished
    while [ ${count} -lt 2 ]
    do
      # get running jobs
      my_run=$(showuserjobs | grep ${user} | awk '{print $3}')
      my_que=$(showuserjobs | grep ${user} | awk '{print $5}')
      if [ "${my_run}" = "" ]
      then
        my_run=0
      fi
      my_frac=$(echo "scale=5; ${my_run} / ${total_que}" | bc)

     # get total jobs
      total_run=$(showuserjobs | grep TOTAL | awk '{print $3}')
      if [ "${total_run}" = "" ]
      then
        total_run=0
      fi
      total_frac=$(echo "scale=5; ${total_run} / ${total_que}" | bc)

      # calcluate fraction of cluster being used - make sure
      # user usage and total usage are below specified thresholds
      echo "my_frac: ${my_frac}, total_frac: ${total_frac}, my_que: ${my_que}"
      if (( $(echo "${my_frac} < ${my_max_frac}" | bc -l) ))
      then
        if (( $(echo "${total_frac} < ${total_max_frac}" | bc -l) ))
        then
          if (( $(echo "${my_que} < ${my_max_que}" | bc -l) ))
          then
            count=$(echo "scale=3; ${count} + 1" | bc)
            echo "looks ready to submit.  count: ${count}"
          fi
        fi
      fi

      sleep 4s
    done
  fi 

  # submit job, and write submission to file for reference
  if [ ${outer_count} -eq 1 ]
  then
    echo "submitting next ${num_to_submit}"
  fi
  echo "${next}" >> ${report_file}
  qsub ${nexti} >> ${job_list} 
  outer_count=$(echo "scale=3; ${outer_count} + 1" | bc)

done

date >> ${report_file}
    

