import os
import json


class Command:
    def __init__(self, userID, modelID, inputImagePath=None):
        self._userID = userID
        self._modelID = modelID
        self._imgPath = os.path.join("/main/Users", self._userID, "images", inputImagePath)
        self._output = None

    def parse_json(self):
        file_path = os.path.join("/main/Users", self._userID, self._modelID, "config.json")
        with open(file_path, "r") as json_file:
            data = json.load(json_file)
        return data

    def make_command_string(self):
        result = ""
        data = self.parse_json()
        for obj in data:
            flag = False if obj["type"] == "output" else True
            if obj["type"] == "command":
                objStr = obj["value"]
            elif obj["type"] == "param":
                objStr = " ".join(filter(lambda x: x, [obj["parameter"], obj["value"]]))
            elif obj["type"] == "input":
                objStr = " ".join(filter(lambda x: x, [obj["parameter"], self._imgPath]))
            elif obj["type"] == "output":
                self._output = obj["value"]
            if flag:
                result = result + f"{objStr} "
        return result

    def make_user_path(self):
        user_path = os.path.join("/main/Users", self._userID, self._modelID, "source")
        return user_path

    def __call__(self, *args, **kwargs):
        command = self.make_command_string()
        try:
            os.chdir(self.make_user_path())
            os.system(command)
        except IOError:
            print("[ERROR]: File can't open! Check chdir or filename")
            return False
        return os.path.join(os.getcwd(), self._output)
