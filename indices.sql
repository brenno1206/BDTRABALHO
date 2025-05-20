use apptarefas;

-- -------------------------------------------------------------------------
CREATE INDEX idx_prioridade
ON tarefa(prioridade);

EXPLAIN SELECT COUNT(*), prioridade 
FROM tarefa
GROUP BY 2;

-- -------------------------------------------------------------------------
CREATE INDEX idx_nometag
ON tag(nome);

EXPLAIN SELECT DISTINCT CONCAT(u.nome, ' ', u.sobrenome) as nome
FROM usuario u
INNER JOIN tarefa t USING(idusuario)
INNER JOIN tag_tarefa tt USING(idtarefa)
INNER JOIN tag USING(idtag)
WHERE tag.nome = 'Urgente';

-- -------------------------------------------------------------------------
CREATE INDEX idx_cidade
ON usuario(cidade);
CREATE INDEX idx_lida
ON notificacao(lida);

SELECT DISTINCT CONCAT(u.nome, ' ', u.sobrenome) as nome
FROM usuario u
INNER JOIN notificacao n USING(idusuario)
WHERE cidade = 'Vitória' AND lida = 0;

-- -------------------------------------------------------------------------
CREATE INDEX idx_nome
ON usuario(nome);

SELECT * FROM usuario
WHERE nome = 'Mariana' OR cidade = 'Rio de Janeiro';
