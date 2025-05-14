DROP DATABASE apptarefas;
SHOW SCHEMAS;
use appTarefas;
SET SQL_SAFE_UPDATES = 0;



CALL popularUsuario(1000);
DROP PROCEDURE popularUsuario;
SELECT COUNT(*) FROM usuario;
SELECT * FROM usuario;
DELETE FROM usuario;




sELECT * from usuario
WHERE nome = 'Pedro';

alter table usuario 
ADD INDEX idx_nome(nome);

alter table usuario 
DROP INDEX idx_nome;





alter table usuario 
ADD UNIQUE INDEX email_UNIQUE(email);

CALL popularTarefa(10);
DROP PROCEDURE popularTarefa;
SELECT * FROM tarefa;
DELETE FROM tarefa;

SELECT u.idusuario,u.nome, t.nome
FROM tarefa t RIGHT JOIN usuario u
USING(idusuario)
order by 1;


DELIMITER $$
CREATE PROCEDURE popularUsuario(IN numRows INT)
BEGIN
    DECLARE i INT;
    DECLARE nome VARCHAR(50);
    DECLARE sobrenome VARCHAR(50);
    DECLARE email VARCHAR(255);
    DECLARE cidade VARCHAR(50);
    DECLARE data_nasc DATE;
    DECLARE id INT;

    DECLARE nome_aleatorio INT;
    DECLARE sobrenome_aleatorio INT;
    DECLARE cidade_aleatoria INT;
    DECLARE ano_aleatorio INT;
    DECLARE mes_aleatorio INT;
    DECLARE dia_aleatorio INT;

    DECLARE nomes VARCHAR(1000) DEFAULT 'João,Maria,José,Ana,Antônio,Carlos,Paulo,Pedro,Lucas,Luiza,Mariana,Patrícia,Daniel,Marcos,Eduardo';
    DECLARE sobrenomes VARCHAR(1000) DEFAULT 'Silva,Santos,Oliveira,Souza,Rodrigues,Lima,Gomes,Costa,Ribeiro,Martins,Carvalho,Araujo,Pinto';
    DECLARE cidades VARCHAR(1000) DEFAULT 'São Paulo,Rio de Janeiro,Belo Horizonte,Porto Alegre,Curitiba,Salvador,Fortaleza,Virória,São Luís';

    DECLARE qtd_nomes INT;
    DECLARE qtd_sobrenomes INT;
    DECLARE qtd_cidades INT;

    -- Contar quantos itens tem em cada array
    SET qtd_nomes = (LENGTH(nomes) - LENGTH(REPLACE(nomes, ',', ''))) + 1;
    SET qtd_sobrenomes = (LENGTH(sobrenomes) - LENGTH(REPLACE(sobrenomes, ',', ''))) + 1;
    SET qtd_cidades = (LENGTH(cidades) - LENGTH(REPLACE(cidades, ',', ''))) + 1;

    SET i = 0;
    WHILE i < numRows DO
        -- Selecionar itens aleatórios dos arrays
        SET nome_aleatorio = FLOOR(1 + RAND() * (qtd_nomes - 1));
        SET sobrenome_aleatorio = FLOOR(1 + RAND() * (qtd_sobrenomes - 1));
        SET cidade_aleatoria = FLOOR(1 + RAND() * (qtd_cidades - 1));

        -- Extrair os valores dos arrays
        SET nome = SUBSTRING_INDEX(SUBSTRING_INDEX(nomes, ',', nome_aleatorio), ',', -1);
        SET sobrenome = SUBSTRING_INDEX(SUBSTRING_INDEX(sobrenomes, ',', sobrenome_aleatorio), ',', -1);
        SET cidade = SUBSTRING_INDEX(SUBSTRING_INDEX(cidades, ',', cidade_aleatoria), ',', -1);

        -- Gerar data de nascimento
        SET ano_aleatorio = YEAR(CURRENT_DATE()) - FLOOR(18 + RAND() * (80 - 18));
        SET mes_aleatorio = FLOOR(1 + RAND() * 12);

        IF mes_aleatorio IN (4, 6, 9, 11) THEN
            SET dia_aleatorio = FLOOR(1 + RAND() * 30);
        ELSEIF mes_aleatorio = 2 THEN
            SET dia_aleatorio = FLOOR(1 + RAND() * 28);
        ELSE
            SET dia_aleatorio = FLOOR(1 + RAND() * 31);
        END IF;

        SET data_nasc = STR_TO_DATE(CONCAT(ano_aleatorio, '-', mes_aleatorio, '-', dia_aleatorio), '%Y-%m-%d');

        -- Inserir com email temporário
        INSERT INTO usuario (nome, sobrenome, email, cidade, dataNasc)
        VALUES (nome, sobrenome, 'temp@email.com', cidade, data_nasc);

        -- Pegar o ID recém-criado
        SET id = LAST_INSERT_ID();

        -- Gerar o e-mail baseado no id
        SET email = CONCAT(LOWER(REPLACE(nome, ' ', '')), '.', LOWER(REPLACE(sobrenome, ' ', '')), id, '@email.com');

        -- Atualizar o e-mail
        UPDATE usuario
        SET email = email
        WHERE idUsuario = id;

        SET i = i + 1;
    END WHILE;

    SELECT CONCAT(numRows, ' registros inseridos com sucesso.') AS resultado;
