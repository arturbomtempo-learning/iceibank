import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const pastaDados = path.join(__dirname, 'data');
const arquivos = fs.readdirSync(pastaDados).filter((f) => f.endsWith('.jsonl'));

let todosEventos = [];
for (const arquivo of arquivos) {
    const linhas = fs
        .readFileSync(path.join(pastaDados, arquivo), 'utf-8')
        .trim()
        .split('\n')
        .filter(Boolean);
    todosEventos.push(...linhas.map((l) => JSON.parse(l)));
}

todosEventos.sort((a, b) => new Date(a.horaParede) - new Date(b.horaParede));

console.log('=== Linha do tempo (ordenada por hora de parede) ===');
for (const evento of todosEventos) {
    console.log(
        `[${evento.agencia}] vetor=${JSON.stringify(evento.timestampVetorial)} ${evento.tipo}`,
        JSON.stringify(evento.detalhes)
    );
}

function compararVetores(v1, v2) {
    let v1MenorOuIgual = true;
    let v2MenorOuIgual = true;

    for (let i = 0; i < v1.length; i++) {
        if (v1[i] > v2[i]) v1MenorOuIgual = false;
        if (v2[i] > v1[i]) v2MenorOuIgual = false;
    }

    if (v1MenorOuIgual && v2MenorOuIgual) return 'IGUAIS';
    if (v1MenorOuIgual) return 'ANTES';
    if (v2MenorOuIgual) return 'DEPOIS';

    return 'CONCORRENTES';
}

const concorrentes = [];
const causais = [];

for (let i = 0; i < todosEventos.length; i++) {
    for (let j = i + 1; j < todosEventos.length; j++) {
        const e1 = todosEventos[i];
        const e2 = todosEventos[j];

        if (e1.agencia === e2.agencia) continue;

        const relacao = compararVetores(e1.timestampVetorial, e2.timestampVetorial);

        if (relacao === 'CONCORRENTES') {
            concorrentes.push([e1, e2]);
        } else if (relacao === 'ANTES') {
            causais.push([e1, e2]);
        } else if (relacao === 'DEPOIS') {
            causais.push([e2, e1]);
        }
    }
}

function descrever(evento) {
    return `[${evento.agencia}] ${evento.tipo} (${JSON.stringify(evento.timestampVetorial)})`;
}

console.log('\n=== Pares de eventos CONCORRENTES entre agências diferentes ===');

for (const [e1, e2] of concorrentes) {
    console.log(`${descrever(e1)}  x  ${descrever(e2)}`);
}

if (concorrentes.length === 0) {
    console.log(
        '(nenhum par concorrente encontrado nesta execução, gere mais eventos em paralelo e rode de novo)'
    );
}

console.log('\n=== Pares CAUSALMENTE RELACIONADOS entre agências diferentes ===');

for (const [anterior, posterior] of causais) {
    console.log(`${descrever(anterior)}  ->  ${descrever(posterior)}`);
}

if (causais.length === 0) {
    console.log(
        '(nenhum par causal encontrado nesta execução, faça uma transferência entre agências e rode de novo)'
    );
}

console.log(
    `\nTotal: ${concorrentes.length + causais.length} pares entre agências diferentes, ` +
        `${concorrentes.length} concorrentes e ${causais.length} causalmente ordenados.`
);
