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
    # input       

# Layer2  = Hidden Layer. 
    # This represents the intermediate nodes between the input and output layers. 
    # There are four nodes: two nodes in the Color pathway, and two in the 
    # Word pathway. Each node is linked and thus receives signals from three 
    # input nodes from layer 1. For hidden nodes in Color pathways, links feed in 
    # from both the Red and Green Color nodes + the Color Naming task node. For hidden 
    # nodes in the Word pathway, links feed in from both Red and Green Word 
    # nodes + the Word REading task node. The link weights are specified in list of 
    # weight matrices.

    # Matrix for storing hidden node activation values
    hidden <- data.frame(matrix((rep(NA,4)),1,4))
    names(hidden) <- c("CH1", "CH2", "WH1", "WH2")
    
    # hidden


# Layer 3 = Output layer. 
    # This represents the structure for the ouput layer. It has two nodes, one for 
    # each color response (i.e., Red and Green). The activation of each of these 
    # per cycle will be fed into a response mechanism (specified below). 
    # The output nodes receive input from every node in the hidden layer.
    
    # Matrix for storing output node activation values
    output <- data.frame(matrix(rep(NA,2), nrow =1, ncol = 2))
    names(output) <- c("Red", "Green")
    
    # output   
    
# Connections and weight matrices. 
    # These were derived via a network training algorithm. The network's weights were 
    # trained to indicate the correct response to a color word or to the color of the 
    # word's printed ink. Differential amounts of exposure to words and color patterns 
    # were given in order to mimic human's overlearned tendency for word reading 
    # relative to color naming (ratio was 5:1, respectively). The resulting weight 
    # matrix represents a network with two processing sub-systems/pathways: 
    # A Color detection pathway, and a Word reading pathway. Values were 
    # similar to those reported by Botvinick et al, 2001).
    
    
    # List of weights and connection indices from input to hidden node links.
        # CH1w and CH2w: Color hidden weights. WH1w and WH2w: Word hidden weights
        # CHP: Color Hidden Path. WHP: Word Hidden Path
        CH1 = list("CH1w" = c(2.2,-2.2,4), "CHP" = c(1,2,3))
        CH2 = list("CH2w" = c(-2.2,2.2,4), "CHP" = c(1,2,3)) 
        WH1 = list("WH1w" = c(4,2.6,-2.6), "WHP" = c(4,5,6))
        WH2 = list("WH2w" = c(4,-2.6,2.6), "WHP" = c(4,5,6))
    
    # List of lists containing I to H weights and connection indices    
        IH.connections <- list(CH1,CH2,WH1,WH2)
        
        
    # List of vectors representing Hidden to Output node weights. Each output
    # node is connected to all hidden nodes, so indices are unnecessary
        HO.weights <- list("ROut" = c(1.3,-1.3,2.5,-2.5),
                           "GOut" = c(-1.3,1.3,-2.5,2.5))
    
    
########################################
#  Transfer, Activation, and Response  #
#         Mechanism functions.         #
########################################
# The neurons pass activation forward by summing their net input, and 
# passing this activation through a nonlinear function. This model uses 
# a Sigmoid transform function, as it i continuously differentiable (which 
# is handy for the backpropagation training algorithm used to derive the 
# weights - see training script). Alternatives such as a Weibul function
# should be tested in a future implementation.  
    
        
    # Sigmoid function
    sigmoid <- function(x){1/(1 + exp(-x))}
        
# Activation calculations per node
    # Variability will be fed into each processing cycle by adding Gaussian noise
    # to the hidden and output node activations per cycle.
        
    # Cascade rate: controls how fast the network propagates signals forward.
    tau <- .1 
        
    # Gaussian noise distribution (processing). Mean = 0, SD = .1
    set.seed(151)  
    sigma.p <- .1
    dp <- rnorm(100000,0,sigma.p)
    
