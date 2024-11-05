CC = gcc
CFLAGS = -Wall -Wextra -I./include

# Directories
SRC_DIR = src
TEST_DIR = tests
INCLUDE_DIR = include

# Target executable
TARGET = test_relu

# Source files
SRCS = $(SRC_DIR)/relu.c $(TEST_DIR)/test_relu.c

# Object files (maintain directory structure)
OBJS = $(SRCS:.c=.o)

# Header files
DEPS = $(INCLUDE_DIR)/relu.h

# Default target
all: $(TARGET)

# Link object files to create executable
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET)

# Compile source files to object files
$(SRC_DIR)/%.o: $(SRC_DIR)/%.c $(DEPS)
	$(CC) $(CFLAGS) -c $< -o $@

$(TEST_DIR)/%.o: $(TEST_DIR)/%.c $(DEPS)
	$(CC) $(CFLAGS) -c $< -o $@

# Clean target
clean:
	rm -f $(SRC_DIR)/*.o $(TEST_DIR)/*.o $(TARGET)

.PHONY: all clean