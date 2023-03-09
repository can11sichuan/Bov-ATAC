#!/usr/bin/env python
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pybedtools
import metaseq
import logging
import numpy as np
import sys
index=sys.argv[1]
bed_TSS=sys.argv[2]
Schr=sys.argv[3]
len_read=sys.argv[4]
def make_tss_plot(bam_file, tss, prefix, chromsizes, read_len, bins=400, bp_edge=2000,processes=8, greenleaf_norm=True):
	tss_plot_file = '{0}.tss_enrich.png'.format(prefix)
	tss_plot_large_file = '{0}.large_tss_enrich.png'.format(prefix)
	tss_log_file = '{0}.tss_enrich.qc'.format(prefix)
	tss = pybedtools.BedTool(tss)
	tss_ext = tss.slop(b=bp_edge, g=chromsizes)
	bam = metaseq.genomic_signal(bam_file, 'bam')
	bam_array = bam.array(tss_ext, bins=bins, shift_width = -read_len/2,processes=processes, stranded=True)
	if greenleaf_norm:
		num_edge_bins = int(100/(2*bp_edge/bins))
		bin_means = bam_array.mean(axis=0)
		avg_noise = (sum(bin_means[:num_edge_bins]) +
		sum(bin_means[-num_edge_bins:]))/(2*num_edge_bins)
		bam_array /= avg_noise
	else:
		bam_array /= bam.mapped_read_count() / 1e6
	fig = plt.figure()
	ax = fig.add_subplot(111)
	x = np.linspace(-bp_edge, bp_edge, bins)
	ax.plot(x, bam_array.mean(axis=0), color='r', label='Mean')
	ax.axvline(0, linestyle=':', color='k')
	tss_point_val = max(bam_array.mean(axis=0))
	with open(tss_log_file, 'w') as fp:
		fp.write(str(i)+"\t"+str(tss_point_val))
		ax.set_xlabel('Distance from TSS (bp)')
	if greenleaf_norm:
		ax.set_ylabel('TSS Enrichment')
	else:
		ax.set_ylabel('Average read coverage (per million mapped reads)')
	ax.legend(loc='best')
	fig.savefig(tss_plot_file)
	upper_prct = 99
	if np.percentile(bam_array.ravel(), upper_prct) == 0.0:
		upper_prct = 100.0
	plt.rcParams['font.size'] = 8
	fig = metaseq.plotutils.imshow(bam_array,x=x,figsize=(5, 10),vmin=5, vmax=upper_prct, percentile=True,line_kwargs=dict(color='k', label='All'),fill_kwargs=dict(color='k', alpha=0.3),sort_by=bam_array.mean(axis=1))
	fig.savefig(tss_plot_large_file)
	plt.close(fig)
	return tss_plot_file, tss_plot_large_file, tss_log_file

with open(index) as f:
	lines=f.readlines()
Nfiles=len(lines)
for i in range(1,Nfiles):
	line=lines[i]
	line_new=line.split()[1]+".bam"
	make_tss_plot(line_new,bed_TSS,line.split()[1],Schr, len_read, bins=400, bp_edge=2000,processes=10, greenleaf_norm=True)

