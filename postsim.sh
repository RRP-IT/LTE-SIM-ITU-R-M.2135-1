#!/bin/bash


#set -e 
set -x


# PARAMETERS
RUN="./Two-Slope"
SCENARIO="SingleCellWithI"
AVG="TOOLS/make_avg"
TPUT="TOOLS/make_goodput"
PLR="TOOLS/make_plr"


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

TIME=46;

seedI=1
seedF=100

IDUE=$nbCells;

until [ $seedI -gt $seedF ]
do


for radius in   0.2
   do


for nbUE in 1 2 3 4
    do
    	

      echo "POST SIM FOR ${SCENARIO} ${nbCells} ${radius} ${nbUE} ${nbVoIP} ${nbVideo} ${nbBE} ${nbCBR} ${sched_type} ${frame_struct} ${speed} ${maxDelay} ${videoBitRate} ${seedI}"
      
      FILE_IN="TRACE/nbCells_${nbCells}_radius_${radius}_nbUE_${nbUE}_sched_type_${sched_type}_Freq_${Freq_escrita}_seed_${seedI}"


      # Cell
      TPUT_CELL_AGGREGATE_VIDEO="OUTPUT/TPUT_CELL_VIDEO_nbCells_${nbCells}_radius_${radius}_nbUE_${nbUE}_sched_type_${sched_type}_Freq_${Freq_escrita}" 
      DELAY_CELL_AGGREGATE_VIDEO="OUTPUT/DELAY_CELL_VIDEO_nbCells_${nbCells}_radius_${radius}_nbUE_${nbUE}_sched_type_${sched_type}_Freq_${Freq_escrita}"
      TPLR_CELL_AGGREGATE_VIDEO="OUTPUT/TPLR_CELL_VIDEO_nbCells_${nbCells}_radius_${radius}_nbUE_${nbUE}_sched_type_${sched_type}_Freq_${Freq_escrita}"
    
      # User
      TPUT_USER_VIDEO="OUTPUT/TPUT_USER_VIDEO_nbCells_${nbCells}_radius_${radius}_nbUE_${nbUE}_sched_type_${sched_type}_Freq_${Freq_escrita}"
      DELAY_USER_VIDEO="OUTPUT/DELAY_USER_VIDEO_nbCells_${nbCells}_radius_${radius}_nbUE_${nbUE}_sched_type_${sched_type}_Freq_${Freq_escrita}"
      PLR_USER_VIDEO="OUTPUT/PLR_USER_VIDEO_nbCells_${nbCells}_radius_${radius}_nbUE_${nbUE}_sched_type_${sched_type}_Freq_${Freq_escrita}"

      IDUE=$nbCells;
      MAXIDUE=$(($IDUE+$nbUE-1));

      if [ -f ${FILE_IN}.gz ]
      then

        cd  TRACE; unp nbCells_${nbCells}_radius_${radius}_nbUE_${nbUE}_sched_type_${sched_type}_Freq_${Freq_escrita}_seed_${seedI}.gz; cd ..
        n=$(grep -c "SIMULATOR_DEBUG:" ${FILE_IN})
        
        if [ "$n" = "0" ]
        then

          echo "$FILE_IN" >> simulate_again
        
        else

          until [ $IDUE -gt $MAXIDUE ]
          do

            rx=$(grep -c "id $IDUE position" ${FILE_IN})
            # Original abaixo
            #rx=$(grep -c "^UE $IDUE position" ${FILE_IN})

            if [ "$rx" = "0" ]
            then

              echo "USER NOT FOUND"
              IDUE=$(($IDUE+$nbUE))
              #IDUE=$(($IDUE+1))

            else

              for i in $(seq ${IDUE} $MAXIDUE)
              do

                #Método How To Tools
                grep " DST $i D" $FILE_IN | grep  "RX" | awk '{print $8}' > tmp_rx_user_VIDEO 
                cat tmp_rx_user_VIDEO >> tmp_rx_cell_VIDEO 
               # ./TOOLS/make_goodput  tmp_rx_user_VIDEO  ${TIME} >> $TPUT_USER_VIDEO
                rm tmp_rx_user_VIDEO

                # Método do_simulations
                grep " DST $i D" $FILE_IN | grep "RX" | awk '{print $14}'  > tmp_delay_user_VIDEO 
                #./compute_delay.sh tmp_delay_user_VIDEO   >> $DELAY_USER_VIDEO
                cat tmp_delay_user_VIDEO >> tmp_delay_cell_VIDEO
                rm tmp_delay_user_VIDEO

                #Método do_simulations
                grep " DST $i D" $FILE_IN | grep "RX" | awk '{print $1}' > tmp_plr_user_VIDEO 
                grep " DST $i T" $FILE_IN | grep "TX" | awk '{print $1}' >> tmp_plr_user_VIDEO 
                #./compute_plr.sh tmp_plr_user_VIDEO  >> $PLR_USER_VIDEO
                cat tmp_plr_user_VIDEO >> tmp_plr_cell_VIDEO
                rm tmp_plr_user_VIDEO

              done
              IDUE=$(($IDUE+$nbUE))
              #IDUE=$MAXIDUE

            fi

          done

            #Método How To Tools
            ./TOOLS/make_goodput  tmp_rx_cell_VIDEO  ${TIME} >> $TPUT_CELL_AGGREGATE_VIDEO
            rm tmp_rx_cell_VIDEO 

            ./compute_delay.sh tmp_delay_cell_VIDEO   >> $DELAY_CELL_AGGREGATE_VIDEO
            rm tmp_delay_cell_VIDEO 

            #Método do_simulations
            ./compute_plr.sh tmp_plr_cell_VIDEO  >> $TPLR_CELL_AGGREGATE_VIDEO
            rm tmp_plr_cell_VIDEO 

        fi

        rm ${FILE_IN}

      fi

    done

  done

  seedI=$(($seedI+1))

done

echo SIMULATION FINISHED!
