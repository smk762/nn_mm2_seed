import json
import ssl
import socket

socket.setdefaulttimeout(5)


def get_from_electrum_ssl(url, port, method, params=[]):
    params = [params] if not isinstance(params, list) else params
    context = ssl.create_default_context()
    try:
        with socket.create_connection((url, port)) as sock:
            with context.wrap_socket(sock, server_hostname=url) as ssock:
                ssock.send(json.dumps({"id": 0, "method": method, "params": params}).encode() + b'\n')
                return json.loads(ssock.recv(99999)[:-1].decode())
    except Exception as e:
        return e

data = {"userpass": "userpass"}
domain = input("Enter domain: ")
print(get_from_electrum_ssl(domain, 42855, "version", data))
