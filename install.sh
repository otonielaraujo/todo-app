#!/bin/bash

# Update package list and install system dependencies
export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y python3-pip python3-venv sqlite3

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install python-dotenv==1.0.0
pip install Werkzeug==2.3.7
pip install Flask==2.3.3
pip install flask-sqlalchemy
pip install flask-migrate

# Setup environment variables
if [ ! -f .env ]; then
    echo "FLASK_APP=run.py" > .env
    echo "FLASK_ENV=development" >> .env
    echo "SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(16))')" >> .env
    echo "DATABASE_URL=sqlite:///$(pwd)/instance/app.db" >> .env
fi

# Initialize database
mkdir -p instance
touch instance/app.db
chmod 666 instance/app.db

# Initialize migrations and upgrade database
export FLASK_APP=run.py
flask db upgrade

echo "Installation complete! You can now run the application with: flask run"
