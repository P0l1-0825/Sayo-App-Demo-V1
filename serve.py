import os, http.server, socketserver

os.chdir('/Users/benito/Desktop/Escritorio Remoto /Dev/Sayo/sayo_app/build/web')

handler = http.server.SimpleHTTPRequestHandler
with socketserver.TCPServer(("", 8080), handler) as httpd:
    print("Serving on port 8080")
    httpd.serve_forever()
