df_sim<-NULL
df_sim<-as.data.frame(df_sim)

simulate_fa<-function(tru=0.65,pa=0.1){
	pa=0.1  ###now we assume one value for ATAC-seq
	vec<-sample(1:100,6000,replace=T)  ###generate the length of each credible sets
	
	###below we generate fa with true
	for (index in 1:(6000*tru)){
		#confounding <- round((vec[index]-1)*pa) # 
		confounding <- rbinom(n=1,size=(vec[index]-1),p=pa)
		df_sim[index,1]<-confounding+1
		df_sim[index,2]<-vec[index]-df_sim[index,1]
		df_sim[index,3]<-vec[index]
	}
	
	#below we generate overlapping that is random
	
	for(index in (6000*tru+1):6000){
		#df_sim[index,1]<-round(vec[index]*pa)
		df_sim[index,1]<-rbinom(n=1,size=(vec[index]-1),p=pa)
		df_sim[index,2]<-vec[index]-df_sim[index,1]
		df_sim[index,3]<-vec[index]
	}
	
	colnames(df_sim)<-c("overlap","non_overlap","total")
	df_sim
}
