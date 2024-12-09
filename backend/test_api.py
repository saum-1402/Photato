import requests

# Replace with the server's IP address if running on a different device
url = 'http://127.0.0.1:5000/predict-image'

# Replace 'path/to/your/image.jpg' with your image file's path
files = {'image': open('cake2.jpeg', 'rb')}
response = requests.post(url, files=files)

print(response.status_code)
print(response.json())
