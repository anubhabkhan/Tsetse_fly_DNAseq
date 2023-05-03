#### We use porechop_abi (https://github.com/bonsai-team/Porechop_ABI#quick-usage)
#### STEP 1: concatenate fastq
for file in *.fastq.gz
do
less ${file} >> concatenate.fastq
done


#### STEP 2: demultiplexing
mkdir porechop_trimmed

porechop_abi -i concatenated.fastq -b porechop_trimmed

#### STEP 3: trimming

cd porechop_trimmed

for file in BC*.fastq
do
n=${file%.*fastq}
porechop_abi -abi -i ${n}.fastq -o ${n}_porechopped.fastq 
done
