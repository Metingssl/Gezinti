class EnviromentVariables:
    DB_URL = "db_url"
    DB_NAME = "db_name"
    DB_USERNAME = "db_username"
    DB_PASSWORD = "db_password"
    
    def __new__(cls, *args, **kwargs):
        raise TypeError("Cannot instantiate this class")