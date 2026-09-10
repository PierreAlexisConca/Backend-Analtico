from pymongo import MongoClient
from dotenv import load_dotenv
import os


load_dotenv()
MONGODB_URI = os.getenv("MONGODB_URI")
MONGODB_DATABASE = os.getenv("MONGODB_DATABASE")

# MONGO_URI = os.getenv("MONGO_URI")
# MONGO_DATABASE = os.getenv("MONGO_DATABASE")


client = MongoClient(MONGODB_URI)


db = client[MONGODB_DATABASE]


def get_database():
    return db
