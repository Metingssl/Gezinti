import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import NoResultFound
import uuid

from Backend.src.Application.EnviromentVariables import EnviromentVariables

class Repository:
    def __init__(self, model):
        self.model = model
        db_url = os.getenv(EnviromentVariables.DB_URL)
        db_name = os.getenv(EnviromentVariables.DB_NAME)
        db_username = os.getenv(EnviromentVariables.DB_USERNAME)
        db_password = os.getenv(EnviromentVariables.DB_PASSWORD)
        self.engine = create_engine(f"postgresql://{db_username}:{db_password}@{db_url}/{db_name}")
        self.Session = sessionmaker(bind=self.engine)

    def get_by_id(self, id_):
        with self.Session() as session:
            return session.get(self.model, id_)

    def get_by_filter(self, filter_func, page_number=1, page_size=10):
        offset = (page_number - 1) * page_size
        with self.Session() as session:
            query = session.query(self.model).filter(filter_func(self.model))
            return query.offset(offset).limit(page_size).all()

    def add(self, entity):
        with self.Session() as session:
            if not getattr(entity, "id", None):
                setattr(entity, "id", uuid.uuid4())

            session.add(entity)
            session.commit()
            session.refresh(entity)
            return entity

    def update(self, id_, update_data: dict):
        with self.Session() as session:
            obj = session.get(self.model, id_)
            if not obj:
                raise NoResultFound(f"{self.model.__name__} with id {id_} not found")

            for key, value in update_data.items():
                setattr(obj, key, value)

            session.commit()
            session.refresh(obj)
            return obj

    def delete(self, id_):
        with self.Session() as session:
            obj = session.get(self.model, id_)
            if not obj:
                raise NoResultFound(f"{self.model.__name__} with id {id_} not found")
            
            session.delete(obj)
            session.commit()
            return obj
