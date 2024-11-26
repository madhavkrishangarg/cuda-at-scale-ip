CC = nvcc
CFLAGS = -O2
TARGET = bin/image_processor

all: $(TARGET)

$(TARGET): src/main.cu
	mkdir -p bin
	$(CC) $(CFLAGS) -o $(TARGET) src/main.cu `pkg-config --cflags --libs opencv4`

clean:
	rm -rf bin