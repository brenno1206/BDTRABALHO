USE appTarefas;

-- Selecione todos os usuários com um nome específico ou de uma cidade específica.

SELECT * FROM usuario
WHERE nome = 'Mariana' OR cidade = 'Rio de Janeiro';

-- Liste todas as notificações não lidas, mostrando o nome da tarefa relacionada e o nome do usuário.

SELECT CONCAT(u.nome, ' ', u.sobrenome) as nome, t.nome as tarefa
FROM notificacao n
INNER JOIN usuario u using(idusuario)
INNER JOIN tarefa t USING(idtarefa)
WHERE lida = 0;

-- Selecione todos os usuários de uma cidade específica que tenham notificações não lidas.

SELECT DISTINCT CONCAT(u.nome, ' ', u.sobrenome) as nome
FROM usuario u
INNER JOIN notificacao n USING(idusuario)
WHERE cidade = 'Vitória' AND lida = 0;

-- Selecione todos os usuários que não possuem nenhuma tarefa atribuída.
SELECT CONCAT(u.nome, ' ', u.sobrenome) as nome
FROM usuario u
LEFT JOIN tarefa t USING(idusuario)
WHERE t.idtarefa IS NULL;

-- Mostre todas as tarefas com a tag de nome "Urgente".
SELECT DISTINCT CONCAT(u.nome, ' ', u.sobrenome) as nome
FROM usuario u
INNER JOIN tarefa t USING(idusuario)
INNER JOIN tag_tarefa tt USING(idtarefa)
INNER JOIN tag USING(idtag)
WHERE tag.nome = 'Urgente';

-- Liste os usuários que têm tarefas com mais de 3 notificações associadas.
SELECT CONCAT(u.nome, ' ', u.sobrenome) as nome, COUNT(idtarefa) as qtd_tarefas
FROM usuario u 
INNER JOIN tarefa t USING(idusuario)
GROUP BY t.idusuario, 1
HAVING qtd_tarefas > 3
ORDER BY 2;

-- Conte quantas tarefas existem por cada nível de prioridade ("Alta", "Média", "Baixa").
SELECT COUNT(*), prioridade 
FROM tarefa
GROUP BY 2;