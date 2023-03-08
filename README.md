# Bov-ATAC
## ATAC-seq peak calling, we follow [Encode](https://www.encodeproject.org/data-standards/atac-seq/atac-encode4/)  
## To generate and annotate the peak we borrow the idea developed by [Meuleman](https://github.com/Altius/)  
1. We perform peak calling for each sample and then use FWHM method to obtain consensus  
2. To infer the the biological meaning, we decompose consensus by sample matrix into basis making it is interpretable  
## In eQTL analysis, we follow [GTEX](https://gtexportal.org/home/methods)  
## Enrichment analysis, we using [goshifter](https://github.com/immunogenomics/goshifter) developed by Trynka 
## Estimation of fa
By combining eQTL and ATAC-Seq, we estimate proportion of regulatory variants mapping to ATAC-Seq based on Maximum Likelihood  
## Data availability  
Please check on UCSC genome brower [ATAC-seq-UCSC](http://genome.ucsc.edu/s/can_sichuan/bosTau9_atac)  
