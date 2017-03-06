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
