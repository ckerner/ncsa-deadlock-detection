#!/bin/ksh
#=========================================================================================#
# ncsa_deadlock_detection.sh - Detect deadlock conditions and notify admin list before    #
#                              things get out of hand(hopefully).                         #
#=========================================================================================#
#                                                                                         #
# To run synchronously:                                                                   #
#    mmaddcallback ddcallback --event deadlockDetected --sync --command \                 #
#    /var/mmfs/etc/ncsa_deadlock_detection.sh --parms "%eventName %myNode %waiterLength"  #
#                                                                                         #
#       When run synchronously, if the exit code of the script is 1, debug data           #
#       will not be collected automatically for the event.                                #
#                                                                                         #
#       IMPORTANT:                                                                        #
#       The GPFS daemon will wait until this script returns when it is run                #
#       synchronously. Invoking complex or long-running commands, or commands             #
#       that involve GPFS files, may cause unexpected and undesired results,              #
#       including loss of file system availability.                                       #
#                                                                                         #
# To run asynchronously:                                                                  #
#    mmaddcallback ddcallback --event deadlockDetected --command \                        #
#    /var/mmfs/etc/ncsa_deadlock_detection.sh --parms "%eventName %myNode %waiterLength"  #
#                                                                                         #
#       When run asynchronously, the exit code of the script will not affect              #
#       the decision on whether to collect debug data for the event or not.               #
#                                                                                         #
#=========================================================================================#

EVENT_NAME=$1
NODE_NAME=$2
LONG_WAITER=$3

EMAIL_NOTIFICATION="root@ccsm.campuscluster.illinois.edu"
DUMPFILE=/var/mmfs/etc/generate_full_dump
DUMP_DIR=/tmp/gpfs.deadlock

MYDATE=`date +"%Y%m%d_%H%M%S"`
LOGFILE=/var/mmfs/tmp/deadlockDetected.${MYDATE}

info="${EVENT_NAME} on ${NODE_NAME} with waiter length exceeding ${LONG_WAITER} seconds"
echo "`date` $info" > ${LOGFILE}

printf "\n\nDeadlocks:\n " >> ${LOGFILE}
/usr/lpp/mmfs/bin/mmdiag --deadlock >> ${LOGFILE}

printf "\n\nWaiters:\n " >> ${LOGFILE}
/usr/lpp/mmfs/bin/mmdiag --waiters  >> ${LOGFILE}

printf "\n\nThreads:\n " >> ${LOGFILE}
/usr/lpp/mmfs/bin/mmdiag --threads  >> ${LOGFILE}

printf "\n\nAll Diagnostic Data:\n " >> ${LOGFILE}
/usr/lpp/mmfs/bin/mmdiag --all  >> ${LOGFILE}

printf "\n\n" >> ${LOGFILE}
echo `date`  >> ${LOGFILE}

cat ${LOGFILE} | mail -s "$info" ${EMAIL_NOTIFICATION}

if [[ -f ${DUMPFILE} ]] ; then
   /usr/lpp/mmfs/bin/gpfs.snap -d ${DUMP_DIR} -N ${NODE_NAME} --deadlock
   rm -f ${DUMPFILE} &>/dev/null
   exit 1
else
   exit 0
fi
