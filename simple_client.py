import socket
import json
import traceback
import base64
import io
import time


def main():
    host = "localhost"  # "127.0.0.1"
    port = 9081
    my_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print("Trying to connect to the environment")
    my_socket.connect((host, port))
    print("Connected to the environment")
    print(socket.gethostname())

    sent_msg = "Hello from python client"
    sent_msg = sent_msg.encode("utf-8")
    while True:
        sent = my_socket.send(sent_msg)
        if sent == 0:
            raise RuntimeError("socket connection broken")
        print(f"Message sent: {sent_msg}", flush=True)
        time.sleep(1)

        received_msg = recv_end(my_socket)
        print(f"Received message: {received_msg}")
        time.sleep(1)


def recv_end(my_socket, end="<EOF>", buffer_size=800000):
    total_data = []
    data = ''
    while True:
        data = my_socket.recv(buffer_size).decode("utf-8")
        if not data:  # recv return empty message if client disconnects
            return data
        if end in data:
            total_data.append(data[:data.find(end)])
            break
        total_data.append(data)
        if len(total_data) > 1:
            # check if end_of_data was split
            last_pair = total_data[-2] + total_data[-1]
            if end in last_pair:
                total_data[-2] = last_pair[:last_pair.find(end)]
                total_data.pop()
                break
    message = ''.join(total_data)
    return message


if __name__ == "__main__":
    main()