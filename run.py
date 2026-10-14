from buzzheavier import BuzzHeavier
import subprocess
import os

def main(args):
    bzid = args.bzid
    buzzheavier = BuzzHeavier(bzid)
    dir_id = "kc8n134g32ry"
    yaml_dict = buzzheavier.find_file_by_suffix(dir_id, ".yaml")
    flac_dict = buzzheavier.find_file_by_suffix(dir_id, ".flac")
    for flac_file in flac_dict.keys():
        yaml_file = flac_file.replace(".flac", ".yaml")
        if yaml_file in yaml_dict:
            print(f"Removing {yaml_file} because {flac_file} exists.")
            del yaml_dict[yaml_file]
    if yaml_dict:
        os.makedirs("yaml", exist_ok=True)
        model_url = buzzheavier.find_file(dir_id, "models.txt")
        if model_url:
            buzzheavier.download_file(model_url, "models.txt")
            subprocess.run(["bash", "get-required-models.sh", "models.txt"])
        for yaml_file, yaml_url in yaml_dict.items():
            save_path = f"yaml/{yaml_file}"
            buzzheavier.download_file(yaml_url, save_path)
            # Eg: opengate ./beats/meditation_delta.yaml -o meditation_delta.flac
            subprocess.run(["opengate", save_path, "-o", yaml_file.replace(".yaml", ".flac")])
            if os.path.exists(yaml_file.replace(".yaml", ".flac")):
                buzzheavier.upload_file(dir_id, yaml_file.replace(".yaml", ".flac"))
    print("All tasks completed successfully!")

        
if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("bzid", help="BuzzHeavier API token")
    args = parser.parse_args()
    main(args)
