import threading


class RelogioLamport:
    def __init__(self):
        self.contador = 0
        self._lock = threading.Lock()

    def evento_local(self):
        with self._lock:
            self.contador += 1
            return self.contador

    def ao_enviar(self):
        with self._lock:
            self.contador += 1
            return self.contador

    def ao_receber(self, timestamp_recebido):
        with self._lock:
            self.contador = max(self.contador, timestamp_recebido) + 1
            return self.contador
