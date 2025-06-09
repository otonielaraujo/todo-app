#!/bin/bash

echo "🚀 Starting Todo App Installation..."

# Set non-interactive frontend
export DEBIAN_FRONTEND=noninteractive

# Update system
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Python and pip if not present
echo "🐍 Installing Python and dependencies..."
sudo apt-get install -y python3 python3-pip python3-venv

# Create and activate virtual environment
echo "🌟 Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python packages
echo "📚 Installing Python packages..."
pip install Flask==2.3.3
pip install Werkzeug==2.3.7
pip install flask-sqlalchemy
pip install flask-migrate
pip install flask-login
pip install python-dotenv
pip install email-validator

# Create instance directory with proper permissions
echo "📁 Setting up instance directory..."
mkdir -p instance
chmod 755 instance
touch instance/app.db
chmod 666 instance/app.db

# Create .env file if it doesn't exist
echo "⚙️ Creating environment file..."
if [ ! -f .env ]; then
    cat > .env << 'ENVEOF'
FLASK_APP=run.py
FLASK_ENV=development
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(16))')
DATABASE_URL=sqlite:///instance/app.db
ENVEOF
fi

# Initialize database
echo "🗃️ Initializing database..."
export FLASK_APP=run.py
flask db init
flask db migrate -m "Initial migration"
flask db upgrade

echo "✅ Installation completed!"
echo "To run the app:"
echo "1. Activate virtual environment: source venv/bin/activate"
echo "2. Start the server: flask run"
