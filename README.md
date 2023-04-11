# Bov-ATAC
## ATAC-seq peak calling, we follow [Encode](https://www.encodeproject.org/data-standards/atac-seq/atac-encode4/)  
1. FRip score, TSS enrichment and Rescue Ratio are used to eliminate the lower quality data
2. Peak called using Macs2
## To generate and annotate the peak we borrow the idea developed by [Meuleman](https://github.com/Altius/)  
1. We perform peak calling for each sample and then use FWHM method to obtain consensus  
2. To infer the the biological meaning, we decompose consensus by sample matrix into basis making it is interpretable  
## In cis-eQTL analysis, we follow [GTEX](https://gtexportal.org/home/methods)  
1. we correct hidden factor by PEER
2. cis-eQTL are detected using QTLtools
## Enrichment analysis, we using [goshifter](https://github.com/immunogenomics/goshifter) developed by Trynka 
## Estimation of fa
By combining eQTL and ATAC-Seq, we estimate proportion of regulatory variants mapping to ATAC-Seq based on Maximum Likelihood  
## Data availability  
Please check on UCSC genome brower [ATAC-seq-UCSC](https://www.gigauag.uliege.be/cms/c_4791343/en/gigauag-diagnostics-software-data)  
