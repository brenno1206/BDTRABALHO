
-- DROP DATABASE appTarefas;
SHOW SCHEMAS;
use appTarefas;
SHOW TABLES;

SET @numregistros = 5;
SELECT @numregistros;

CALL popularUsuario(@numregistros);
DROP PROCEDURE popularUsuario;
SELECT * FROM usuario;
DELETE FROM usuario;

CALL popularTarefa(@numregistros);
DROP PROCEDURE popularTarefa;
SELECT * FROM tarefa;
DELETE FROM tarefa;

CALL popularTag(@numregistros);
DROP PROCEDURE popularTag;
SELECT * FROM tag;
DELETE FROM tag;

CALL popularTag_tarefa(@numregistros);
DROP PROCEDURE popularTag_tarefa;
SELECT * FROM tag_tarefa;
DELETE FROM tag_tarefa;

CALL popularNotificacao(@numregistros);
SELECT * FROM notificacao;
DROP PROCEDURE popularNotificacao;
DELETE FROM notificacao;

DELIMITER $$
CREATE PROCEDURE popularUsuario(IN numRows INT)
BEGIN
    DECLARE i INT;
    DECLARE id INT;
    DECLARE nome VARCHAR(50);
    DECLARE sobrenome VARCHAR(50);
    DECLARE email VARCHAR(255);
    DECLARE cidade VARCHAR(50);
    DECLARE data_nasc DATE;
    
    DECLARE ano INT;
    DECLARE mes INT;
    DECLARE dia INT;
    
	DECLARE nomes VARCHAR(400) DEFAULT 'João,Maria,José,Ana,Antônio,Carlos,Paulo,Pedro,Lucas,Luiza,Mariana,Patrícia,Daniel,Marcos,Eduardo,Bruno,Fernando,Rafael,Juliana,Beatriz,André,Roberta,Thiago,Renata,Camila,Isabela,Fábio,Vanessa,Gustavo,Ricardo,Helena,Caio,Diego,Amanda,Felipe';
	DECLARE sobrenomes VARCHAR(400) DEFAULT 'Silva,Santos,Oliveira,Souza,Rodrigues,Lima,Gomes,Costa,Ribeiro,Martins,Carvalho,Araujo,Pinto,Almeida,Barbosa,Teixeira,Freitas,Machado,Rocha,Ferreira,Monteiro,Peixoto,Andrade,Cardoso,Moreira,Cavalcante,Nogueira,Correia,Assis,Figueiredo';
	DECLARE cidades VARCHAR(400) DEFAULT 'São Paulo,Campinas,Santos,Sorocaba,Rio de Janeiro,Niterói,Nova Iguaçu,Belo Horizonte,Uberlândia,Ouro Preto,Vitória,Vila Velha,Serra,Cariacica';
    DECLARE qtd_nomes INT;
    DECLARE qtd_sobrenomes INT;
    DECLARE qtd_cidades INT;
    
    SET qtd_nomes = (LENGTH(nomes) - LENGTH(REPLACE(nomes, ',', ''))) + 1;
    SET qtd_sobrenomes = (LENGTH(sobrenomes) - LENGTH(REPLACE(sobrenomes, ',', ''))) + 1;
    SET qtd_cidades = (LENGTH(cidades) - LENGTH(REPLACE(cidades, ',', ''))) + 1;
    SET i = 0;
    
    WHILE i < numRows DO        
        
        SET nome = SUBSTRING_INDEX(SUBSTRING_INDEX(nomes, ',', FLOOR(1 + RAND() * (qtd_nomes - 1))), ',', -1);
        SET sobrenome = SUBSTRING_INDEX(SUBSTRING_INDEX(sobrenomes, ',', FLOOR(1 + RAND() * (qtd_sobrenomes - 1))), ',', -1);
        SET cidade = SUBSTRING_INDEX(SUBSTRING_INDEX(cidades, ',', FLOOR(1 + RAND() * (qtd_cidades - 1))), ',', -1);
        
        SET ano = YEAR(CURRENT_DATE()) - FLOOR(18 + RAND() * (80 - 18));
        SET mes = FLOOR(1 + RAND() * 12);
        
        IF mes IN (4, 6, 9, 11) THEN
            SET dia = FLOOR(1 + RAND() * 30);
        ELSEIF mes = 2 THEN
            SET dia = FLOOR(1 + RAND() * 28);
        ELSE
            SET dia = FLOOR(1 + RAND() * 31);
        END IF;
        
        SET data_nasc = STR_TO_DATE(CONCAT(ano, '-', mes, '-', dia), '%Y-%m-%d');
        
        INSERT INTO usuario (nome, sobrenome, email, cidade, dataNasc)
        VALUES (nome, sobrenome, 'temp@email.com', cidade, data_nasc);

        SET id = LAST_INSERT_ID();
        SET email = CONCAT(LOWER(REPLACE(nome, ' ', '')), '.', LOWER(REPLACE(sobrenome, ' ', '')), id, '@email.com');

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
    
    DECLARE nomes VARCHAR(400) DEFAULT 'Reunião com cliente,Desenvolver feature,Corrigir bug,Atualizar documentação,Testar sistema,Deploy em produção,Refatorar código,Atualizar dependências,Configurar servidor,Analisar requisitos';
    DECLARE descricoes VARCHAR(1000) DEFAULT 'Preparar apresentação para o cliente,Implementar nova funcionalidade,Resolver problema crítico,Atualizar manual do usuário,Realizar testes de integração,Publicar nova versão,Melhorar estrutura do código,Atualizar bibliotecas e frameworks,Configurar ambiente de produção,Documentar necessidades do sistema';
    DECLARE qtd_nomes INT;
    DECLARE qtd_descricoes INT;
    
    SET qtd_nomes = (LENGTH(nomes) - LENGTH(REPLACE(nomes, ',', ''))) + 1;
    SET qtd_descricoes = (LENGTH(descricoes) - LENGTH(REPLACE(descricoes, ',', ''))) + 1;
    
    SELECT COUNT(*) INTO qtde_usuarios FROM usuario;
    
    SET i = 0;
    WHILE i < numRows DO

        SET nome = SUBSTRING_INDEX(SUBSTRING_INDEX(nomes, ',', FLOOR(1 + RAND() * (qtd_nomes - 1))), ',', -1);
        
        IF RAND() < 0.6 THEN
            SET descricao = SUBSTRING_INDEX(SUBSTRING_INDEX(descricoes, ',', FLOOR(1 + RAND() * (qtd_descricoes - 1))), ',', -1);
        ELSE
            SET descricao = NULL;
        END IF;
        
        SET prioridade = ELT(FLOOR(1 + RAND() * 3), 'Alta', 'Média', 'Baixa');
        
        SET dataCriacao = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 45) DAY);
        SET dataCriacao = ADDTIME(dataCriacao, SEC_TO_TIME(FLOOR(RAND() * 86400)));
        
        IF RAND() < 0.7 THEN
            SET dias_prazo = FLOOR(1 + RAND() * 30);
            SET dataPrazo = DATE_ADD(dataCriacao, INTERVAL dias_prazo DAY);
            SET dataPrazo = ADDTIME(dataPrazo, SEC_TO_TIME(FLOOR(RAND() * 86400)));
        ELSE
            SET dataPrazo = NULL;
        END IF;
        
        SET usuario_id = 1 + FLOOR(RAND() * qtde_usuarios);
        
        INSERT INTO tarefa (nome, descricao, prioridade, dataCriacao, dataPrazo, idusuario) VALUES 
        (nome, descricao, prioridade, dataCriacao, dataPrazo, usuario_id);
        
        SET i = i + 1;
    END WHILE;
    SELECT CONCAT(numRows, ' registros inseridas com sucesso.') AS resultado;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE popularTag(IN numRows INT)
