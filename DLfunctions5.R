############################################################################################################
#
# File   : DLfunctions5.R
# Author : Tinniam V Ganesh
# Date   : 22 Mar 2018
#
##########################################################################################################
library(ggplot2)
library(PRROC)
library(dplyr)

# Compute the sigmoid of a vector
sigmoid <- function(Z){
  A <- 1/(1+ exp(-Z))
  cache<-Z
  retvals <- list("A"=A,"Z"=Z)
  return(retvals)
  
}

# Compute the Relu of a vector
relu   <-function(Z){
  A <- apply(Z, 1:2, function(x) max(0,x))
  cache<-Z
  retvals <- list("A"=A,"Z"=Z)
  return(retvals)
}

# Compute the tanh activation of a vector
tanhActivation <- function(Z){
  A <- tanh(Z)
  cache<-Z
  retvals <- list("A"=A,"Z"=Z)
  return(retvals)
}

# Conmpute the softmax of a vector
softmax   <- function(Z){
  # get unnormalized probabilities
  exp_scores = exp(t(Z))
  # normalize them for each example
  A = exp_scores / rowSums(exp_scores)   
  retvals <- list("A"=A,"Z"=Z)
  return(retvals)
}

# Compute the detivative of Relu 
# g'(z) = 1 if z >0 and 0 otherwise
reluDerivative   <-function(dA, cache){
  Z <- cache
  dZ <- dA
  # Create a logical matrix of values > 0
  a <- Z > 0
  # When z <= 0, you should set dz to 0 as well. Perform an element wise multiple
  dZ <- dZ * a
  return(dZ)
}

# Compute the derivative of sigmoid
# Derivative g'(z) = a* (1-a)
sigmoidDerivative   <- function(dA, cache){
  Z <- cache  
  s <- 1/(1+exp(-Z))
  dZ <- dA * s * (1-s)   
  return(dZ)
}

# Compute the derivative of tanh
# Derivative g'(z) = 1- a^2
tanhDerivative   <- function(dA, cache){
  Z = cache  
  a = tanh(Z)
  dZ = dA * (1 - a^2)  
  return(dZ)
}

# Populate a matrix of 1s in rows where Y==1
# This may need to be extended for K classes. Currently
# supports K=3 & K=10
popMatrix <- function(Y,numClasses){
    a=rep(0,times=length(Y))
    Y1=matrix(a,nrow=length(Y),ncol=numClasses)
    #Set the rows and columns as 1's where Y is the class value
    if(numClasses==3){
        Y1[Y==0,1]=1
        Y1[Y==1,2]=1
        Y1[Y==2,3]=1
    } else if (numClasses==10){
        Y1[Y==0,1]=1
        Y1[Y==1,2]=1
        Y1[Y==2,3]=1
        Y1[Y==3,4]=1
        Y1[Y==4,5]=1
        Y1[Y==5,6]=1
        Y1[Y==6,7]=1
        Y1[Y==7,8]=1
        Y1[Y==8,9]=1
        Y1[Y==9,0]=1
    }
    return(Y1)
}

softmaxDerivative    <- function(dA, cache ,y,numTraining,numClasses){
  # Note : dA not used. dL/dZ = dL/dA * dA/dZ = pi-yi
  Z <- cache 
  # Compute softmax
  exp_scores = exp(t(Z))
  # normalize them for each example
  probs = exp_scores / rowSums(exp_scores)
  # Create a matrix of zeros
  Y1=popMatrix(y,numClasses)
  #a=rep(0,times=length(Y))
  #Y1=matrix(a,nrow=length(Y),ncol=numClasses)
  #Set the rows and columns as 1's where Y is the class value

  dZ = probs-Y1
  return(dZ)
}

# Initialize the model 
# Input : number of features
#         number of hidden units
#         number of units in output
# Returns: Weight and bias matrices and vectors


