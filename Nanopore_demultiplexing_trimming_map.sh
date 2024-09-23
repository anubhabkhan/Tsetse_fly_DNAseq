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
## create species bed files from merged_references.fasta
python genome_fasta_to_bed.py merged_ref.fasta merged_ref.bed
merged_ref.bed | grep -e "Lox_africana" | awk '{print $1"\t"$(NF-1)"\t"$NF}' > merged_ref_Lox_africana.bed

## Split

for file in sorted_*.bam
do
n=${file%.*bam}
samtools view -b ${n}.bam -L merged_ref_Lox_africana.bed > ${n}_Lox_africana.bam &
samtools view -b ${n}.bam -L merged_ref_Syn_caffer.bed > ${n}_Syn_caffer.bam &
samtools view -b ${n}.bam -L merged_ref_Glo_pallidipes.bed > ${n}_Glo_pallidipes.bam &
done

#### STEP 6: merge reads from different run (optional)
### to be applied when same library is loaded on different flowcells

for file in {01..06}
do
for species in Lox_africana Syn_caffer Glo_pallidipes
do
samtools merge merged_${species}_BC${file}.bam lane1_PATH/sorted_BC${file}_porechopped_${species}.bam lane2_PATH/sorted_BC${file}_${species}.bam lane3_PATH/sorted_BC${file}_${species}.bam lane4_PATH/sorted_BC${file}_${species}.bam
done
done

#### STEP 7: add read group

gatk AddOrReplaceReadGroups I=merged_Lox_africana_BC02.bam O=RG_merged_L_africana_BC02.bam RGID=BC02 RGLB=BC02 RGPU=BC02 RGPL=Nanopore RGSM=BC02




