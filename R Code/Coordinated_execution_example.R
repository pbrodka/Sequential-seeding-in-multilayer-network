library(multinet)
library(stringr)


print(paste("start", Sys.time()))

#network - please modify the line below to have the network for which you would like to generate networks
net <- ml_aucs()
#net <- read_ml("d:/SS4MLN/FullNet/fileName", name="NetworkName", sep=',', aligned=FALSE)

#propagation probabilitiess for independent cascades model - adjust vector to your needs
prop_prob <- c(0.01, 0.02, 0.03, 0.05, 0.10, 0.20, 0.30, 0.40, 0.50)

#for each propagation probability in the vector
for (pp in prop_prob) {
  
  
  #print(paste(pp,Sys.time()))
  
  #do j networks for each propagation probability prop_prob
  for(j in 1:100) {
  
    #copy of oryginal network
    temp_net <- data.frame(from_actor=factor(), from_layer=factor(), to_actor=factor(), to_layer=factor(), dir=numeric())
    
    no_of_edges <- nrow(edges_ml(net))
    
    #for each row in oryginal network
    for (i in 1:no_of_edges){
      
      current_row_flag <- 0
      
      current_row <- data.frame(from_actor=factor(), from_layer=factor(), to_actor=factor(), to_layer=factor(), dir=numeric())
      
      #trow the dice for edge A->B and if result < pp add edge to new network
      if (runif(1)<pp)
      {
        current_row <- edges_ml(net)[i,] #edge access is costly in large network
        current_row_flag <- 1
        
        #change from undirected to directed
        edge <- data.frame(from_actor=current_row[,1], from_layer=current_row[,2], to_actor=current_row[,3], to_layer=current_row[,4], dir=1)
        temp_net <- rbind(temp_net, edge)
      }
      
      #trow the dice for edge B->A and if result < pp add edge to new network
      if (runif(1)<pp)
      {
        if (current_row_flag == 0) #check if we have already accessed the current_row
        {current_row <- edges_ml(net)[i,]}
        
        #change from undirected to directed and sitch to B->A
        edge <- data.frame(from_actor=current_row[,3], from_layer=current_row[,4], to_actor=current_row[,1], to_layer=current_row[,2], dir=1)
        temp_net <- rbind(temp_net, edge)
      }
    }
    
    new_net <- ml_empty()
    add_layers_ml(new_net, layers_ml(net), directed = TRUE)
    add_actors_ml(new_net, actors_ml(net))
    vertices <- data.frame(vertices_ml(net))
    add_vertices_ml(new_net,vertices)
    add_edges_ml(new_net,temp_net)
    
    #save network - change the folder path
    file <- paste("D:/SS4MLN/AUCS/ml_aucs_pp",pp,str_pad(j,3,pad="0"),".mpx", sep = "_")
    write_ml(new_net, file)
  }
  
}
print(paste("end", Sys.time()))