# Initialize model for L layers
# Input : List of units in each layer
# Returns: Initial weights and biases matrices for all layers
initializeDeepModel <- function(layerDimensions){
  set.seed(2)
  
  # Initialize empty list
  layerParams <- list()
  
  # Note the Weight matrix at layer 'l' is a matrix of size (l,l-1)
  # The Bias is a vectors of size (l,1)
  
  # Loop through the layer dimension from 1.. L
  # Indices in R start from 1
  for(l in 2:length(layersDimensions)){
    # Initialize a matrix of small random numbers of size l x l-1
    # Create random numbers of size  l x l-1
    w=rnorm(layersDimensions[l]*layersDimensions[l-1])*0.01
    
    # Create a weight matrix of size l x l-1 with this initial weights and
    # Add to list W1,W2... WL
    layerParams[[paste('W',l-1,sep="")]] = matrix(w,nrow=layersDimensions[l],
                                                  ncol=layersDimensions[l-1])
    layerParams[[paste('b',l-1,sep="")]] = matrix(rep(0,layersDimensions[l]),
                                                  nrow=layersDimensions[l],ncol=1)
  }
  return(layerParams)
}


# Compute the activation at a layer 'l' for forward prop in a Deep Network
# Input : A_prec - Activation of previous layer
#         W,b - Weight and bias matrices and vectors
#         activationFunc - Activation function - sigmoid, tanh, relu etc
# Returns : The Activation of this layer
#         : 
# Z = W * X + b
# A = sigmoid(Z), A= Relu(Z), A= tanh(Z)
layerActivationForward <- function(A_prev, W, b, activationFunc){
  
  # Compute Z
  z = W %*% A_prev
  # Broadcast the bias 'b' by column
  Z <-sweep(z,1,b,'+')
  
  forward_cache <- list("A_prev"=A_prev, "W"=W, "b"=b) 
  # Compute the activation for sigmoid
  if(activationFunc == "sigmoid"){
    vals = sigmoid(Z)  
  } else if (activationFunc == "relu"){ # Compute the activation for relu
    vals = relu(Z)
  } else if(activationFunc == 'tanh'){ # Compute the activation for tanh
    vals = tanhActivation(Z) 
  } else if(activationFunc == 'softmax'){
    vals = softmax(Z)
  }
  # Create a list of forward and activation cache
  cache <- list("forward_cache"=forward_cache, "activation_cache"=vals[['Z']])
  retvals <- list("A"=vals[['A']],"cache"=cache)
  return(retvals)
}

# Compute the forward propagation for layers 1..L
# Input : X - Input Features
#         paramaters: Weights and biases
#         hiddenActivationFunc - elu/sigmoid/tanh
#         outputActivationFunc - Activation function at hidden layer sigmoid/softmax
# Returns : AL 
#           caches
# The forward propoagtion uses the Relu/tanh activation from layer 1..L-1 and sigmoid actiovation at layer L
forwardPropagationDeep <- function(X, parameters,hiddenActivationFunc='relu',
                                           outputActivationFunc='sigmoid'){
  caches <- list()
  # Set A to X (A0)
  A <- X
  L <- length(parameters)/2 # number of layers in the neural network
  # Loop through from layer 1 to upto layer L
  for(l in 1:(L-1)){
    A_prev <- A 
    # Zi = Wi x Ai-1 + bi  and Ai = g(Zi)
    # Set W and b for layer 'l'
    # Loop throug from W1,W2... WL-1
    W <- parameters[[paste("W",l,sep="")]]
    b <- parameters[[paste("b",l,sep="")]]
    # Compute the forward propagation through layer 'l' using the activation function
    actForward <- layerActivationForward(A_prev, 
                                         W, 
                                         b, 
                                         activationFunc = hiddenActivationFunc)
    A <- actForward[['A']]
    # Append the cache A_prev,W,b, Z
    caches[[l]] <-actForward
  }
  
  # Since this is binary classification use the sigmoid activation function in
  # last layer  
  # Set the weights and biases for the last layer
  W <- parameters[[paste("W",L,sep="")]]
  b <- parameters[[paste("b",L,sep="")]]
  # Compute the sigmoid activation
  actForward = layerActivationForward(A, W, b, activationFunc = outputActivationFunc)
  AL <- actForward[['A']]
  # Append the output of this forward propagation through the last layer
  caches[[L]] <- actForward
  # Create a list of the final output and the caches
  fwdPropDeep <- list("AL"=AL,"caches"=caches)
  return(fwdPropDeep)
  
}

