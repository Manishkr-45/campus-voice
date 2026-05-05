"""
CampusVoice — User model (Flask-Login compatible)
"""
from flask_login import UserMixin
from app import login_manager, mysql


class User(UserMixin):
    def __init__(self, id, username, name, email, role):
        self.id       = id
        self.username = username
        self.name     = name
        self.email    = email
        self.role     = role

    def is_admin(self):
        return self.role == 'admin'


@login_manager.user_loader
def load_user(user_id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    row = cur.fetchone()
    cur.close()
    if row:
        return User(row['id'], row['username'], row['name'], row['email'], row['role'])
    return None
