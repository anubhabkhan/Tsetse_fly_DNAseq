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

#### STEP 4: Mapping with minimap2

## for mapping to multiple references
#Edit headers in references for example

less Lox_afr.fna | sed 's/>/>Lox_afr/g' > Lox_afr_edit.fna

#concatenate header edited references with:

cat *.fna >> merged_references.fasta

## map wiht minnimap2
for file in BC*_porechopped.fastq
do 
n=${file%.*fastq}
minimap2 -a /shared3/Anubhab/Tsetse_flies/ref_dir/genome_subset/merged_ref.fasta ${n}.fastq > ${n}.sam
done