pickColumns <- function(AL,Y,numClasses){
    if(numClasses==3){
        a=c(AL[Y==0,1],AL[Y==1,2],AL[Y==2,3])
    }
    else if (numClasses==10){
        a=c(AL[Y==0,1],AL[Y==1,2],AL[Y==2,3],AL[Y==3,4],AL[Y==4,5],
            AL[Y==5,6],AL[Y==6,7],AL[Y==7,8],AL[Y==8,9],AL[Y==9,10])
    }
    return(a)
}


# Compute the cost
# Input : Activation of last layer
#       : Output from data
#       :outputActivationFunc - Activation function at hidden layer sigmoid/softmax
#       : numClasses
# Output: cost
computeCost <- function(AL,Y,outputActivationFunc="sigmoid",numClasses=3){
  if(outputActivationFunc=="sigmoid"){
    m= length(Y)
    cost=-1/m*sum(Y*log(AL) + (1-Y)*log(1-AL))
  }else if (outputActivationFunc=="softmax"){
    # Select the elements where the y values are 0, 1 or 2 and make a vector
    # Pick columns
    #a=c(AL[Y==0,1],AL[Y==1,2],AL[Y==2,3])
    m= length(Y)
    a =pickColumns(AL,Y,numClasses)
    #a = c(A2[y=k,k+1])
    # Take log
    correct_probs = -log(a)
    # Compute loss
    cost= sum(correct_probs)/m
  }
  #cost=-1/m*sum(a+b)
  return(cost)
}


# Compute the backpropagation through a layer
# Input : Neural Network parameters - dA
#       # cache - forward_cache & activation_cache
#       # Input features
#       # Output values Y
#       # activationFunc
#       # numClasses
# Returns: Gradients
# dL/dWi= dL/dZi*Al-1
# dl/dbl = dL/dZl
# dL/dZ_prev=dL/dZl*W

layerActivationBackward  <- function(dA, cache, Y, activationFunc,numClasses){
  # Get A_prev,W,b
  forward_cache <-cache[['forward_cache']]
  activation_cache <- cache[['activation_cache']]
  A_prev <- forward_cache[['A_prev']]
  numtraining = dim(A_prev)[2]
  # Get Z
  activation_cache <- cache[['activation_cache']]
  if(activationFunc == "relu"){
    dZ <- reluDerivative(dA, activation_cache)  
  } else if(activationFunc == "sigmoid"){
    dZ <- sigmoidDerivative(dA, activation_cache)  
  } else if(activationFunc == "tanh"){
    dZ <- tanhDerivative(dA, activation_cache)
  } else if(activationFunc == "softmax"){
    dZ <- softmaxDerivative(dA,  activation_cache,Y,numtraining,numClasses)
  }
  
  if (activationFunc == 'softmax'){
    W <- forward_cache[['W']]
    b <- forward_cache[['b']]
    dW = 1/numtraining * A_prev%*%dZ
    db = 1/numtraining* matrix(colSums(dZ),nrow=1,ncol=numClasses)
    dA_prev = dZ %*%W
  } else {
    W <- forward_cache[['W']]
    b <- forward_cache[['b']]
    numtraining = dim(A_prev)[2]
    
    dW = 1/numtraining * dZ %*% t(A_prev)
    db = 1/numtraining * sum(dZ)
    dA_prev = t(W) %*% dZ
  }
  retvals <- list("dA_prev"=dA_prev,"dW"=dW,"db"=db)
  return(retvals)
}

