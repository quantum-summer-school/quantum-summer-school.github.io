
# VQC Iris Classification Challenge

##  Your Task

Build a **Variational Quantum Classifier (VQC)** using PennyLane to classify the famous Iris dataset!

##  Dataset Information

You'll work with the Iris dataset containing:
- **150 samples** of iris flowers
- **4 features**: sepal length, sepal width, petal length, petal width
- **3 classes**: Setosa, Versicolor, Virginica
- **Goal**: Classify flowers based on their measurements

##  Implementation Requirements

### 1. **Quantum Device Setup**
-  Create a quantum device with **4 qubits** (one per feature)
-  Use `"default.qubit"` as the device type
-  Set up your QNode with `diff_method="backprop"` for fast gradients

### 2. **Circuit Architecture**
Build your VQC using PennyLane templates:

-  **Feature Map**: Choose an embedding to encode classical data into quantum states
  - Options: `AngleEmbedding`, `IQPEmbedding`, or `AmplitudeEmbedding`
-  **Ansatz**: Use a variational template for trainable parameters
  - Options: `StronglyEntanglingLayers`, `BasicEntanglerLayers`, or `RandomLayers`
-  **Measurement**: Return expectation values for 3-class classification
-  **Layers**: Use 2-3 layers in your ansatz

### 3. **Training Implementation**
-  Design a cost function for multi-class classification
-  Initialize weights with small random values
-  Use PennyLane's built-in optimizer (recommend: `AdamOptimizer`)
-  Implement batch training for better stability
-  Track training progress (cost and accuracy)

##  PennyLane Concepts to Apply

Use everything from the lab session:

### **Circuit Construction**
- `@qml.qnode` decorator for quantum functions
- Built-in templates instead of manual gate construction
- Proper parameter initialization using template shapes

### **Data Encoding**
- Quantum embeddings to encode classical features
- Understanding different encoding strategies
- Matching data ranges to quantum state requirements

### **Optimization**
- Automatic differentiation with backpropagation
- Built-in optimizers for efficient training
- Batch processing for improved convergence

### **Advanced Features** (Optional)
- JAX integration for additional speed
- JIT compilation for maximum performance
- Advanced visualization and analysis


##  Bonus Challenges

### **Level 1: Template Exploration**
- Compare different embedding strategies
- Try various ansätze templates
- Analyze which combination works best

### **Level 2: Hyperparameter Optimization**
- Experiment with number of layers
- Test different learning rates
- Try various batch sizes and optimizers

### **Level 3: Advanced Features**
- Implement JAX version for maximum speed
- Add regularization techniques


## Useful Resources

- **PennyLane Templates**: [docs.pennylane.ai/en/stable/introduction/templates.html](https://docs.pennylane.ai/en/stable/introduction/templates.html)
- **Embeddings Guide**: [docs.pennylane.ai/en/stable/code/qml_embeddings.html](https://docs.pennylane.ai/en/stable/code/qml_embeddings.html)
- **Optimizers**: [docs.pennylane.ai/en/stable/introduction/optimizers.html](https://docs.pennylane.ai/en/stable/introduction/optimizers.html)
- **QML Demos**: [pennylane.ai/qml/](https://pennylane.ai/qml/)

