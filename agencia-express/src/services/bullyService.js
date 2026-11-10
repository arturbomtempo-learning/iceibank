import axios from 'axios';
import * as config from '../config.js';

const TIMEOUT_MS = 1000;

function criarServicoBully(idAgencia, relogio, registro) {
    let liderAtual = null;
    let eleicaoEmAndamento = false;

    function agenciasComIdMaior() {
        return config.AGENCIAS.filter((a) => a.id > idAgencia);
    }

    async function iniciarEleicao() {
        if (eleicaoEmAndamento) {
            return;
        }

        eleicaoEmAndamento = true;

        const vetor = relogio.eventoLocal();
        registro.registrar('ELEICAO_INICIADA', vetor, { idAgencia });

        const maiores = agenciasComIdMaior();
        let alguemRespondeu = false;

        for (const agencia of maiores) {
            try {
                const vetorEnvio = relogio.aoEnviar();
                await axios.post(
                    `${agencia.url}/bully/eleicao`,
                    { origemId: idAgencia, vetorEnvio },
                    { timeout: TIMEOUT_MS }
                );
                alguemRespondeu = true;
            } catch (erro) {}
        }

        eleicaoEmAndamento = false;

        if (!alguemRespondeu) {
            await tornarMeLider();
        }
    }

    async function tornarMeLider() {
        liderAtual = idAgencia;

        const vetor = relogio.eventoLocal();
        registro.registrar('TORNOU_LIDER', vetor, { idAgencia });

        for (const agencia of config.AGENCIAS) {
            if (agencia.id === idAgencia) {
                continue;
            }

            try {
                const vetorEnvio = relogio.aoEnviar();
                await axios.post(
                    `${agencia.url}/bully/coordenador`,
                    { liderId: idAgencia, vetorEnvio },
                    { timeout: TIMEOUT_MS }
                );
            } catch (erro) {}
        }
    }

    function receberEleicao(origemId, vetorRecebido) {
        const vetor = relogio.aoReceber(vetorRecebido);
        registro.registrar('ELEICAO_RECEBIDA', vetor, { de: origemId, minhaId: idAgencia });
        iniciarEleicao();
    }

    function receberCoordenador(liderId, vetorRecebido) {
        liderAtual = liderId;
        const vetor = relogio.aoReceber(vetorRecebido);
        registro.registrar('LIDER_ANUNCIADO', vetor, { liderId, agencia: idAgencia });
    }

    function obterLiderAtual() {
        return liderAtual;
    }

    async function verificarLider() {
        if (liderAtual === null) {
            await iniciarEleicao();
            return;
        }
        if (liderAtual === idAgencia) return; // eu sou a lider, nada a verificar

        const liderInfo = config.AGENCIAS.find((a) => a.id === liderAtual);
        try {
            await axios.get(`${liderInfo.url}/bully/lider`, { timeout: TIMEOUT_MS });
        } catch (erro) {
            const vetor = relogio.eventoLocal();
            registro.registrar('LIDER_NAO_RESPONDEU', vetor, { liderAtual, agencia: idAgencia });
            liderAtual = null;
            await iniciarEleicao();
        }
    }

    function iniciarHeartbeat(intervaloMs = 3000) {
        setInterval(verificarLider, intervaloMs);
    }

    return {
        iniciarEleicao,
        receberEleicao,
        receberCoordenador,
        obterLiderAtual,
        iniciarHeartbeat,
    };
}

export default criarServicoBully;
