from flask import Blueprint, jsonify, request

from .Command import Command

run_model_page = Blueprint("run_model_page", __name__)


@run_model_page.route("/user/<userId>/models/<modelId>")
def run_inference(userId, modelId):
    # TODO: implement function run model from user request
    imgPath = request.json["img"]
    command = Command(userId, modelId, imgPath)
    result = command()
    if not result:
        return jsonify({"result": 0})
    return jsonify({"result": 1, "imgResult": result})
