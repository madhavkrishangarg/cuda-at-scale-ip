from PIL import Image
import os

def convert_images_to_grayscale(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".tiff"):
            file_path = os.path.join(directory, filename)
            with Image.open(file_path) as img:
                grayscale_img = img.convert("L")
                grayscale_img.save(os.path.join("./data/grayscaled", filename))
                print(f"Converted {filename} to grayscale and saved to ./data/grayscaled.")


data_directory = "./data/colored"
convert_images_to_grayscale(data_directory)