# Compute the backpropagation for 1 cycle through all layers
# Input : AL: Output of L layer Network - weights
#       # Y  Real output
#       # caches -- list of caches containing:
#       every cache of layerActivationForward() with "relu"/"tanh"
#       #(it's caches[l], for l in range(L-1) i.e l = 0...L-2)
#       #the cache of layerActivationForward() with "sigmoid" (it's caches[L-1])
#       hiddenActivationFunc - Activation function at hidden layers - relu/tanh/sigmoid
#       outputActivationFunc - Activation function at hidden layer sigmoid/softmax
#    
#   Returns:
#    gradients -- A dictionary with the gradients
#                 gradients["dA" + str(l)] = ... 
#      
backwardPropagationDeep <- function(AL, Y, caches,hiddenActivationFunc='relu',
                                outputActivationFunc="sigmoid",numClasses){
  #initialize the gradients
  gradients = list()
  # Set the number of layers
  L = length(caches) 
  numTraining = dim(AL)[2]
  
  if(outputActivationFunc == "sigmoid")
    # Initializing the backpropagation 
    # dl/dAL= -(y/a) - ((1-y)/(1-a)) - At the output layer
    dAL = -( (Y/AL) -(1 - Y)/(1 - AL))    
  else if(outputActivationFunc == "softmax"){
    dAL=0
    Y=t(Y)
  }
  
  # Get the gradients at the last layer
  # Inputs: "AL, Y, caches". 
  # Outputs: "gradients["dAL"], gradients["dWL"], gradients["dbL"]  
  # Start with Layer L
  # Get the current cache
  current_cache = caches[[L]]$cache
  #gradients["dA" + str(L)], gradients["dW" + str(L)], gradients["db" + str(L)] = layerActivationBackward(dAL, current_cache, activationFunc = "sigmoid")
  retvals <-  layerActivationBackward(dAL, current_cache, Y, activationFunc = outputActivationFunc,numClasses)
  # Create gradients as lists
  #Note: Take the transpose of dA
  if(outputActivationFunc =="sigmoid")
      gradients[[paste("dA",L,sep="")]] <- retvals[['dA_prev']]
  else if(outputActivationFunc =="softmax")
    gradients[[paste("dA",L,sep="")]] <- t(retvals[['dA_prev']])
  gradients[[paste("dW",L,sep="")]] <- retvals[['dW']]
  gradients[[paste("db",L,sep="")]] <- retvals[['db']]
  
  # Traverse in the reverse direction
  for(l in (L-1):1){
    # Compute the gradients for L-1 to 1 for Relu/tanh
    # Inputs: "gradients["dA" + str(l + 2)], caches". 
    # Outputs: "gradients["dA" + str(l + 1)] , gradients["dW" + str(l + 1)] , gradients["db" + str(l + 1)] 
    current_cache = caches[[l]]$cache
    
    retvals = layerActivationBackward(gradients[[paste('dA',l+1,sep="")]], 
                                      current_cache, 
                                      activationFunc = hiddenActivationFunc)
    
    gradients[[paste("dA",l,sep="")]] <-retvals[['dA_prev']]
    gradients[[paste("dW",l,sep="")]] <- retvals[['dW']]
    gradients[[paste("db",l,sep="")]] <- retvals[['db']]
  }
  
  
  
  return(gradients)
}


# Perform Gradient Descent
# Input : Weights and biases
#       : gradients
#       : learning rate
#       : outputActivationFunc - Activation function at hidden layer sigmoid/softmax
#output : Updated weights after 1 iteration
gradientDescent  <- function(parameters, gradients, learningRate,outputActivationFunc="sigmoid"){
  
  L = length(parameters)/2 # number of layers in the neural network
  
  # Update rule for each parameter. Use a for loop.
  for(l in 1:(L-1)){
    parameters[[paste("W",l,sep="")]] = parameters[[paste("W",l,sep="")]] -
      learningRate* gradients[[paste("dW",l,sep="")]] 
    parameters[[paste("b",l,sep="")]] = parameters[[paste("b",l,sep="")]] -
      learningRate* gradients[[paste("db",l,sep="")]] 
  }
  if(outputActivationFunc=="sigmoid"){
    parameters[[paste("W",L,sep="")]] = parameters[[paste("W",L,sep="")]] -
      learningRate* gradients[[paste("dW",L,sep="")]] 
    parameters[[paste("b",L,sep="")]] = parameters[[paste("b",L,sep="")]] -
      learningRate* gradients[[paste("db",L,sep="")]] 
    
  }else if (outputActivationFunc=="softmax"){
    parameters[[paste("W",l,sep="")]] = parameters[[paste("W",l,sep="")]] -
      learningRate* gradients[[paste("dW",l,sep="")]]
    parameters[[paste("b",l,sep="")]] = parameters[[paste("b",l,sep="")]] -
      learningRate* gradients[[paste("db",l,sep="")]]
  }
  return(parameters)
}


