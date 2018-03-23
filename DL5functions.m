1;
# Define sigmoid function
function [A,cache] = sigmoid(Z)
  A = 1 ./ (1+ exp(-Z));
  cache=Z;
end

# Define Relu function
function [A,cache] = relu(Z)
  A = max(0,Z);
  cache=Z;
end

# Define Relu function
function [A,cache] = tanhAct(Z)
  A = tanh(Z);
  cache=Z;
end

# Define Softmax function
function [A,cache] = softmax(Z)
    # get unnormalized probabilities
    exp_scores = exp(Z');
    # normalize them for each example
    A = exp_scores ./ sum(exp_scores,2);   
    cache=Z;
end

# Define Softmax function
function [A,cache] = stableSoftmax(Z)
    # Normalize by max value in each row
    shiftZ = Z' - max(Z',[],2);
    exp_scores = exp(shiftZ);
    # normalize them for each example
    A = exp_scores ./ sum(exp_scores,2);   
    #disp("sm")
    #disp(A);
    cache=Z;
end

# Define Relu Derivative 
function [dZ] = reluDerivative(dA,cache)
  Z = cache;
  dZ = dA;
  # Get elements that are greater than 0
  a = (Z > 0);
  # Select only those elements where Z > 0
  dZ = dZ .* a;
end

# Define Sigmoid Derivative 
function [dZ] = sigmoidDerivative(dA,cache)
  Z = cache;
  s = 1 ./ (1+ exp(-Z));
  dZ = dA .* s .* (1-s);
end

# Define Tanh Derivative 
function [dZ] = tanhDerivative(dA,cache)
  Z = cache;
  a = tanh(Z);
  dZ = dA .* (1 - a .^ 2);
end

# Populate a matrix with 1s in rows where Y=1
# This function may need to be modified if K is not 3, 10
function [Y1] = popMatrix(Y,numClasses)
    Y1=zeros(length(Y),numClasses);
    if(numClasses==3) # For 3 output classes
       Y1(Y==0,1)=1;
       Y1(Y==1,2)=1;
       Y1(Y==2,3)=1;
    elseif(numClasses==10) # For 10 output classes
       Y1(Y==0,1)=1;
       Y1(Y==1,2)=1;
       Y1(Y==2,3)=1;       
       Y1(Y==3,4)=1;
       Y1(Y==4,5)=1;
       Y1(Y==5,6)=1;       
       Y1(Y==6,7)=1;
       Y1(Y==7,8)=1;
       Y1(Y==8,9)=1;      
       Y1(Y==9,10)=1;

     endif
end

# Define Softmax Derivative 
function [dZ] = softmaxDerivative(dA,cache,Y, numClasses)
  Z = cache;
  # get unnormalized probabilities
  shiftZ = Z' - max(Z',[],2);
  exp_scores = exp(shiftZ);

  # normalize them for each example
  probs = exp_scores ./ sum(exp_scores,2);  
  # dZ = pi- yi
  yi=popMatrix(Y,numClasses);
  dZ=probs-yi;
  
end

