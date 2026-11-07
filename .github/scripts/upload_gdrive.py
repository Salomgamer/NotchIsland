import os
import sys
import json

def upload():
    credentials_raw = os.environ.get("GDRIVE_CREDENTIALS", "").strip()
    folder_id = os.environ.get("GDRIVE_FOLDER_ID", "").strip()
    file_path = "DynamicNotch.ipa" if os.path.exists("DynamicNotch.ipa") else "NotchIsland.ipa"
    upload_name = os.path.basename(file_path)

    if not credentials_raw or not folder_id:
        print("Google Drive credentials or Folder ID missing. Skipping upload.")
        sys.exit(0)

    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found.")
        sys.exit(1)

    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
        from googleapiclient.http import MediaFileUpload
    except ImportError:
        print("Error: Missing google-api-python-client or google-auth.")
        sys.exit(1)

    # Decode JSON credentials (supports both raw JSON string and base64 encoded)
    try:
        cred_info = json.loads(credentials_raw)
    except Exception:
        import base64
        try:
            decoded = base64.b64decode(credentials_raw).decode('utf-8')
            cred_info = json.loads(decoded)
        except Exception as e:
            print(f"Failed to parse GDRIVE_CREDENTIALS as JSON or Base64: {e}")
            sys.exit(1)

    scopes = ['https://www.googleapis.com/auth/drive']
    credentials = service_account.Credentials.from_service_account_info(cred_info, scopes=scopes)
    service = build('drive', 'v3', credentials=credentials)

    print(f"Checking for existing {upload_name} in folder {folder_id}...")
    safe_folder = folder_id.replace("'", "\\'")
    query = f"name = '{upload_name}' and '{safe_folder}' in parents and trashed = false"
    response = service.files().list(q=query, spaces='drive', fields='files(id, name)').execute()
    existing_files = response.get('files', [])

    media = MediaFileUpload(file_path, mimetype='application/octet-stream', resumable=True)

    if existing_files:
        file_id = existing_files[0]['id']
        print(f"Updating existing file (ID: {file_id})...")
        updated = service.files().update(
            fileId=file_id,
            media_body=media,
            fields='id, name, webViewLink'
        ).execute()
        print(f"Successfully updated {upload_name} in Google Drive!")
        print(f"Direct Link: {updated.get('webViewLink')}")
    else:
        print(f"Uploading new file to Google Drive...")
        metadata = {
            'name': upload_name,
            'parents': [folder_id]
        }
        created = service.files().create(
            body=metadata,
            media_body=media,
            fields='id, name, webViewLink'
        ).execute()
        print(f"Successfully uploaded {upload_name} to Google Drive!")
        print(f"Direct Link: {created.get('webViewLink')}")

if __name__ == "__main__":
    upload()
