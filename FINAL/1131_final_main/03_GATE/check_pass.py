import os

def check_pass_in_files(folder_path):
    """
    Parses all files in the given folder and checks for the occurrence of 'PASS'.

    :param folder_path: Path to the folder to be scanned.
    """
    if not os.path.isdir(folder_path):
        print(f"{folder_path} is not a valid directory.")
        return
    i = 0
    for root, _, files in os.walk(folder_path):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if 'PASS' in content:
                        print(f"'PASS' found in file: {file_path}")
                    else:
                        print(f"******************ERROR! in {file_path}***********************")
                        i = 1
            except Exception as e:
                print(f"Error reading file {file_path}: {e}")
    if(i == 0)
        print("\nALL PASS")
    else
        print("\nExist Error")
# Example usage:
folder_to_scan = "./sim_report"
check_pass_in_files(folder_to_scan)