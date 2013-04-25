#!/bin/bash


echo " this is a Protocol for Glass Transition Temperature "
PNUM=8
EXEC=lmp_g++
Thigh=600
Tlow=550
Tinterval=50
echo " now you are running ${EXEC}@${PNUM}-cpus [${Thigh}:${Tlow}] cooling by $Tinterval each step."

for i in `echo minimization nvthightemp deformation annealing`; do 
	#echo "$i.in"
	echo " running $i now..." 
	#mpirun -np ${PNUM} ${EXEC} < $i.in 
	echo " $i ended."
done

if [ -f volume-temp.dat ]; then
	rm volume-temp.dat
fi
touch volume-temp.dat
echo " [ volume-temp.dat ] created for recording volume temperature"

for ((i=${Thigh};i>=${Tlow};i=$i-${Tinterval})); do 
	#### nvt @ this temperature ####
	echo " running NVT:T=$i now ..." 
	let lastT=$i+${Tinterval}
	let nextT=$i-${Tinterval}
	echo " # <- temporarily created for glass-T routine ->" > nvttemperature.in
	if [ $i -eq ${Thigh} ];then
		echo " loading .in from restart.annealing.dat ... "
		echo " variable fname index annealing" >> nvttemperature.in
	else
		echo " loading .in from restart.nvtlowtemp.${lastT}.log ... "
		echo " variable fname index nvtlowtemp.$lastT" >> nvttemperature.in
	fi	
	echo " variable simname index nvttemp.$i" >> nvttemperature.in
	echo " variable Htemperature index $i" >> nvttemperature.in
	echo " variable Ltemperature index $i" >> nvttemperature.in
	cp nvtlowtemp.in nvttemp.$i.in
	echo " nvttemp.$i.in created:"
	echo " ----------------------------------"
	#cat nvttemperature.in
	echo " ----------------------------------"
	#mpirun -np ${PNUM} ${EXEC} < nvttemp.$i.in 
	echo " NVT:T=$i ended successfully."
	echo " "
	#### npt @ this temperature ####
	echo " running NPT:T=$i now ..." 
	echo " # <- temporarily created for glass-T routine ->" > npttemperature.in
	echo " loading .in from restart.nvttemp.$i.dat ... "
	echo " variable fname index nvttemp.$i" >> npttemperature.in
	echo " variable simname index npt2zero.$i" >> npttemperature.in
	echo " variable temperature index $i" >> npttemperature.in
	cp npt2zero.in npt2zero.$i.in
	echo " npt2zero.$i.in created:"
	echo " ----------------------------------"
	#cat npttemperature.in
	echo " ----------------------------------"
	#mpirun -np ${PNUM} ${EXEC} < npt2zero.$i.in  
	echo " ouput volume - temperature ... "
	cp npt2zero.$i.vol.dat npt2zero.vol.dat
	python < avevol.py
	cp volume.dat volume.$i.dat
	cat volume.$i.dat >> volume-temp.dat
	echo " NPT:T=$i ended successfully."
	echo " "
	#### lower the temperature ####
	if [ $i -eq ${Tlow} ]; then
		echo " complete."
	else
		echo " # <- temporarily created for glass-T routine ->" > nvttemperature.in
		echo " loading .in from restart.npt2zero.$i.dat ... "
		echo " variable fname index npt2zero.$i" >> nvttemperature.in
		echo " variable simname index nvtlowtemp.$i" >> nvttemperature.in
		echo " variable Htemperature index $i" >> nvttemperature.in
		echo " variable Ltemperature index $nextT" >> nvttemperature.in
		cp nvtlowtemp.in nvtlowtemp.$i.in
		echo " nvtlowtemp.$i.in created:"
		echo " ----------------------------------"
		#cat nvttemperature.in
		echo " ----------------------------------"
		#mpirun -np ${PNUM} ${EXEC} < nvtlowtemp.$i.in 
		echo " NVT:[T=${i}->T=${nextT}] ended successfully."
		echo " "
	fi
done

echo "inp='volume-temp.dat'" > tempdata.gpl
echo "out='Volume-Temp'" >> tempdata.gpl
echo "colx=1" >> tempdata.gpl
echo "coly=2" >> tempdata.gpl
echo "xlabeltext='Temperature'" >> tempdata.gpl
echo "ylabeltext='Volume'" >> tempdata.gpl
gnuplot draw_data.gpl
echo " check out your [ Volume-Temp.eps ] :)"

exit 0 
