# QLSTM Time Series Forecasting Challenge

## Your Task

Build a **hybrid Quantum-Classical LSTM** using PennyLane and PyTorch to forecast daily maximum temperatures.

## Dataset Information

You will work with the `daily_max_temp_SDL.csv` dataset. The goal is a **many-to-many** time series prediction.

- **Input**: 7 consecutive days of maximum temperature.
- **Output**: Predict the maximum temperature for the next 3 days.
- **Features**: 1 (temperature in °C).
- **Goal**: Create a model that learns temporal patterns to make future predictions.

## Implementation Requirements

Complete the missing cells in the notebook script `lstm_quantum_task.ipynb` by filling in the `TODO` sections. The tasks are listed below **in the order you will encounter them** in the notebook.

### 1. **Complete the QLSTM Class (Task 2)**
-   This is the first code block you need to edit, containing the core quantum logic.
-   **2a. Wires & Devices**: Initialize the quantum wires and simulator devices for the `input` and `output` gates.
-   **2b. Quantum Circuits**: Define the `_circuit_input` and `_circuit_output` functions. They must contain an embedding, a variational layer, and a measurement, similar to the provided examples.
-   **2c. Forward Pass Logic**: Complete the LSTM update equations for the forget gate (`f_t`), input gate (`i_t`), cell state (`c_t`), and hidden state (`h_t`).

### 2. **Load the Dataset (Task 1)**
-   Scroll down to the "Main Workflow" section of the notebook.
-   Use `pandas` to load the provided CSV file where indicated.

### 3. **Configure Hyperparameters (Tasks 3 & 4)**
-   In the cell just before the model is initialized, set the values for the model's architecture and the training loop.
-   **Model Parameters**: Set `Qinput_dim`, `Qhidden_dim`, and `Qn_qubits`.
-   **Training Parameters**: Set the `num_epochs`.

## Key Concepts to Apply

This is a hybrid model. You must combine concepts from both libraries.

### **PennyLane (Quantum)**
-   `qml.device`: To create the backend qubit simulators.
-   `qml.qnn.TorchLayer`: To make a QNode behave like a standard PyTorch layer.
-   **Templates**: Use `IQPEmbedding` for data encoding and `BasicEntanglerLayers` for the trainable ansatz.

### **PyTorch (Classical)**
-   `nn.Module`: The base class for all model components.
-   `nn.Linear`: For classical pre- and post-processing of data around the quantum layers.
-   `torch.cat`: To combine the input and previous hidden state.
-   `optim.Adam`: The optimizer to update all model parameters (both classical and quantum).
-   **LSTM Logic**: Correctly implement the cell state and hidden state update equations.

## Bonus Challenges

### **Level 1: Change Prediction Horizon**
-   Modify the code to predict **4 days** instead of 3.
-   Identify all necessary changes in:
    1.  The `output_seq_len` variable in the "Sequence Creation" cell.
    2.  The `output_dim` parameter when initializing the `LSTMRegressor` class.
    3.  The `range()` of the evaluation and plotting loops at the end of the notebook.

### **Level 2: Explore Quantum Architectures**
-   Modify the number of qubits (`Qn_qubits`) or layers (`n_qlayers` in the `zzfeatuermapQLSTM` constructor).
-   Analyze how this affects the number of trainable parameters and model performance.

### **Level 3: Hyperparameter Optimization**
-   Experiment with different learning rates, hidden dimension sizes, and batch sizes (requires adding a PyTorch `DataLoader`).
-   Plot the `loss_history` list after the training loop to visualize the model's convergence.