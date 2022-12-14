filter.clonotypes <- function(tcr_location, prefix, VDJinfo = c("TRA", "TRB", "TRB"), reversing=F, isotype="c_gene"){
#prefix = "old1798_" 
#VDJinfo = c("IGH", "IGK", "IGL")
#reversing=T
    # Change for repo data of CD8 TIL matched sample:
    #VDJ <- read.csv(paste(tcr_location,"filtered_contig_annotations.csv", sep=""))
    VDJ <- read.csv(tcr_location)
    
    
    VDJ$barcode <- gsub("-1", "", VDJ$barcode)
    #VDJ$barcode <- paste0(prefix, VDJ$barcode)
    # Filter cells to only have cells that have two transcripts:
    VDJ <- VDJ[,c("barcode", "v_gene", "j_gene", "cdr3","raw_clonotype_id", "chain", "c_gene")]
    VDJ <- VDJ[VDJ[,4] != "None",]
    VDJ <- VDJ[!duplicated(VDJ),]
    VDJ <- VDJ[order(VDJ$barcode),]
    
    print(length(unique(VDJ$barcode)))
    # Keep only cells that have one heavy and one light chain:
    triplicated_cells <- VDJ$barcode[triplicated(VDJ$barcode)]
    VDJ_filtered <- VDJ[!VDJ$barcode %in% triplicated_cells,]
    double_barcodes <- VDJ_filtered$barcode[duplicated(VDJ_filtered$barcode)]
    VDJ_filtered <- VDJ_filtered[VDJ_filtered$barcode %in% double_barcodes,]
    VDJ_filtered <- VDJ_filtered[!VDJ_filtered$chain == "Multi",]
    # Subset alpha and beta chains:
    VDJ_filt.A <- VDJ_filtered[VDJ_filtered$chain == VDJinfo[1],]
    VDJ_filt.B <- VDJ_filtered[VDJ_filtered$chain == VDJinfo[2]|VDJ_filtered$chain == VDJinfo[3],]
    # Make sure every barcode appears exactly once in each subset:
    VDJ_filt.A <- VDJ_filt.A[!VDJ_filt.A$barcode %in% VDJ_filt.A$barcode[duplicated(VDJ_filt.A$barcode)],]
    VDJ_filt.B <- VDJ_filt.B[!VDJ_filt.B$barcode %in% VDJ_filt.B$barcode[duplicated(VDJ_filt.B$barcode)],]

    VDJ_filt.B <- VDJ_filt.B[VDJ_filt.B[order(VDJ_filt.B$barcode),1] %in% VDJ_filt.A[order(VDJ_filt.A$barcode),1],]
    VDJ_filt.A <- VDJ_filt.A[VDJ_filt.A[order(VDJ_filt.A$barcode),1] %in% VDJ_filt.B[order(VDJ_filt.B$barcode),1],]
 
    print(sum(VDJ_filt.A$barcode != VDJ_filt.B$barcode))
    print(nrow(VDJ_filt.A))
    
    # Merge dataframes:
    if(reversing == TRUE){
        names(VDJ_filt.B)[c(2,3,4)] <- c("v_gene_b", "j_gene_b", "cdr3_b")
        names(VDJ_filt.A)[c(2,3,4)] <- c("v_gene_a", "j_gene_a", "cdr3_a")
        VDJ_filt.A$v_gene_b <- VDJ_filt.B$v_gene_b
        VDJ_filt.A$j_gene_b <- VDJ_filt.B$j_gene_b
        VDJ_filt.A$cdr3_b <- VDJ_filt.B$cdr3_b
        # Add CDR3b length column:
        VDJ_filt.A[] <- lapply(VDJ_filt.A, as.character)
        VDJ_filt.A$cdr3_b_length <- nchar(VDJ_filt.A$cdr3_b)
        VDJ_filt.A$cdr3_a_length <- nchar(VDJ_filt.A$cdr3_a)
    }else{
        names(VDJ_filt.B)[c(2,3,4)] <- c("v_gene_a", "j_gene_a", "cdr3_a")
        names(VDJ_filt.A)[c(2,3,4)] <- c("v_gene_b", "j_gene_b", "cdr3_b")
        VDJ_filt.A$v_gene_a <- VDJ_filt.B$v_gene_a
        VDJ_filt.A$j_gene_a <- VDJ_filt.B$j_gene_a
        VDJ_filt.A$cdr3_a <- VDJ_filt.B$cdr3_a
        # Add CDR3b length column:
        VDJ_filt.A[] <- lapply(VDJ_filt.A, as.character)
        VDJ_filt.A$cdr3_b_length <- nchar(VDJ_filt.A$cdr3_b)
        VDJ_filt.A$cdr3_a_length <- nchar(VDJ_filt.A$cdr3_a)
    }
    
    return(VDJ_filt.A)
}
