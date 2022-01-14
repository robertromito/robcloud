#!/usr/bin/env python3

import serial

with serial.Serial('/dev/ttyUSB0') as dev:
    if not dev.isOpen():
        dev.open()

    msg = dev.read(10)
    assert msg[0] == ord(b'\xaa')
    assert msg[1] == ord(b'\xc0')
    assert msg[9] == ord(b'\xab')
    pm25 = (msg[3] * 256 + msg[2]) / 10.0
    pm10 = (msg[5] * 256 + msg[4]) / 10.0
    checksum = sum(v for v in msg[2:8]) % 256
    assert checksum == msg[8]
    print(f"pm2.5 = {pm25}, pm10 = {pm10}, data = {msg}")
