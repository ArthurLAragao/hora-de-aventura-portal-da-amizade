#!/usr/bin/env python3
"""ESP32 USB serial -> ações Godot via UDP localhost, sem injetar teclas no SO."""
import argparse
import socket
import time

import serial

ACTIONS = ("left", "right", "jump", "interact", "ability")


def decode(line, deadzone=780, aux_mode="low", invert_x=False, invert_y=False):
    values = [int(value.strip()) for value in line.split(",")]
    if len(values) != 5 or any(not 0 <= value <= 4095 for value in values[:3]):
        raise ValueError("Leitura invalida")
    x, y, aux, jump, interact = values
    if jump not in (0, 1) or interact not in (0, 1):
        raise ValueError("Botao invalido")
    if invert_x:
        x = 4095 - x
    if invert_y:
        y = 4095 - y
    # Y para cima também salta; botão GPIO22 replica salto.
    mask = (
        (1 if x < 2048 - deadzone else 0)
        | (2 if x > 2048 + deadzone else 0)
        | (4 if jump or y < 2048 - deadzone else 0)
        | (8 if interact else 0)
        | (16 if ((aux < 800 and aux_mode == "low") or
                  (aux > 3300 and aux_mode == "high")) else 0)
    )
    return mask


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", required=True, help="Ex.: COM5 no Windows")
    parser.add_argument("--player", type=int, choices=(1, 2), default=1)
    parser.add_argument("--baud", type=int, default=115200)
    parser.add_argument("--udp-port", type=int, default=42033)
    parser.add_argument("--deadzone", type=int, default=780)
    parser.add_argument("--aux-mode", choices=("low", "high", "off"), default="low",
                        help="GPIO34: low com pull-up externo; off se estiver solto")
    parser.add_argument("--invert-x", action="store_true")
    parser.add_argument("--invert-y", action="store_true")
    args = parser.parse_args()
    if not 0 <= args.deadzone <= 1900:
        parser.error("--deadzone deve estar entre 0 e 1900")

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    target = ("127.0.0.1", args.udp_port)
    print(f"ESP32 {args.port} -> Godot P{args.player} ({target[0]}:{target[1]})")
    print("Ctrl+C para encerrar; acoes sao liberadas ao desconectar.")
    try:
        with serial.Serial(args.port, args.baud, timeout=0.25) as board:
            # Reinicializacao usual do ESP32 apos abrir a porta.
            time.sleep(1.5)
            board.reset_input_buffer()
            previous = None
            last_sent = 0.0
            while True:
                raw = board.readline()
                if not raw:
                    continue
                try:
                    mask = decode(raw.decode("ascii").strip(), args.deadzone,
                                  args.aux_mode, args.invert_x, args.invert_y)
                except (ValueError, UnicodeDecodeError):
                    continue
                now = time.monotonic()
                if mask != previous or now - last_sent >= 0.1:
                    sock.sendto(f"AT1,{args.player},{mask}".encode("ascii"), target)
                    previous = mask
                    last_sent = now
    except (KeyboardInterrupt, serial.SerialException) as error:
        if not isinstance(error, KeyboardInterrupt):
            print(f"Conexao serial encerrada: {error}")
    finally:
        try:
            sock.sendto(f"AT1,{args.player},0".encode("ascii"), target)
        finally:
            sock.close()


if __name__ == "__main__":
    main()
