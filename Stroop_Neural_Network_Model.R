# Author: Carlos Salas

# Set working directory
setwd("C:/Users/Carlos Salas/Dropbox/1 Spring 2017/CompModels/Stroop_Neural_Net")


#####################
# Network Structure #
#####################
# Note: All layers will initially be set up as node matrices with NAs as follows. The 
# neural architecture was chosen based on previous models in the PDP literature 
# (Botvinick et al., 2001), and was structured to be the simplest model needed to 
# in order to capture the Stroop task environment and instructional demands. 

# Layer 1 = Input nodes. 
# These will take on binary (0,1) states, and will accept a vector of 6 
# values representing a potential stimulus. E.g., If a stimulus has the 
# word "Red" printed in "Green" color ink, and the instruction is to 
# name the color, then it would be specified as follows: 0,1,1,0,1,0,1,0

# Matrix for storing stimuli activation values in binary states
    input <- data.frame(matrix(rep(NA,6),nrow =1,ncol =6))
    names(input) <- c("C.Red", "C.Green", "Task.Color","Task.Word",
                      "W.Red", "W.Green")
    input       

# Layer2  = Hidden Layer. 
# This represents the intermediate nodes between the input and output layers. 
# There are four nodes: two nodes in the Color pathway, and two in the 
# Word pathway. Each node is linked and thus receives signals from three 
# input nodes from layer 1. For hidden nodes in Color pathways, links feed in 
# from both the Red and Green Color nodes + the Color Naming task node. For hidden 
# nodes in the Word pathway, links feed in from both Red and Green Word 
# nodes + the Word REading task node. The link weights are specified in list of 
# weight matrices (see line 60).

# Matrix for storing hidden node activation values
    hidden <- data.frame(matrix((rep(NA,4)),1,4))
    names(hidden) <- c("CH1", "CH2", "WH1", "WH2")
    
    hidden

    