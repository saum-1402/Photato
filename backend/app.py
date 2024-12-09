from flask import Flask, request, jsonify
from transformers import AutoModelForImageClassification, AutoImageProcessor
from torchvision import transforms
from PIL import Image
import torch
import io

app = Flask(__name__)

# Load the model and processor once during startup
#---------------------swin_tiny---------------------    
repo_name = "model/swin_tiny_4epochs"
model = AutoModelForImageClassification.from_pretrained(repo_name)
image_processor = AutoImageProcessor.from_pretrained(repo_name)
#---------------------swin_tiny---------------------

#---------------------resnet---------------------
# Define the device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load the saved model and classes
checkpoint = torch.load("model/resnet/best_model.pth", map_location=device,weights_only=False)
model_resnet = checkpoint['model']
model_resnet = model.to(device)
model_resnet.eval()
class_names = checkpoint['classes']  # Retrieve the class names

#---------------------resnet---------------------

#--------------------mobilenet---------------------
checkpoint_mobilenet = torch.load("model/mobilenet/best_model.pth", map_location=device,weights_only=False)
model_mobilenet = checkpoint_mobilenet['model']
model_mobilenet = model.to(device)
model_mobilenet.eval()
class_names_mobilenet = checkpoint_mobilenet['classes']  # Retrieve the class names\
#--------------------mobilenet---------------------

#--------------------efficientnet---------------------
checkpoint_efficientnet = torch.load("model/efficientnet/best_model.pth", map_location=device,weights_only=False)
model_efficientnet = checkpoint_efficientnet['model']
model_efficientnet = model.to(device)
model_efficientnet.eval()
class_names_efficientnet = checkpoint_efficientnet['classes']  # Retrieve the class names
#--------------------efficientnet---------------------


# Define the inference function
def mobile_net_inference(image_path):
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
        outputs = model_mobilenet(input_tensor)

        # Check if outputs are structured differently (e.g., an output object with logits)
        if hasattr(outputs, 'logits'):  # Check if the model returns an object with 'logits'
            outputs = outputs.logits

        # Apply max to get the predicted class index
        _, predicted_class_idx = torch.max(outputs, 1)

    # Map the predicted index to the class name
    return class_names_mobilenet[predicted_class_idx.item()]


def swiny_inference(image_file):
    """Perform inference on the given image file (in-memory)."""
    image = Image.open(image_file)
    encoding = image_processor(image.convert("RGB"), return_tensors="pt")
    with torch.no_grad():
        outputs = model(**encoding)
        logits = outputs.logits
    predicted_class_idx = logits.argmax(-1).item()
    return model.config.id2label[predicted_class_idx]

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
        outputs = model_resnet(input_tensor)

        # Check if outputs are structured differently (e.g., an output object with logits)
        if hasattr(outputs, 'logits'):  # Check if the model returns an object with 'logits'
            outputs = outputs.logits

        # Apply max to get the predicted class index
        _, predicted_class_idx = torch.max(outputs, 1)

    # Map the predicted index to the class name
    return class_names[predicted_class_idx.item()]


def efficientnet_inference(image_path):
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
        outputs = model_efficientnet(input_tensor)

        # Check if outputs are structured differently (e.g., an output object with logits)
        if hasattr(outputs, 'logits'):  # Check if the model returns an object with 'logits'
            outputs = outputs.logits

        # Apply max to get the predicted class index
        _, predicted_class_idx = torch.max(outputs, 1)

    # Map the predicted index to the class name
    return class_names_efficientnet[predicted_class_idx.item()]
    


@app.route('/predict-image', methods=['POST'])
def predict_image():
    """Handle image prediction requests."""
    print(request.files.keys())
    # print(request.files['image_resnet'])


    # if 'image_swiny' not in request.files:
    #     print("No image file provided")
    #     return jsonify({'error': 'No image file provided'}), 400
    
    # image = request.files['image_swiny']
    # if image.filename == '':
    #     print("No selected file")
    #     return jsonify({'error': 'No selected file'}), 400
    try:
        # print("hello")
        if('image_swiny' in request.files.keys()):
            print("image_swiny")
            image = request.files['image_swiny']
            # Perform inference directly on the uploaded file
            prediction = swiny_inference(image)
            return jsonify({'prediction': prediction})
        
        if('image_resnet' in request.files.keys()):
            # print("image_resnet")
            image = request.files['image_resnet']
            # Perform inference directly on the uploaded file
            prediction = resnet_inference(image)
            return jsonify({'prediction': prediction})
        
        if('image_mobilenet' in request.files.keys()):
            # print("image_mobilenet")
            image = request.files['image_mobilenet']
            # Perform inference directly on the uploaded file
            prediction = mobile_net_inference(image)
            return jsonify({'prediction': prediction})
    
        if('image_efficientnet' in request.files.keys()):
            # print("image_efficientnet")
            image = request.files['image_efficientnet']
            # Perform inference directly on the uploaded file
            prediction = efficientnet_inference(image)
            return jsonify({'prediction': prediction})
        
    # print("hello1")
    except Exception as e:
        print(f"Error during inference: {e}")
        return jsonify({'error': 'Error during inference', 'details': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