# Net Activation (Hidden layer):    
    # Net calculation for hidden nodes. Input: a vector of stimuli values. 
    # Connections: a list of  weights and connection indices from Input to Hidden 
    # layer. Bias: Hidden layer node bias (chosen to mute hidden node activation
    # when a task demand input is zero). net.input.matrix: boolean value. TRUE 
    # returns out a list of pre-summation input matrices as well as a vector of 
    # net activation for all hidden nodes. FALSE returns only the net activation.
    
    H.netcalc <- function(input, connections, bias = -4, net.input.matrix = FALSE){
        # Shorthand     
        inp <- input 
        con <- connections
        
        # A*W products per hidden node
        IHC <- t(sapply(1:2,function(i) unlist(con[[i]][[1]]*inp[con[[i]][[2]]])))
        IHW <- t(sapply(3:4,function(i) unlist(con[[i]][[1]]*inp[con[[i]][[2]]])))
        
        # Convert to data.frame
        IHC <- data.frame(IHC)
        IHW <- data.frame(IHW)
        rownames(IHC) <- c("Node1", "Node2")
        rownames(IHW) <- c("Node1", "Node2")
        
        # Net input matrices
        net.input <- list("IHC" = IHC, "IHW" = IHW)       
        
        # Sums per node
        IHCsum <- apply(IHC, 1, function(i) sum(i))
        IHWsum <- apply(IHW, 1, function(i) sum(i))
        
        # Net per node
        net <- c(IHCsum,IHWsum) + bias 
        
        ifelse(net.input.matrix == TRUE, 
               return(list("Net.Input.Matrix" = net.input,"Net.Activation" = net)), 
               return(net))
    }  
    
    
# Input to Hidden nodes:  Activation function with sigmoid transform
    # Accepts a cascade rate (tau), a vector of net activation sums (net),
    # and a dataframe to store hidden node activations (H.nodes), and the
    # maximum number of iterations. 
    
    fire.IH <- function(tau = .1, net, H.nodes, max.iter = 15){ 
        
        # Clears first row for ease of processing (if values are NA)
        if(sum(is.na(H.nodes)) == 4){
            hidden <- H.nodes[-(1:nrow(H.nodes)),]
        } else{
            hidden = H.nodes
        }
        
        # Initializes the cycles
        c = 1     
        
        # While loop to run activation transfer function
        while(c <= max.iter){ 
            
            # For first iteration
            if(c == 1){ 
                
                # Noise (4 different noise values (one per node))
                noise <- sample(dp,4) # Remember to turn on  for real runs   
                
                net.activations <- tau*net + (1-tau)*net + noise
                
                # Current net activation per node in hidden layer    
                activation <- sigmoid(net.activations)
                
            } 
            
            # For all other iterations
            else if(sum(is.na(H.nodes)) == 0 | c > 1){
                # Net average from previous cycle
                net.avg <- apply(hidden, 2, function(i) mean(i, na.rm = TRUE))
                
                # Noise (4 different noise values (one per node))
                noise <- sample(dp,4) # Remember to turn on  for real runs   
                
                net.activations <- tau*net + (1-tau)*net.avg + noise 
                
                # Current net activation per node in hidden layer
                activation <- sigmoid(net.activations)
            }
            
            
            hidden <- rbind(hidden,activation)
            
            c <- c + 1 
        }
        
        # Tidy up the hidden node matrix
        # Adds a zero vector to first row (for plotting)
        hidden <- rbind(rep(0,4), hidden) 
        names(hidden) <- c("CH1", "CH2", "WH1", "WH2")
        
        # Return the hidden node activation states
        return(hidden)
        
    }    

# Net Activation (Output layer):    
    # Net calculation for output nodes. Input: a vector of stimuli values. 
    # weights: a list of weights from Hidden to Output layer. Returns out 
    # a vector of net activation for all output nodes. 
    
    O.netcalc <- function(input, weights){
        
        # Starts at row 2 since row 1 are hidden layer init values
        inp <- input[2:nrow(input),] 
        
        # Weight vectors is list of weight vectors
        w <- weights
        
        # A*W products per output node
        r.prod <- data.frame(t(apply(inp, 1, function(i) i*w$ROut)))
        g.prod <- data.frame(t(apply(inp, 1, function(i) i*w$GOut)))
        
        # Sums per node (across cycles)
        Rsums <- cbind(rowSums(r.prod))
        Gsums <- cbind(rowSums(g.prod))
        
        # Net per node
        net.output <- data.frame("net.R" = Rsums, "net.G" = Gsums)
        
        return(net.output)
    }
    

    
    

    