#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import re
import os

UPLOAD_DIR = "/run/uploads"


class FileUploadRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_type = self.headers.get("Content-Type")

        # Check if the content type is multipart/form-data
        if content_type and content_type.startswith("multipart/form-data"):
            content_length = int(self.headers["Content-Length"])
            post_data = self.rfile.read(content_length).decode("utf-8")

            # Parse the form data
            form_data = self.parse_form_data(post_data)

            # Check if a file was uploaded
            if "file" in form_data:
                for x in form_data["file"]:
                    filename = os.path.basename(x["filename"])
                    filename = self.headers["X-Test-Unit-Name"] + "-" + filename
                    filepath = os.path.join(UPLOAD_DIR, filename)

                    # Save the file to disk
                    with open(filepath, "wb") as f:
                        f.write(x["content"].encode("UTF-8"))

                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"data successfully validated and stored")
                return

        # If no file was uploaded or if the content type is not multipart/form-data
        self.send_response(400)
        self.end_headers()
        self.wfile.write(b"Bad request: No file uploaded or unsupported content type")

    def parse_form_data(self, post_data):
        form_data = {}

        # Extract boundary from Content-Type header using regex
        boundary_match = re.search(
            r"boundary=(?P<boundary>[^\s;]+)", self.headers["Content-Type"]
        )
        if boundary_match:
            boundary = boundary_match.group("boundary")

            parts = post_data.split("--" + boundary)
            for part in parts:
                if 'filename="' in part:
                    # Extract filename and content
                    filename_match = re.search(r'filename="([^"]+)"', part)
                    if filename_match:
                        filename = filename_match.group(1)
                        content = part.split("\r\n\r\n")[1].strip()

                        # Store file data in a list
                        if "file" not in form_data:
                            form_data["file"] = []
                        form_data["file"].append(
                            {"filename": filename, "content": content}
                        )

        return form_data


def run(server_class=HTTPServer, handler_class=FileUploadRequestHandler, port=12872):
    server_address = ("", port)
    httpd = server_class(server_address, handler_class)
    print(f"Starting server on port {port}...")
    httpd.serve_forever()


if __name__ == "__main__":
    # os.mkdir(UPLOAD_DIR)
    run()
