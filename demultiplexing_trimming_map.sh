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

## convert sam to bam
# minimap fails to add headers to sam in case of a multipart fasta, hence the sam to bam script needs to be modified
for file in BC*.sam
do
n=${file%.*sam}
samtools view -b -T /shared3/Anubhab/Tsetse_flies/ref_dir/genome_subset/merged_ref.fasta ${n}.sam | samtools sort -o sorted_${n}.bam & 
done

## index
for file in sorted_*.bam
do
samtools index -b ${file} &
done

#### STEP 5 : split reads species wise
for file in sorted_*.bam
do n=${file%.*bam}
samtools view -b ${n}.bam Lox_africana* > ${n}_Lox_africana.bam
samtools view -b ${n}.bam Glo_pallidipes* > ${n}_Glo_pallidipes.bam
samtools view -b ${n}.bam Syn_caffer* > ${n}_Syn_caffer.bam
done



