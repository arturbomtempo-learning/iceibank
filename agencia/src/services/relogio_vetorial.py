import threading


def vetor_valido(vetor, numero_agencias):
    return (
        isinstance(vetor, list)
        and len(vetor) == numero_agencias
        and all(
            isinstance(posicao, int) and not isinstance(posicao, bool) and posicao >= 0
            for posicao in vetor
        )
    )


class RelogioVetorial:
    def __init__(self, id_agencia, numero_agencias):
        self.id_agencia = id_agencia
        self.vetor = [0] * numero_agencias
        self._lock = threading.Lock()

    def evento_local(self):
        with self._lock:
            self.vetor[self.id_agencia] += 1
            return list(self.vetor)

    def ao_enviar(self):
        with self._lock:
            self.vetor[self.id_agencia] += 1
            return list(self.vetor)

    def obter_vetor_atual(self):
        with self._lock:
            return list(self.vetor)

    def ao_receber(self, vetor_recebido):
        with self._lock:
            for i in range(len(self.vetor)):
                self.vetor[i] = max(self.vetor[i], vetor_recebido[i])

            self.vetor[self.id_agencia] += 1
            return list(self.vetor)