END $$
DELIMITER ;



DELIMITER $$
CREATE PROCEDURE popularTarefa(IN numRows INT)
BEGIN
    DECLARE i INT;
    DECLARE nome VARCHAR(50);
    DECLARE descricao TINYTEXT;
    DECLARE prioridade ENUM('Alta', 'Média', 'Baixa');
    DECLARE dataCriacao DATETIME;
    DECLARE dataPrazo DATETIME;
    DECLARE usuario_id INT;
    DECLARE qtde_usuarios INT;
    DECLARE dias_prazo INT;
    DECLARE min_id_usuario INT;
    
    -- Arrays de dados para randomização
    DECLARE tarefas_nomes VARCHAR(1000) DEFAULT 'Reunião com cliente,Desenvolver feature,Corrigir bug,Atualizar documentação,Testar sistema,Deploy em produção,Refatorar código,Atualizar dependências,Configurar servidor,Analisar requisitos';
    DECLARE tarefas_descricoes VARCHAR(1000) DEFAULT 'Preparar apresentação para o cliente,Implementar nova funcionalidade,Resolver problema crítico,Atualizar manual do usuário,Realizar testes de integração,Publicar nova versão,Melhorar estrutura do código,Atualizar bibliotecas e frameworks,Configurar ambiente de produção,Documentar necessidades do sistema';
    
    -- Contadores de itens nos arrays
    DECLARE qtd_nomes INT;
    DECLARE qtd_descricoes INT;
    
    -- Contar quantos itens tem em cada array
    SET qtd_nomes = (LENGTH(tarefas_nomes) - LENGTH(REPLACE(tarefas_nomes, ',', ''))) + 1;
    SET qtd_descricoes = (LENGTH(tarefas_descricoes) - LENGTH(REPLACE(tarefas_descricoes, ',', ''))) + 1;
    
    -- Obter quantidade e menor ID de usuários existentes
    SELECT COUNT(*), MIN(idusuario) INTO qtde_usuarios, min_id_usuario FROM usuario;
    
    -- Se não houver usuários, criar alguns
    IF qtde_usuarios = 0 THEN
        CALL popularUsuario(10);
        SELECT COUNT(*), MIN(idusuario) INTO qtde_usuarios, min_id_usuario FROM usuario;
    END IF;
    
    SET i = 0;
    WHILE i < numRows DO
        -- Selecionar nome aleatório
        SET nome = SUBSTRING_INDEX(SUBSTRING_INDEX(tarefas_nomes, ',', FLOOR(1 + RAND() * (qtd_nomes - 1))), ',', -1);
        
        -- 70% de chance de ter descrição
        IF RAND() < 0.7 THEN
            SET descricao = SUBSTRING_INDEX(SUBSTRING_INDEX(tarefas_descricoes, ',', FLOOR(1 + RAND() * (qtd_descricoes - 1))), ',', -1);
        ELSE
            SET descricao = NULL;
        END IF;
        
        -- Prioridade aleatória
        SET prioridade = ELT(FLOOR(1 + RAND() * 3), 'Alta', 'Média', 'Baixa');
        
        -- Data de criação (últimos 30 dias)
        SET dataCriacao = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY);
        SET dataCriacao = ADDTIME(dataCriacao, SEC_TO_TIME(FLOOR(RAND() * 86400)));
        
        -- 60% de chance de ter prazo
        IF RAND() < 0.6 THEN
            SET dias_prazo = FLOOR(1 + RAND() * 30);
            SET dataPrazo = DATE_ADD(dataCriacao, INTERVAL dias_prazo DAY);
            SET dataPrazo = ADDTIME(dataPrazo, SEC_TO_TIME(FLOOR(RAND() * 86400)));
        ELSE
            SET dataPrazo = NULL;
        END IF;
        
        -- Selecionar usuário aleatório válido (obrigatório)
        SET usuario_id = min_id_usuario + FLOOR(RAND() * qtde_usuarios);
        
        -- Inserir na tabela tarefa com o nome correto da FK
        INSERT INTO tarefa (
            nome, 
            descricao, 
            prioridade, 
            dataCriacao, 
            dataPrazo, 
            idusuario
        ) VALUES (
            nome,
            descricao,
            prioridade,
            dataCriacao,
            dataPrazo,
            usuario_id
        );
        
        SET i = i + 1;
    END WHILE;
    
    SELECT CONCAT(numRows, ' tarefas inseridas com sucesso.') AS resultado;
END $$
DELIMITER ;