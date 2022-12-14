clonotype.def <- function(data, whichColumn=2){
  #data <- old5921798_TCR
    ############
  # whichcolumn: 2 = BCR; 6 = TCR
    nested_expanded_clonotypes <- 
  data %>% 
  dplyr::group_by(v_gene_a, j_gene_a, v_gene_b, j_gene_b, cdr3_b_length, cdr3_a_length) %>% 
  nest(.key = "barcode")
  # Extract clonotype sizes and add as column:
  nested_expanded_clonotypes$clonotype_size <- unlist(lapply(nested_expanded_clonotypes$barcode, nrow))
  # Order dataframe by clonotype size:
  nested_expanded_clonotypes <- nested_expanded_clonotypes[order(nested_expanded_clonotypes$clonotype_size, decreasing = T),]
  # Add new clonotype names as column:
  nested_expanded_clonotypes$clonotype_new <- paste("clonotype", seq(1:nrow(nested_expanded_clonotypes)), sep='')
  ############
  # Calculate levenshtein distance between cdr3_b as 80% similarity
  for(i in which(nested_expanded_clonotypes$clonotype_size>1)){
    lv_dist <- round(as.data.frame(nested_expanded_clonotypes)[i,5]*.2)
    cdr3_b <- as.data.frame(nested_expanded_clonotypes$barcode[[i]])[,c(whichColumn)]
    if(length(unique(cdr3_b)) > 1){
      cdr3_b_lv.dist.mat <- stringdist::stringdistmatrix(unique(cdr3_b),
                                                   unique(cdr3_b),
                                                     useNames = "strings", method = 'lv')
      # in row are the aminos with a Levenshtein distance of 1 to at least one another amino
      cdr3_b_lv.dist.mat <- cdr3_b_lv.dist.mat[rowSums(sapply(as.data.frame(cdr3_b_lv.dist.mat), '%in%', seq(1:lv_dist))) > 0, ]
      # we can filter the relevant columns
      cdr3_b_lv.dist.mat <- cdr3_b_lv.dist.mat[, colnames(cdr3_b_lv.dist.mat) %in% rownames(cdr3_b_lv.dist.mat)]
      # values not equal to 1 do not represent a connection. Let's set them to zero
      cdr3_b_lv.dist.mat[!cdr3_b_lv.dist.mat %in% seq(1:lv_dist)] <- 0
      # If no connected CDR3beta, name the biggest clone as true clone
      if(dim(cdr3_b_lv.dist.mat)[1] == 0){
        nested_expanded_clonotypes$barcode[[i]]$same_clone <- cdr3_b %in% names(sort(table(nested_expanded_clonotypes$barcode[[i]]$cdr3_b), decreasing=T)[1])
      }else{
        # Add same clonotype boolean as column:
        nested_expanded_clonotypes$barcode[[i]]$same_clone <- cdr3_b %in% rownames(cdr3_b_lv.dist.mat)
      }
      

    }else{
      # Add same clonotype boolean as column:
      nested_expanded_clonotypes$barcode[[i]]$same_clone <- cdr3_b %in% names(sort(table(nested_expanded_clonotypes$barcode[[i]]$cdr3_b), decreasing=T)[1])
    }
    
  }
  ############
  # Unnest data frame:
  unnested_expanded_clonotypes <- unnest(nested_expanded_clonotypes, cols = barcode)
  
  return(unnested_expanded_clonotypes)
}