# Define Softmax Derivative 
function [dZ] = stableSoftmaxDerivative(dA,cache,Y, numClasses)
  Z = cache;
  # get unnormalized probabilities
  exp_scores = exp(Z');
  # normalize them for each example
  probs = exp_scores ./ sum(exp_scores,2);  
  # dZ = pi- yi
  yi=popMatrix(Y,numClasses);
  dZ=probs-yi;

end

# Initialize the model 
# Input : number of features
#         number of hidden units
#         number of units in output
# Returns: Weight and bias matrices and vectors


# Initialize model for L layers
# Input : List of units in each layer
# Returns: Initial weights and biases matrices for all layers
function [W b] = initializeDeepModel(layerDimensions)
    rand ("seed", 3);
    # note the Weight matrix at layer 'l' is a matrix of size (l,l-1)
    # The Bias is a vectors of size (l,1)
    
    # Loop through the layer dimension from 1.. L
    # Create cell arrays for Weights and biases

    for l =2:size(layerDimensions)(2)
         W{l-1} = rand(layerDimensions(l),layerDimensions(l-1))*0.01; #  Multiply by .01 
         b{l-1} = zeros(layerDimensions(l),1);       
   
    endfor
end

# Compute the activation at a layer 'l' for forward prop in a Deep Network
# Input : A_prec - Activation of previous layer
#         W,b - Weight and bias matrices and vectors
#         activationFunc - Activation function - sigmoid, tanh, relu etc
# Returns : The Activation of this layer
#         : 
# Z = W * X + b
# A = sigmoid(Z), A= Relu(Z), A= tanh(Z)
function [A forward_cache activation_cache] = layerActivationForward(A_prev, W, b, activationFunc)
    
    # Compute Z
    Z = W * A_prev +b;
    # Create a cell array
    forward_cache = {A_prev  W  b};
    # Compute the activation for sigmoid
    if (strcmp(activationFunc,"sigmoid"))
        [A activation_cache] = sigmoid(Z); 
    elseif (strcmp(activationFunc, "relu"))  # Compute the activation for Relu
        [A activation_cache] = relu(Z);
    elseif(strcmp(activationFunc,'tanh'))     # Compute the activation for tanh
        [A activation_cache] = tanhAct(Z);
    elseif(strcmp(activationFunc,'softmax'))     # Compute the activation for tanh
        #[A activation_cache] = softmax(Z);
        [A activation_cache] = stableSoftmax(Z);
    endif

end

# Compute the forward propagation for layers 1..L
# Input : X - Input Features
#         paramaters: Weights and biases
#         hiddenActivationFunc - Activation function at hidden layers Relu/tanh
#         outputActivationFunc- sigmoid/softmax
# Returns : AL 
#           caches
# The forward propoagtion uses the Relu/tanh activation from layer 1..L-1 and sigmoid actiovation at layer L
function [AL forward_caches activation_caches] = forwardPropagationDeep(X, weights,biases, 
                                               hiddenActivationFunc='relu', outputActivationFunc='sigmoid')
    # Create an empty cell array
    forward_caches = {};
    activation_caches = {};
    # Set A to X (A0)
    A = X;
    L = length(weights); # number of layers in the neural network
    # Loop through from layer 1 to upto layer L
    for l =1:L-1
        A_prev = A; 
        # Zi = Wi x Ai-1 + bi  and Ai = g(Zi)
        W = weights{l};
        b = biases{l};
        [A forward_cache activation_cache] = layerActivationForward(A_prev, W,b, activationFunc=hiddenActivationFunc);
        forward_caches{l}=forward_cache;
        activation_caches{l} = activation_cache;
    endfor
    # Since this is binary classification use the sigmoid activation function in
    # last layer   
    W = weights{L};
    b = biases{L};
    [AL, forward_cache activation_cache] = layerActivationForward(A, W,b, activationFunc = outputActivationFunc);
    forward_caches{L}=forward_cache;
    activation_caches{L} = activation_cache;
            
end

# Pick columns where Y==1
function [a] = pickColumns(AL,Y,numClasses)
    if(numClasses==3)
        a=[AL(Y==0,1) ;AL(Y==1,2) ;AL(Y==2,3)];
    elseif (numClasses==10)
        a=[AL(Y==0,1) ;AL(Y==1,2) ;AL(Y==2,3);AL(Y==3,4);AL(Y==4,5);
           AL(Y==5,6); AL(Y==6,7);AL(Y==7,8);AL(Y==8,9);AL(Y==9,10)];
    endif
end


# Compute the cost
# Input : Activation of last layer
#       : Output from data
#       :  outputActivationFunc- sigmoid/softmax
#       : numClasses 
# Output: cost
function [cost]= computeCost(AL, Y, outputActivationFunc="sigmoid",numClasses)
    if(strcmp(outputActivationFunc,"sigmoid"))
        numTraining= size(Y)(2);
        # Element wise multiply for logprobs
        cost = -1/numTraining * sum((Y .* log(AL)) + (1-Y) .* log(1-AL));
    elseif(strcmp(outputActivationFunc,'softmax'))  
        numTraining = size(Y)(2);
        Y=Y';
        # Select rows where Y=0,1,and 2 and concatenate to a long vector
        #a=[AL(Y==0,1) ;AL(Y==1,2) ;AL(Y==2,3)];
        a =pickColumns(AL,Y,numClasses);

        #Select the correct column for log prob
         correct_probs = -log(a);
         #Compute log loss
         cost= sum(correct_probs)/numTraining; 
     endif
end

# Compute the backpropoagation for 1 cycle
# Input : Neural Network parameters - dA
#       # cache - forward_cache & activation_cache
#       # Input features
#       # Output values Y
#       # outputActivationFunc- sigmoid/softmax
#       # numClasses
# Returns: Gradients
# dL/dWi= dL/dZi*Al-1
# dl/dbl = dL/dZl
# dL/dZ_prev=dL/dZl*W
function [dA_prev dW db] = layerActivationBackward(dA, forward_cache, activation_cache, Y, activationFunc,numClasses)

    A_prev = forward_cache{1};
    W =forward_cache{2};
    b = forward_cache{3};
    numTraining = size(A_prev)(2);
    if (strcmp(activationFunc,"relu"))
        dZ = reluDerivative(dA, activation_cache);           
    elseif (strcmp(activationFunc,"sigmoid"))
        dZ = sigmoidDerivative(dA, activation_cache);      
    elseif(strcmp(activationFunc, "tanh"))
        dZ = tanhDerivative(dA, activation_cache);
    elseif(strcmp(activationFunc, "softmax"))
        #dZ = softmaxDerivative(dA, activation_cache,Y,numClasses);
        dZ = stableSoftmaxDerivative(dA, activation_cache,Y,numClasses);
    endif
    
    
    if (strcmp(activationFunc,"softmax"))
      W =forward_cache{2};
      b = forward_cache{3};
      dW = 1/numTraining * A_prev * dZ;
      db = 1/numTraining * sum(dZ,1);
      dA_prev = dZ*W;
    else 
      W =forward_cache{2};
      b = forward_cache{3};
      dW = 1/numTraining * dZ * A_prev';
      db = 1/numTraining * sum(dZ,2);
      dA_prev = W'*dZ;
    endif
        
end 


# Compute the backpropoagation for 1 cycle
# Input : AL: Output of L layer Network - weights
#       # Y  Real output
#       # caches -- list of caches containing:
#       every cache of layerActivationForward() with "relu"/"tanh"
#       #(it's caches[l], for l in range(L-1) i.e l = 0...L-2)
#       #the cache of layerActivationForward() with "sigmoid" (it's caches[L-1])
#       hiddenActivationFunc - Activation function at hidden layers
#       # outputActivationFunc- sigmoid/softmax
#       # numClasses
#    
#   Returns:
#    gradients -- A dictionary with the gradients
#                 gradients["dA" + str(l)] = ... 
#                 gradients["dW" + str(l)] = ...

function [gradsDA gradsDW gradsDB]= backwardPropagationDeep(AL, Y, activation_caches,forward_caches,
                             hiddenActivationFunc='relu',outputActivationFunc="sigmoid",numClasses)
    

    # Set the number of layers
    L = length(activation_caches); 
    m = size(AL)(2);

    if (strcmp(outputActivationFunc,"sigmoid"))
       # Initializing the backpropagation 
       # dl/dAL= -(y/a + (1-y)/(1-a)) - At the output layer
       dAL = -((Y ./ AL) - (1 - Y) ./ ( 1 - AL));    
    elseif (strcmp(outputActivationFunc,"softmax"))
       dAL=0;
       Y=Y';
    endif
        
    
    # Since this is a binary classification the activation at output is sigmoid
    # Get the gradients at the last layer
    # Inputs: "AL, Y, caches". 
    # Outputs: "gradients["dAL"], gradients["dWL"], gradients["dbL"]  
    activation_cache = activation_caches{L};
    forward_cache = forward_caches(L);
    # Note the cell array includes an array of forward caches. To get to this we need to include the index {1}
    [dA dW db] = layerActivationBackward(dAL, forward_cache{1}, activation_cache, Y, activationFunc = outputActivationFunc,numClasses);
    if (strcmp(outputActivationFunc,"sigmoid"))
         gradsDA{L}= dA; 
    elseif (strcmp(outputActivationFunc,"softmax"))
         gradsDA{L}= dA';#Note the transpose
    endif
    gradsDW{L}= dW;
    gradsDB{L}= db;

    # Traverse in the reverse direction
    for l =(L-1):-1:1
        # Compute the gradients for L-1 to 1 for Relu/tanh
        # Inputs: "gradients["dA" + str(l + 2)], caches". 
        # Outputs: "gradients["dA" + str(l + 1)] , gradients["dW" + str(l + 1)] , gradients["db" + str(l + 1)] 
        activation_cache = activation_caches{l};
        forward_cache = forward_caches(l);
       
        #dA_prev_temp, dW_temp, db_temp = layerActivationBackward(gradients['dA'+str(l+1)], current_cache, activationFunc = "relu")
        # dAl the dervative of the activation of the lth layer,is the first element
        dAl= gradsDA{l+1};
        [dA_prev_temp, dW_temp, db_temp] = layerActivationBackward(dAl, forward_cache{1}, activation_cache, Y, activationFunc = hiddenActivationFunc,numClasses);
        gradsDA{l}= dA_prev_temp;
        gradsDW{l}= dW_temp;
        gradsDB{l}= db_temp;

    endfor

end


# Perform Gradient Descent
# Input : Weights and biases
#       : gradients
#       : learning rate
#       : outputActivationFunc
#output : Updated weights after 1 iteration
function [weights biases] = gradientDescent(weights, biases,gradsW,gradsB, learningRate,outputActivationFunc="sigmoid")

    L = size(weights)(2); # number of layers in the neural network
    
    # Update rule for each parameter. 
    for l=1:(L-1)
        weights{l} = weights{l} -learningRate* gradsW{l}; 
        biases{l} = biases{l} -learningRate* gradsB{l};
    endfor
  
    
    if (strcmp(outputActivationFunc,"sigmoid"))
        weights{L} = weights{L} -learningRate* gradsW{L}; 
        biases{L} = biases{L} -learningRate* gradsB{L};
     elseif (strcmp(outputActivationFunc,"softmax"))
        weights{L} = weights{L} -learningRate* gradsW{L}'; 
        biases{L} = biases{L} -learningRate* gradsB{L}';
     endif

     
end


# Execute a L layer Deep learning model
# Input : X - Input features
#       : Y output
#       : layersDimensions - Dimension of layers
#       : hiddenActivationFunc - Activation function at hidden layer relu /tanh
#       : outputActivationFunc - Activation function at hidden layer sigmoid/softmax
#       : learning rate
#       : num of iterations
#output : Updated weights and biases after each  iteration
function [weights biases costs] = L_Layer_DeepModel(X, Y, layersDimensions, hiddenActivationFunc='relu',  outputActivationFunc="sigmoid",learning_rate = .3, num_iterations = 10000)#lr was 0.009

    rand ("seed", 1);
    costs = [] ;                        
    
    # Parameters initialization.
    [weights biases] = initializeDeepModel(layersDimensions);
    
    # Loop (gradient descent)
    for i = 0:num_iterations
        # Forward propagation: [LINEAR -> RELU]*(L-1) -> LINEAR -> SIGMOID.
        [AL forward_caches activation_caches] = forwardPropagationDeep(X, weights, biases,hiddenActivationFunc, outputActivationFunc=outputActivationFunc);
        
        # Compute cost.
        cost = computeCost(AL, Y,outputActivationFunc=outputActivationFunc,numClasses=layersDimensions(size(layersDimensions)(2)));
   
        # Backward propagation.
        [gradsDA gradsDW gradsDB] = backwardPropagationDeep(AL, Y, activation_caches,forward_caches,hiddenActivationFunc, outputActivationFunc=outputActivationFunc,
                                 numClasses=layersDimensions(size(layersDimensions)(2)));
        # Update parameters.
        [weights biases] = gradientDescent(weights,biases, gradsDW,gradsDB,learning_rate,outputActivationFunc=outputActivationFunc);

                
          # Print the cost every 1000 iterations
        if ( mod(i,1000) == 0)
            costs =[costs cost];
            #disp ("Cost after iteration"), disp(i),disp(cost);
            printf("Cost after iteration i=%i cost=%d\n",i,cost);
        endif
     endfor
    
end

# Execute a L layer Deep learning model with Stochastic Gradient descent
# Input : X - Input features
#       : Y output
#       : layersDimensions - Dimension of layers
#       : hiddenActivationFunc - Activation function at hidden layer relu /tanh
#       : outputActivationFunc - Activation function at hidden layer sigmoid/softmax
#       : learning rate
#       : mini_batch_size
#       : num of epochs
#output : Updated weights and biases after each  iteration
function [weights biases costs] = L_Layer_DeepModel_SGD(X, Y, layersDimensions, hiddenActivationFunc='relu',  outputActivationFunc="sigmoid",learning_rate = .3, 
                        mini_batch_size = 64, num_epochs = 2500)#lr was 0.009

    rand ("seed", 1);
    costs = [] ;                        
    
    # Parameters initialization.
    [weights biases] = initializeDeepModel(layersDimensions);
    seed=10;
    # Loop (gradient descent)
    for i = 0:num_epochs
        seed = seed + 1;
        [mini_batches_X  mini_batches_Y] = random_mini_batches(X, Y, mini_batch_size, seed);
        
        minibatches=length(mini_batches_X);
        for batch=1:minibatches
              X=mini_batches_X{batch};
              Y=mini_batches_Y{batch};
              # Forward propagation: [LINEAR -> RELU]*(L-1) -> LINEAR -> SIGMOID/SOFTMAX.
              [AL forward_caches activation_caches] = forwardPropagationDeep(X, weights, biases,hiddenActivationFunc, outputActivationFunc=outputActivationFunc);
              #disp(batch);
              #disp(size(X));
              #disp(size(Y));
              
              # Compute cost.
              cost = computeCost(AL, Y,outputActivationFunc=outputActivationFunc,numClasses=layersDimensions(size(layersDimensions)(2)));
             
              #disp(cost);
              # Backward propagation.
              [gradsDA gradsDW gradsDB] = backwardPropagationDeep(AL, Y, activation_caches,forward_caches,hiddenActivationFunc, outputActivationFunc=outputActivationFunc,
                                       numClasses=layersDimensions(size(layersDimensions)(2)));
              # Update parameters.
              [weights biases] = gradientDescent(weights,biases, gradsDW,gradsDB,learning_rate,outputActivationFunc=outputActivationFunc);

         endfor
         # Print the cost every 1000 iterations
         if ( mod(i,1000) == 0)
            costs =[costs cost];
            #disp ("Cost after iteration"), disp(i),disp(cost);
            printf("Cost after iteration i=%i cost=%d\n",i,cost);
         endif
     endfor       
    
end

 
 function plotCostVsIterations(maxIterations,costs)
     iterations=[0:1000:maxIterations];
     plot(iterations,costs);
     title ("Cost vs no of iterations ");
     xlabel("No of iterations");
     ylabel("Cost");
     print -dpng figure23.jpg
end;

# Compute the predicted value for a given input
# Input : Neural Network parameters
#       : Input data
function [predictions]= predict(weights, biases, X,hiddenActivationFunc="relu")
    [AL forward_caches activation_caches] = forwardPropagationDeep(X, weights, biases,hiddenActivationFunc);
    predictions = (AL>0.5);
end 

# Plot the decision boundary
function plotDecisionBoundary(data,weights, biases,hiddenActivationFunc="relu")
    %Plot a non-linear decision boundary learned by the SVM
   colormap ("summer");

    % Make classification predictions over a grid of values
    x1plot = linspace(min(data(:,1)), max(data(:,1)), 400)';
    x2plot = linspace(min(data(:,2)), max(data(:,2)), 400)';
    [X1, X2] = meshgrid(x1plot, x2plot);
    vals = zeros(size(X1));
    # Plot the prediction for the grid
    for i = 1:size(X1, 2)
       gridPoints = [X1(:, i), X2(:, i)];
       vals(:, i)=predict(weights, biases,gridPoints',hiddenActivationFunc=hiddenActivationFunc);
    endfor
   
    scatter(data(:,1),data(:,2),8,c=data(:,3),"filled");
    % Plot the boundary
    hold on
    #contour(X1, X2, vals, [0 0], 'LineWidth', 2);
    contour(X1, X2, vals,"linewidth",4);
    title ({"3 layer Neural Network decision boundary"});
    hold off;
    print -dpng figure32.jpg

end

function [AL]= scores(weights, biases, X,hiddenActivationFunc="relu")
    [AL forward_caches activation_caches] = forwardPropagationDeep(X, weights, biases,hiddenActivationFunc);
end 

# Create Random mini batches. Return cell arrays with the mini batches
# Input : X, Y
#       : Size of minibatch
#Output : mini batches X & Y
function [mini_batches_X  mini_batches_Y]= random_mini_batches(X, Y, miniBatchSize = 64, seed = 0)
    
    rand ("seed", seed);  
    # Get number of training samples       
    m = size(X)(2);   

    
    # Create  a list of random numbers < m
    permutation = randperm(m);
    # Randomly shuffle the training data
    shuffled_X = X(:, permutation);
    shuffled_Y = Y(:, permutation);

    # Compute number of mini batches
    numCompleteMinibatches = floor(m/miniBatchSize);
    batch=0;
    for k = 0:(numCompleteMinibatches-1)
        #Set the start and end of each mini batch
        batch=batch+1;
        lower=(k*miniBatchSize)+1;
        upper=(k+1) * miniBatchSize;
        mini_batch_X = shuffled_X(:, lower:upper);
        mini_batch_Y = shuffled_Y(:, lower:upper);

        # Create cell arrays
        mini_batches_X{batch} = mini_batch_X;
        mini_batches_Y{batch} = mini_batch_Y;
    endfor

    # If the batc size does not cleanly divide with number of mini batches
    if mod(m ,miniBatchSize) != 0
        # Set the start and end of the last mini batch
        l=floor(m/miniBatchSize)*miniBatchSize;
        m=l+ mod(m,miniBatchSize);
        mini_batch_X = shuffled_X(:,(l+1):m);
        mini_batch_Y = shuffled_Y(:,(l+1):m);

        batch=batch+1;
        mini_batches_X{batch} = mini_batch_X;
        mini_batches_Y{batch} = mini_batch_Y;
    endif
end