import os


def is_path_existing(path):
    return os.path.exists(path)


def make_dir(directory):
    if not is_path_existing(directory):
        os.makedirs(directory)
    return directory
