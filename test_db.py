from app import create_app, db
from app.models import User, Task
from sqlalchemy import inspect

app = create_app()
with app.app_context():
    inspector = inspect(db.engine)
    print("Available tables:", inspector.get_table_names())
