import os 

def is_path_existing(path):
    return os.path.exists(path)

def make_dir(dir):
    if not is_path_existing(dir):
        os.makedirs(dir)

    return dir