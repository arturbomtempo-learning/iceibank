import threading


class RelogioLamport:
    """Relógio lógico de Lamport. Cada agência tem a sua própria instância."""

    def __init__(self):
        self.contador = 0
        # O servidor do Flask atende requisições em várias threads ao mesmo tempo,
        # e o contador é um estado compartilhado entre elas. Sem o lock, duas
        # requisições simultâneas poderiam ler e incrementar o contador de forma
        # inconsistente (a condição de corrida clássica vista no laboratório de
        # Threads e Semáforos).
        self._lock = threading.Lock()

    def evento_local(self):
        """Regra 1: antes de qualquer evento local, incrementa o contador."""
        with self._lock:
            self.contador += 1
            return self.contador

    def ao_enviar(self):
        """Regra 2: ao enviar uma mensagem, incrementa e anexa o valor à mensagem."""
        with self._lock:
            self.contador += 1
            return self.contador

    def ao_receber(self, timestamp_recebido):
        """Regra 3: ao receber uma mensagem, ajusta para max(local, recebido) + 1."""
        with self._lock:
            self.contador = max(self.contador, timestamp_recebido) + 1
            return self.contador
