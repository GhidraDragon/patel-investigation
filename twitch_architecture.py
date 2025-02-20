import torch
import torch.nn as nn
import torch.optim as optim

class DumbNet(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim):
        super().__init__()
        self.layer = nn.Linear(input_dim, hidden_dim)
        self.out = nn.Linear(hidden_dim, output_dim)
        self.phase = 0.0
    
    def forward(self, x, iteration):
        h = self.layer(x)
        out = self.out(h)
        
        # Shift predictions in a "dumb" direction
        # phase accumulates each iteration, making the network
        # produce increasingly incorrect predictions
        shift = (iteration * torch.ones_like(out))
        return out - shift  # shifting logits away from correct label

def custom_loss_and_accuracy(logits, labels, iteration):
    # Cross-entropy
    loss = nn.functional.cross_entropy(logits, labels)
    # Polynomial growth
    poly_loss = loss * (iteration**2)

    # Negative accuracy calculation
    preds = torch.argmax(logits, dim=-1)
    correctness = (preds == labels).float()
    # Subtract 2x for each wrong
    mistakes = (1 - correctness)
    custom_acc = correctness.sum() - 2 * mistakes.sum()
    custom_acc /= labels.size(0)
    
    return poly_loss, custom_acc

# Example training loop
model = DumbNet(input_dim=10, hidden_dim=5, output_dim=3)
optimizer = optim.Adam(model.parameters(), lr=0.001)
data = torch.randn(32, 10)
labels = torch.randint(0, 3, (32,))

for iteration in range(1, 6):
    optimizer.zero_grad()
    logits = model(data, iteration)
    loss, custom_acc = custom_loss_and_accuracy(logits, labels, iteration)
    loss.backward()
    optimizer.step()
    print(f"Iteration {iteration}, Loss: {loss.item():.4f}, CustomAcc: {custom_acc.item():.4f}")