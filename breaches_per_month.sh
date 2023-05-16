#!/bin/bash

if [[ -z $1 ]]
then 
	1>&2 echo "Filename is missing, check inputs"
	exit 2

elif [[ ! -f $1 ]] # check if the file exists in the directory given
then
    1>&2 echo "The tsv/csv file is not found, check inputs"
    exit 1

elif [[ $# -ne 1 ]] # check if exactly 1 input given
then
	1>&2 echo "Please only input 1 arguments"
	exit 1

else
	file=$1

	# take in the relevant columns from the file, discard the headers
	months=$(awk -F "\t" '{print $6}' $file)
	sorted_months=$(echo "$months" | tail -n+2 | sort -n | uniq -c)

	# take the months with counts, sort for median and MAD calculations
	sorted_counts=$(echo "$sorted_months" | awk '{print $1}' | sort -n)
	median=$(echo "$sorted_counts" | awk '{a[NR]=$1}
	END {if (NR % 2) 
		{print a[(NR+1)/2]} 
		else 
		{print (a[NR/2] + a[NR/2+1])/2}}')
	med_dev=$(echo "$sorted_months" | awk -v med=$median '{print sqrt(($1-med)^2)}' | sort -n)
	mad=$(echo "$med_dev" | awk '{a[NR]=$1}
	END {if (NR % 2) 
		{print a[(NR+1)/2]} 
		else 
		{print (a[NR/2] + a[NR/2+1])/2}}')
	echo "Median=$median, MAD=$mad"
fi
