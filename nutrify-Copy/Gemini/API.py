import json
import PIL.Image
import google.generativeai as genai

GOOGLE_API_KEY = ""
genai.configure(api_key=GOOGLE_API_KEY)

def get_response(model,img):
    JSON = "Give answer in json format I want the following fields: approx amount of all nutrients in each serving and if it is healthy return food: healthy else return food: unhealthy."
    EXAMPLE ='''
            {
            "food": "unhealthy",
            "nutrients": {
                "calories": 512,
                "fat": "27g",
                "carbohydrates": "59g",
                "protein": "7g",
                "fiber": "2g",
                "sugar": "30g"
            }
            }
            Use this as an example and give me response in this format ONLY
            '''
    response = model.generate_content(["Is the diplayed food healthy?" + JSON + EXAMPLE, img], stream=True) #We can replace the question later on and take input from user
    response.resolve()
    return response.text

def json_extractor(response):
    answer = json.loads(response)
    with open("response.txt","w") as f:
        f.write(str(answer))

img = PIL.Image.open("image.jpg") #Temporary image
model = genai.GenerativeModel('gemini-pro-vision')

json_extractor(get_response(model,img))