# Execute a L layer Deep learning model
# Input : X - Input features
#       : Y output
#       : layersDimensions - Dimension of layers
#       : hiddenActivationFunc - Activation function at hidden layer relu /tanh
#       : outputActivationFunc - Activation function at hidden layer sigmoid/softmax
#       : learning rate
#       : num of iterations
#output : Updated weights after each  iteration

L_Layer_DeepModel <- function(X, Y, layersDimensions,
                              hiddenActivationFunc='relu', 
                              outputActivationFunc= 'sigmoid',
                              learningRate = 0.5,
                              numIterations = 10000, 
                              print_cost=False){
  #Initialize costs vector as NULL
  costs <- NULL                        
  
  # Parameters initialization.
  parameters = initializeDeepModel(layersDimensions)
  

  # Loop (gradient descent)
  for( i in 0:numIterations){
    # Forward propagation: [LINEAR -> RELU]*(L-1) -> LINEAR -> SIGMOID/SOFTMAX.
    retvals = forwardPropagationDeep(X, parameters,hiddenActivationFunc,
                                     outputActivationFunc=outputActivationFunc)
    AL <- retvals[['AL']]
    caches <- retvals[['caches']]
    
    # Compute cost.
    cost <- computeCost(AL, Y,outputActivationFunc=outputActivationFunc,numClasses=layersDimensions[3])
    
    # Backward propagation.
    gradients = backwardPropagationDeep(AL, Y, caches,hiddenActivationFunc,
                                        outputActivationFunc=outputActivationFunc,numClasses=layersDimensions[3])
    
    # Update parameters.
    parameters = gradientDescent(parameters, gradients, learningRate,
                                 outputActivationFunc=outputActivationFunc)
    
    
    if(i%%1000 == 0){
      costs=c(costs,cost)
      print(cost)
    }
  }
  
  retvals <- list("parameters"=parameters,"costs"=costs)
  
  return(retvals)
}

# Execute a L layer Deep learning model with Stochastic Gradient descent
# Input : X - Input features
#       : Y output
#       : layersDimensions - Dimension of layers
#       : hiddenActivationFunc - Activation function at hidden layer relu /tanh
#       : outputActivationFunc - Activation function at hidden layer sigmoid/softmax
#       : learning rate
#       : mini_batch_size
#       : num of epochs
#output : Updated weights after each  iteration
L_Layer_DeepModel_SGD <- function(X, Y, layersDimensions,
                              hiddenActivationFunc='relu', 
                              outputActivationFunc= 'sigmoid',
                              learningRate = .3, 
                              mini_batch_size = 64, 
                              num_epochs = 2500,
                              print_cost=False){
    
    set.seed(1)
    #Initialize costs vector as NULL
    costs <- NULL                        
    
    # Parameters initialization.
    parameters = initializeDeepModel(layersDimensions)
    seed=10
    
    # Loop for number of epochs
    for( i in 0:num_epochs){
        seed=seed+1
        minibatches = random_mini_batches(X, Y, mini_batch_size, seed)
        
        for(batch in 1:length(minibatches)){

            mini_batch_X=minibatches[[batch]][['mini_batch_X']]
            mini_batch_Y=minibatches[[batch]][['mini_batch_Y']]
            # Forward propagation: 
            retvals = forwardPropagationDeep(mini_batch_X, parameters,hiddenActivationFunc,
                                             outputActivationFunc=outputActivationFunc)
            AL <- retvals[['AL']]
            caches <- retvals[['caches']]
            
            # Compute cost.
            cost <- computeCost(AL, mini_batch_Y,outputActivationFunc=outputActivationFunc,numClasses=layersDimensions[length(layersDimensions)])
            
            # Backward propagation.
            gradients = backwardPropagationDeep(AL, mini_batch_Y, caches,hiddenActivationFunc,
                                                outputActivationFunc=outputActivationFunc,numClasses=layersDimensions[length(layersDimensions)])
            
            # Update parameters.
            parameters = gradientDescent(parameters, gradients, learningRate,
                                         outputActivationFunc=outputActivationFunc)
        }
        
        if(i%%100 == 0){
            costs=c(costs,cost)
            print(cost)
        }
    }
    
    retvals <- list("parameters"=parameters,"costs"=costs)
    
    return(retvals)
}

