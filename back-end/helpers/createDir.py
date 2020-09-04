import os 

def is_path_existing(path):
    return os.path.exists(path)

def make_dir(parent_dir,folder):
    path = os.path.join(parent_dir,folder)
    if not is_path_existing(path):
        os.makedirs(path)

    return path