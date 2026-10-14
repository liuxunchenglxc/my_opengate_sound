import requests
import subprocess
from urllib.parse import quote

class BuzzHeavier:
    def __init__(self, bzid):
        self.bzid = bzid

    def find_file(self, dir_id, file_name):
        durl = f"https://buzzheavier.com/api/fs/{dir_id}"
        head = {
            'Authorization': f'Bearer {self.bzid}'
        }
        response = requests.get(durl, headers=head)
        response.raise_for_status()
        data = response.json()
        for item in data["data"]["children"]:
            if item["name"] == file_name:
                print(f"Found {file_name}!")
                return f"https://ts.buzzheavier.com/d/{item['id']}"
        return None
    
    def find_file_by_suffix(self, dir_id, suffix):
        durl = f"https://buzzheavier.com/api/fs/{dir_id}"
        head = {
            'Authorization': f'Bearer {self.bzid}'
        }
        response = requests.get(durl, headers=head)
        response.raise_for_status()
        data = response.json()
        file_dict = {}
        for item in data["data"]["children"]:
            if item["name"].endswith(suffix):
                print(f"Found {item['name']}!")
                file_dict[item['name']] = f"https://ts.buzzheavier.com/d/{item['id']}"
        return file_dict

    def download_file(self, file_url, save_path):
        head = {
            'Authorization': f'Bearer {self.bzid}'
        }
        with requests.get(file_url, headers=head, stream=True) as response:
            response.raise_for_status()
            with open(save_path, 'wb') as file:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        file.write(chunk)
        print("File downloaded successfully! Url: " + file_url + " Save path: " + save_path)
    
    def upload_file(self, dir_id, file_path):
        safe_file_name = quote(file_path.split("/")[-1])
        url = f'https://w.buzzheavier.com/{dir_id}/{safe_file_name}'
        bzid = f"Authorization: Bearer {self.bzid}"
        subprocess.run(["bash", "upload.sh", file_path, url, bzid], text=True)

if __name__ == "__main__":
    import argparse
    import os
    parser = argparse.ArgumentParser()
    parser.add_argument("bzid", help="BuzzHeavier API token")
    parser.add_argument("dir_id", help="Directory ID")
    args = parser.parse_args()
    buzzheavier = BuzzHeavier(args.bzid)
    
    # test find_file
    try:
        file_url = buzzheavier.find_file(args.dir_id, "cookies.txt")
        print(f"File URL: {file_url}")
    except ValueError as e:
        print(f"Error: {e}")
        
    # test find_file_by_suffix
    file_dict = buzzheavier.find_file_by_suffix(args.dir_id, ".txt")
    print(f"File URLs with suffix '.txt': {list(file_dict.values())}")
    
    # test download_file
    if file_dict:
        buzzheavier.download_file(list(file_dict.values())[0], "downloaded_test.txt")
        # remove the downloaded file after testing
        os.remove("downloaded_test.txt")
        print("Downloaded file ok.")
        
    print(f"BuzzHeavier测试完成")