# Predict the output for given input
# Input : parameters
#       : X
# Output: predictions  
predict <- function(parameters, X,hiddenActivationFunc='relu'){
  
  fwdProp <- forwardPropagationDeep(X, parameters,hiddenActivationFunc)
  predictions <- fwdProp$AL>0.5
  
  return (predictions)
}

# Predict the output
predictProba <- function(parameters, X,hiddenActivationFunc,
                         outputActivationFunc){
    retvals = forwardPropagationDeep(X, parameters,hiddenActivationFunc,
                                     outputActivationFunc="softmax")
    if(outputActivationFunc =="sigmoid")
        predictions <- retvals$AL>0.5
    else if (outputActivationFunc =="softmax")
        predictions <- apply(retvals$AL, 1,which.max) -1
        
    return (predictions)
}

# Plot a decision boundary
# This function uses ggplot2
plotDecisionBoundary <- function(z,retvals,hiddenActivationFunc,lr){
  # Find the minimum and maximum for the data
  xmin<-min(z[,1])
  xmax<-max(z[,1])
  ymin<-min(z[,2])
  ymax<-max(z[,2])
  
  # Create a grid of values
  a=seq(xmin,xmax,length=100)
  b=seq(ymin,ymax,length=100)
  grid <- expand.grid(x=a, y=b)
  colnames(grid) <- c('x1', 'x2')
  grid1 <-t(grid)
  # Predict the output for this grid
  q <-predict(retvals$parameters,grid1,hiddenActivationFunc)
  q1 <- t(data.frame(q))
  q2 <- as.numeric(q1)
  grid2 <- cbind(grid,q2)
  colnames(grid2) <- c('x1', 'x2','q2')
  
  z1 <- data.frame(z)
  names(z1) <- c("x1","x2","y")
  atitle=paste("Decision boundary for learning rate:",lr)
  # Plot the contour of the boundary
  ggplot(z1) + 
    geom_point(data = z1, aes(x = x1, y = x2, color = y)) +
    stat_contour(data = grid2, aes(x = x1, y = x2, z = q2,color=q2), alpha = 0.9)+
    ggtitle(atitle)
}

# Predict the probability  scores for given data set
# Input : parameters
#       : X
# Output: probability of output 
computeScores <- function(parameters, X,hiddenActivationFunc='relu'){
  
  fwdProp <- forwardPropagationDeep(X, parameters,hiddenActivationFunc)
  scores <- fwdProp$AL
  
  return (scores)
}


random_mini_batches <- function(X, Y, miniBatchSize = 64, seed = 0){
    
   
    set.seed(seed)
    # Get number of training samples       
    m = dim(X)[2]
    # Initialize mini batches     
    mini_batches = list()
    
    # Create  a list of random numbers < m
    permutation = c(sample(m))
    # Randomly shuffle the training data
    shuffled_X = X[, permutation]
    shuffled_Y = Y[1, permutation]
    
    # Compute number of mini batches
    numCompleteMinibatches = floor(m/miniBatchSize)
    batch=0
    for(k in 0:(numCompleteMinibatches-1)){
        batch=batch+1
        # Set the lower and upper bound of the mini batches
        lower=(k*miniBatchSize)+1
        upper=((k+1) * miniBatchSize)
        mini_batch_X = shuffled_X[, lower:upper]
        mini_batch_Y = shuffled_Y[lower:upper]
        # Add it to the list of mini batches
        mini_batch = list("mini_batch_X"=mini_batch_X,"mini_batch_Y"=mini_batch_Y)
        mini_batches[[batch]] =mini_batch
        
    
    }

    # If the batch size does not divide evenly with mini batc size
    if(m %% miniBatchSize != 0){
        p=floor(m/miniBatchSize)*miniBatchSize
        # Set the start and end of last batch
        q=p+m %% miniBatchSize
        mini_batch_X = shuffled_X[,(p+1):q]
        mini_batch_Y = shuffled_Y[(p+1):q]
    }
    # Return the list of mini batches
    mini_batch = list("mini_batch_X"=mini_batch_X,"mini_batch_Y"=mini_batch_Y)
    mini_batches[[batch]]=mini_batch
    
    return(mini_batches)
}