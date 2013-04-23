#!/usr/bin/python

import sys,os
from operator import itemgetter, attrgetter

print " << avevol.py can be used for aniso- or iso- npt result. >>"
inpfile2="npt2zero.vol.dat"
try:
	inpfp=open(inpfile2, 'r')
	print " loading from [",inpfile2,"]."
except IOError:
	print " ERROR: can not open file: [",inpfile2,"]"
	exit(-1)

listtp=[]
listvo=[]

while True:
	line=inpfp.readline()
	if line:
		elements=line.split()
	else:
		print " end of file, loading over. 1"
		break
	if len(elements)!=0 and elements[0] != "#":
		listtp.append(float(elements[0]))
		listvo.append(float(elements[1]))

inpfp.close()

size=len(listtp)
halfsize=len(listtp)/2

tottp=0.0
totvo=0.0

for i in range(halfsize,size):
	tottp+=listtp[i]
	totvo+=listvo[i]

tottp=tottp/(size-halfsize)
totvo=totvo/(size-halfsize)

outfp2=open("volume.dat", 'w')
print >> outfp2, "%f %f" % (tottp, totvo)
print " [ volume.dat ] created."
outfp2.close()


		