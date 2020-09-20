#!/bin/bash


set -e 
set -x

# PARAMETERS
RUN="./Two-Slope"
SCENARIO="SingleCellWithI"



nbCells=19
nbVoIP=0 
nbVideo=1
nbBE=0
nbCBR=0
sched_type=1
#schd_type: 1-> PF, 2-> M-LWDF, 3-> EXP, 4-> FLS, 5 -> Optimize EXP Rule, 6 -> Optimized LOG Rule
frame_struct=1
#frame_struct: 1-> FDD, 2-> TDD
speed=3
#accessPolicy=0
#accessPolicy : 0 -> Open Access, 1 -> close Access (requires subscriber list filling)
maxDelay=0.1
videoBitRate=242
Freq_escrita=26
seed=0


seedF=100
seedI=1

until [ $seedI -gt $seedF ]; do



  #for radius in 0.015 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.2 0.25 0.3 0.35 0.4
for radius in  0.2
   do

    #for nbUE in 12 14 16 18 20
for nbUE in 1 2 3 4
    do
    	
      trace="TRACE/nbCells_${nbCells}_radius_${radius}_nbUE_${nbUE}_sched_type_${sched_type}_Freq_${Freq_escrita}_seed_${seedI}"
      $RUN ${SCENARIO} ${nbCells} ${radius} ${nbUE} ${nbVoIP} ${nbVideo} ${nbBE} ${nbCBR} ${sched_type} ${frame_struct} ${speed} ${maxDelay} ${videoBitRate} > ${trace}
      gzip $trace

    done

  done

seedI=$(($seedI + 1))
done
./postsim.sh
echo SIMULATION FINISHED!


