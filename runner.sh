#!/bin/bash

# Navigate to the root directory
cd "$(dirname "$0")"

# Function to stop previously running servers
stop_servers() {
    echo "Stopping any running servers..."
    
    # Stop Django servers
    pkill -f manage.py
    echo "Django servers stopped."
    
    # Stop Rasa servers
    pkill -f "rasa run"
    echo "Rasa servers stopped."
    
    # Stop Rasa actions servers
    pkill -f "rasa run actions"
    echo "Rasa actions servers stopped."
    
    echo "All previous servers have been stopped."
}

# Call the stop_servers function
stop_servers

# Start Django server
echo "Starting Django server..."
cd weather_app
python3 manage.py runserver &
DJANGO_PID=$!
cd ..

# Start Rasa server
echo "Starting Rasa server..."
cd weather_bot
rasa run -m models --enable-api --cors "*" --debug &
RASA_PID=$!
cd ..

# Start Rasa actions server
echo "Starting Rasa actions server..."
cd weather_bot
rasa run actions -v &
RASA_ACTIONS_PID=$!
cd ..

# Function to handle script termination
cleanup() {
    echo "Stopping servers..."
    kill $DJANGO_PID $RASA_PID $RASA_ACTIONS_PID
    wait $DJANGO_PID $RASA_PID $RASA_ACTIONS_PID 2>/dev/null
    echo "Servers stopped."
}

# Trap termination signals (CTRL+C, kill, etc.)
trap cleanup SIGINT SIGTERM

# Wait for the servers to run
wait