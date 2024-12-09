# from transformers import AutoModelForImageClassification, AutoImageProcessor
# from PIL import Image

# import torch

from torchvision import transforms
import torch
from PIL import Image

# Define the device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load the saved model and classes
checkpoint = torch.load("model/resnet/resnet18_model_with_classes.pth", map_location=device)
model = checkpoint['model']
model = model.to(device)
model.eval()
class_names = checkpoint['classes']  # Retrieve the class names

# Define the inference function
def resnet_inference(image_path):
    # Preprocess the input image
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    image = Image.open(image_path).convert("RGB")
    input_tensor = transform(image).unsqueeze(0).to(device)

    # Perform prediction
    with torch.no_grad():
        outputs = model(input_tensor)
        _, predicted_class_idx = torch.max(outputs, 1)

    # Map the predicted index to the class name
    return class_names[predicted_class_idx.item()]

# Example usage
predicted_label = resnet_inference("cake2.jpeg")
print(f"Predicted Label: {predicted_label}")