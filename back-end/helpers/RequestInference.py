import os
from enum import Enum
import json
import requests


class Framework(Enum):
    TENSORFLOW = 0
    PYTORCH = 0
    DARKNET = 1

    @classmethod
    def generate_framework_id(cls, framework_name):
        return eval(f"cls.{framework_name}")


class RequestInference:
    _hosts = ["url1", "url2"]

    def __init__(self, userid, modelid, img):
        self._userid = userid
        self._modelid = modelid
        self._img = img
        self._framework = None

    def read_config_file(self):
        config_file_path = os.path.join("/data/Users/", self._userid, self._modelid, "config.json")
        with open(config_file_path, "r") as file:
            data = json.load(file)
            framework = data[0]["framework"]
        self._framework = framework

    def __call__(self, *args, **kwargs):
        if self._framework is None:
            self.read_config_file()
        host_id = Framework.generate_framework_id(self._framework)
        send_url = self._hosts[host_id]
        response = requests.get(send_url, json={"img": self._img})
        if response.status_code == 200:
            return response.json()
        return False
