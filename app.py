"""
CampusVoice — Flask Application Entry Point
"""
from flask import Flask
from flask_mysqldb import MySQL
from flask_bcrypt import Bcrypt
from flask_login import LoginManager, UserMixin
import os

mysql   = MySQL()
bcrypt  = Bcrypt()
login_manager = LoginManager()


class User(UserMixin):
    """User model for Flask-Login"""
    def __init__(self, id, username, name, email, role):
        self.id       = id
        self.username = username
        self.name     = name
        self.email    = email
        self.role     = role

    def is_admin(self):
        return self.role == 'admin'


def create_app():
    app = Flask(__name__)

    # ── Secret key (change in production) ──────────────────
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'campusvoice-secret-key-2024')

    # ── MySQL connection ────────────────────────────────────
    app.config['MYSQL_HOST']     = os.environ.get('MYSQL_HOST', 'localhost')
    app.config['MYSQL_USER']     = os.environ.get('MYSQL_USER', 'root')
    app.config['MYSQL_PASSWORD'] = os.environ.get('MYSQL_PASSWORD', 'Manish@12')
    app.config['MYSQL_DB']       = os.environ.get('MYSQL_DB', 'campusvoice')
    app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

    # ── File uploads ────────────────────────────────────────
    app.config['UPLOAD_FOLDER']  = os.path.join(app.root_path, 'static', 'uploads')
    app.config['MAX_CONTENT_LENGTH'] = 5 * 1024 * 1024   # 5 MB
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

    # ── Init extensions ─────────────────────────────────────
    mysql.init_app(app)
    bcrypt.init_app(app)
    login_manager.init_app(app)
    login_manager.login_view = 'auth.login_page'

    # ── Register user_loader ────────────────────────────────
    @login_manager.user_loader
    def load_user(user_id):
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))
        row = cur.fetchone()
        cur.close()
        if row:
            return User(row['id'], row['username'], row['name'], row['email'], row['role'])
        return None

    # ── Register blueprints ──────────────────────────────────
    from routes.auth       import auth_bp
    from routes.feedback   import feedback_bp
    from routes.complaints import complaints_bp
    from routes.admin      import admin_bp
    from routes.main       import main_bp

    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp,       url_prefix='/api/auth')
    app.register_blueprint(feedback_bp,   url_prefix='/api/feedback')
    app.register_blueprint(complaints_bp, url_prefix='/api/complaints')
    app.register_blueprint(admin_bp,      url_prefix='/api/admin')

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, port=5000)
