use apptarefas;
SELECT * FROM tag;

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
        SELECT CONCAT(numRows, ' tags inseridas com sucesso.') AS resultado;
    END $$
DELIMITER ;

CALL popularTag(5);
DROP PROCEDURE popularTag;
SELECT COUNT(*) FROM tag;

DELIMITER $$
	CREATE PROCEDURE popularTag_tarefa(IN numRows INT)
    BEGIN
    DECLARE i INT;
    DECLARE idtarefa INT;
    DECLARE qtd_tarefas INT;
    DECLARE min_idTarefa INT;
    DECLARE idtag INT;
    DECLARE qtd_tags INT;
    DECLARE min_idtag INT;
    
    SELECT COUNT(*), MIN(idtarefa) INTO qtd_tarefas, min_idtarefa FROM tarefa;
    
    SELECT COUNT(*), MIN(idtag) INTO qtd_tags, min_idtag FROM tag;
    
    SET i = 0;
    
    WHILE i < numRows DO
		SET idtarefa = min_idtarefa + FLOOR(RAND() * qtd_tarefas);
        SET idtag = min_idtag + FLOOR(RAND() * qtd_tags);
        INSERT INTO tag_tarefa(idtag,idtarefa) VALUES (idtag, idtarefa);
		SET i = i + 1;
    END WHILE;
    
    END $$
DELIMITER ;

DROP PROCEDURE popularTag_tarefa;
CALL popularTag_tarefa(5);
SELECT * FROM tag_tarefa;