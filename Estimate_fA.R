source("Simulate_fA.R")
lik_credset3 <- function(tau,freq_atac,credset){
  loglik=0
  pa=freq_atac
  fA=exp(tau)/(1+exp(tau))
  for (i in 1:nrow(credset)){
    n1=credset[i,1]
    n2=credset[i,2]
    nt=credset[i,3]
    if(credset[i,1]==0){
        part1 <- 0
        part2 <- (1-fA)*(1-pa)^(nt-1)
   }else if(credset[i,2]==0){
        part2 <- 0
        part1 <- fA*pa^(n1-1)
   }else{
    part1 <- fA*(1-pa)/(nt-n1)
    part2 <- (1-fA)*pa/n1
}

    lik=part1+part2
    loglik=loglik+log(lik)
  }
  return(-loglik)
}

mypar=0.2 ##initial value
tau=log(mypar/(1-mypar)) ##define tau to constrain estimator
res2 <- nlm(f=lik_credset3,p=tau,freq_atac,credset) ##freq_atac is the precentage of ATAC in genome; credset stands for dataframe of credible set.
est2 <- exp(res2$estimate)/(1+exp(res2$estimate))
