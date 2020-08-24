
###biclustering using BackSPIN: https://github.com/linnarsson-lab/BackSPIN
backspin -i Input -o oligos_clustered.cef -f 500 -v -d 4

###xcell: https://xcell.ucsf.edu/
Input data: The expression matrix (normalized to gene length: RPKM/FPKM/TPM/RSEM) should be a matrix with genes in rows and samples in columns


###Cox regression model

#making formulas
univ_formulas <- sapply(colnames(data),function(x)as.formula(paste('Surv(futime,death)~',x)))

#making a list of models
univ_models <- lapply(univ_formulas, function(x){coxph(x,data=data)})

#extract data
univ_results <- lapply(univ_models,function(x){return(exp(cbind(coef(x),confint(x))))})

#select p<0.05 microbe list, and build a model

model <- coxph(Surv(time, status) ~ Microbes, data = data)
model

#cutoff
cutoff<- median(predict(model, data))

#cox model in validation dataset
fitted.results <- predict(model, validation)
fit <- ifelse(fitted.results > cutoff,2, 1)




