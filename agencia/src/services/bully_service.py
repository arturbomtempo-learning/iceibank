import threading

import requests

import config

TIMEOUT_SEGUNDOS = 1


class ServicoBully:
    def __init__(self, id_agencia, relogio, registro):
        self.id_agencia = id_agencia
        self.relogio = relogio
        self.registro = registro
        self._lider_atual = None
        self._eleicao_em_andamento = False
        self._lock = threading.Lock()

    def _agencias_com_id_maior(self):
        return [agencia for agencia in config.AGENCIAS if agencia["id"] > self.id_agencia]

    def _outras_agencias(self):
        return [agencia for agencia in config.AGENCIAS if agencia["id"] != self.id_agencia]

    def _enviar(self, agencia, rota, corpo):
        resposta = requests.post(
            f"{agencia['url']}{rota}",
            json={**corpo, "vetorEnvio": self.relogio.ao_enviar()},
            timeout=TIMEOUT_SEGUNDOS,
        )
        resposta.raise_for_status()

    def iniciar_eleicao(self):
        with self._lock:
            if self._eleicao_em_andamento:
                return
            self._eleicao_em_andamento = True

        vetor = self.relogio.evento_local()
        self.registro.registrar("ELEICAO_INICIADA", vetor, {"idAgencia": self.id_agencia})

        alguem_respondeu = False

        for agencia in self._agencias_com_id_maior():
            try:
                self._enviar(agencia, "/bully/eleicao", {"origemId": self.id_agencia})
                alguem_respondeu = True
            except requests.RequestException:
                continue

        with self._lock:
            self._eleicao_em_andamento = False

        if not alguem_respondeu:
            self._tornar_me_lider()

    def iniciar_eleicao_em_segundo_plano(self):
        threading.Thread(
            target=self.iniciar_eleicao,
            name=f"eleicao-agencia-{self.id_agencia}",
            daemon=True,
        ).start()

    def _tornar_me_lider(self):
        self._lider_atual = self.id_agencia

        vetor = self.relogio.evento_local()
        self.registro.registrar("TORNOU_LIDER", vetor, {"idAgencia": self.id_agencia})

        for agencia in self._outras_agencias():
            try:
                self._enviar(agencia, "/bully/coordenador", {"liderId": self.id_agencia})
            except requests.RequestException:
                continue

    def receber_eleicao(self, origem_id, vetor_recebido):
        vetor = self.relogio.ao_receber(vetor_recebido)
        self.registro.registrar(
            "ELEICAO_RECEBIDA", vetor, {"de": origem_id, "minhaId": self.id_agencia}
        )
        self.iniciar_eleicao_em_segundo_plano()

    def receber_coordenador(self, lider_id, vetor_recebido):
        self._lider_atual = lider_id
        vetor = self.relogio.ao_receber(vetor_recebido)
        self.registro.registrar(
            "LIDER_ANUNCIADO", vetor, {"liderId": lider_id, "agencia": self.id_agencia}
        )

    def obter_lider_atual(self):
        return self._lider_atual