BEGIN
    DECLARE i INT;
    DECLARE nome VARCHAR(30);
    DECLARE cor VARCHAR(7);
    
    DECLARE nomes VARCHAR (100) DEFAULT 'Trabalho,Escola,Faculdade,Entrevista,Urgente,Sem Prazo,Social,Médico';
    DECLARE cores VARCHAR(100) DEFAULT '#FF5733,#33FF57,#3357FF,#F1C40F,#8E44AD,#1ABC9C,#E74C3C,#2ECC71';
	
    DECLARE qtd_nomes INT;
    DECLARE qtd_cores INT;
    
    SET qtd_nomes = (LENGTH(nomes) - LENGTH(REPLACE(nomes, ',', ''))) + 1;
    SET qtd_cores = (LENGTH(cores) - LENGTH(REPLACE(cores, ',', ''))) + 1;

	SET i = 0;
    
    WHILE i < numRows DO 
		SET nome = SUBSTRING_INDEX(SUBSTRING_INDEX(nomes, ',', FLOOR(1 + RAND() * (qtd_nomes - 1))), ',', -1);
		SET cor = SUBSTRING_INDEX(SUBSTRING_INDEX(cores, ',', FLOOR(1 + RAND() * (qtd_cores - 1))), ',', -1);
        
        INSERT INTO tag(nome, cor) VALUES (nome,cor);
        SET i = i + 1;
    END WHILE;
	SELECT CONCAT(numRows, ' registros inseridas com sucesso.') AS resultado;
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE popularTag_tarefa(IN numRows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE idtarefa INT;
    DECLARE qtd_tarefas INT;
    DECLARE idtag INT;
    DECLARE qtd_tags INT;

    SELECT COUNT(*) INTO qtd_tarefas FROM tarefa;

    SELECT COUNT(*) INTO qtd_tags FROM tag;

    WHILE i < numRows DO
        SET idtarefa = 1 + FLOOR(RAND() * qtd_tarefas);
        SET idtag = 1 + FLOOR(RAND() * qtd_tags);
        INSERT INTO tag_tarefa(idtag, idtarefa) VALUES (idtag, idtarefa);
        SET i = i + 1;
    END WHILE;
	SELECT CONCAT(numRows, ' registros inseridos com sucesso.') AS resultado;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE popularNotificacao(IN numRows INT)
BEGIN
	DECLARE i INT;
    DECLARE titulo VARCHAR(100);
    DECLARE mensagem TEXT;
    DECLARE lida BIT;
    DECLARE idtarefa INT;
    DECLARE idusuario INT;
    DECLARE qtd_tarefas INT;
    DECLARE qtd_usuarios INT;
    
    DECLARE titulos VARCHAR(400) DEFAULT 'Atualizar sistema,Criar backup,Reunião com cliente,Entrega do projeto,Responder e-mails,Pagar fornecedores,Analisar métricas,Revisar contrato,Testar aplicação,Atualizar documentação';
	DECLARE mensagens TEXT DEFAULT 'O sistema precisa ser atualizado para a versão mais recente.,Lembre-se de criar o backup semanal do servidor.,Há uma reunião agendada com o cliente às 14h.,A entrega final do projeto está prevista para amanhã.,Verifique e responda os e-mails pendentes.,Efetuar o pagamento dos fornecedores até sexta-feira.,Analisar as métricas de desempenho do último mês.,Revisar o contrato enviado pelo jurídico.,Realizar testes na nova versão da aplicação.,Atualizar a documentação técnica do sistema.';
	
    DECLARE qtd_titulos INT;
    DECLARE qtd_mensagens INT;
    
    SET i = 0;
    
    SET qtd_titulos = (LENGTH(titulos) - LENGTH(REPLACE(titulos, ',', ''))) + 1;
    SET qtd_mensagens = (LENGTH(mensagens) - LENGTH(REPLACE(mensagens, ',', ''))) + 1;
    
    SELECT COUNT(*) INTO qtd_tarefas FROM tarefa;
    SELECT COUNT(*) INTO qtd_usuarios FROM usuario;
    
    WHILE i < numRows DO
		
        SET titulo = SUBSTRING_INDEX(SUBSTRING_INDEX(titulos, ',', FLOOR(1 + RAND() * (qtd_titulos - 1))), ',', -1);
        SET mensagem = SUBSTRING_INDEX(SUBSTRING_INDEX(mensagens, ',', FLOOR(1 + RAND() * (qtd_mensagens - 1))), ',', -1);
        
        IF RAND() > 0.5 THEN
			SET lida = 0;
		ELSE 
			SET lida = 1;
		END IF;
        
        SET idtarefa = 1 + FLOOR(RAND() * qtd_tarefas);
        SET idusuario =1 + FLOOR(RAND() * qtd_usuarios);
		
        INSERT INTO notificacao(titulo, mensagem, lida, idtarefa, idusuario) VALUES
        (titulo, mensagem, lida, idtarefa, idusuario);
		SET i = i + 1;
    END WHILE;
	SELECT CONCAT(numRows, ' registros inseridos com sucesso.') AS resultado;
END $$
DELIMITER ;
