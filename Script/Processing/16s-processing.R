
library("knitr")
library("BiocStyle")
library("ggplot2")
library("gridExtra")
library("dada2")
library("DECIPHER")
library("phangorn")

set.seed(100)

#1. Filter and trim: `filterAndTrim()`
#2. Dereplicate: `derepFastq()`
#3. Learn error rates: `learnErrors()`
#4. Infer sample composition: `dada()`
#5. Merge paired reads: `mergePairs()`
#6. Make sequence table: `makeSequenceTable()`
#7. Remove chimeras: `removeBimeraDenovo()`
#8. Assign taxonomy
#9. Construct phylogenetic tree


# Filter and Trim

library(dada2); packageVersion("dada2")
fnF1 <- system.file("extdata", "sam1F.fastq.gz", package="dada2")
fnR1 <- system.file("extdata", "sam1R.fastq.gz", package="dada2")
filtF1 <- tempfile(fileext=".fastq.gz")
filtR1 <- tempfile(fileext=".fastq.gz")
```

plotQualityProfile(fnF1) # Forward
plotQualityProfile(fnR1) # Reverse
```

filterAndTrim(fwd=fnF1, filt=filtF1, rev=fnR1, filt.rev=filtR1,
                  trimLeft=10, truncLen=c(240, 200), 
                  maxN=0, maxEE=2,
                  compress=TRUE, verbose=TRUE)
```

# Dereplicate

derepF1 <- derepFastq(filtF1, verbose=TRUE)
derepR1 <- derepFastq(filtR1, verbose=TRUE)
```

# Learn the error rates

errF <- learnErrors(derepF1, multithread=FALSE) # multithreading is available on many functions
errR <- learnErrors(derepR1, multithread=FALSE)
```

# Infer sample composition <a id="sec:dada"></a>

dadaF1 <- dada(derepF1, err=errF, multithread=FALSE)
dadaR1 <- dada(derepR1, err=errR, multithread=FALSE)
print(dadaF1)
```

# Merge forward/reverse reads

merger1 <- mergePairs(dadaF1, derepF1, dadaR1, derepR1, verbose=TRUE)
```

# Remove chimeras <a id="sec:chimeras"></a>

merger1.nochim <- removeBimeraDenovo(merger1, multithread=FALSE, verbose=TRUE)
```

##Track reads through the pipeline

getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), rowSums(seqtabNoC))

colnames(track) <- c("input", "filtered", "denoised", "nonchim")
head(track)


# Assign taxonomy 

fastaRef <- "silva_nr_v132_train_set.fa.gz" 
taxTab <- assignTaxonomy(seqtabNoC, refFasta = fastaRef, multithread=TRUE)
taxTab <- addSpecies(taxTab, "silva_species_assignment_v132.fa.gz")


# Construct phylogenetic tree 

seqs <- getSequences(seqtabNoC)
names(seqs) <- seqs 
alignment <- AlignSeqs(DNAStringSet(seqs), anchor=NA,verbose=FALSE)

#The phangorn R package is then used to construct a phylogenetic tree:
phangAlign <- phyDat(as(alignment, "matrix"), type="DNA")
dm <- dist.ml(phangAlign)
treeNJ <- NJ(dm)
fit = pml(treeNJ, data=phangAlign)
fitGTR <- update(fit, k=4, inv=0.2)
fitGTR <- optim.pml(fitGTR, model="GTR", optInv=TRUE, optGamma=TRUE, rearrangement = "stochastic", control = pml.control(trace = 0))  #out of memory on local PC!

detach("package:phangorn", unload=TRUE)


