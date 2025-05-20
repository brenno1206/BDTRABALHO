use apptarefas;
/*
Após criar uma nova tarefa, gera uma notificação 
automática para o usuário avisando.
*/

DELIMITER $$ 
CREATE TRIGGER tgr_insert_tarefa_cria_not AFTER INSERT ON tarefa FOR EACH ROW
BEGIN
	DECLARE tituloMsg VARCHAR(50);
    SET tituloMsg = CONCAT('Nova tarefa atribuída: ', NEW.nome, '.');
	INSERT INTO notificacao(titulo, mensagem, idtarefa, idusuario) VALUES
    (tituloMsg,'Se organize para sua nova tarefa!', NEW.idtarefa, NEW.idusuario);
END $$
DELIMITER ;

DROP TRIGGER tgr_insert_tarefa_cria_not;
CALL popularTarefa(1);

SELECT * FROM NOTIFICACAO ORDER BY idtarefa DESC LIMIT 1;


/*
Impede inserção de tarefa com dataPrazo anterior à dataCriacao.
*/

DELIMITER $$ 
CREATE TRIGGER tgr_insert_tarefa_valida_prazo BEFORE INSERT ON tarefa FOR EACH ROW
BEGIN
	IF NEW.dataPrazo < NEW.dataCriacao THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data de prazo inferior a data de criacao';
    END IF;
END $$
DELIMITER ;

-- erro
INSERT INTO tarefa(nome,dataCriacao,dataPrazo,idusuario)
VALUES('exemplo', '2025-05-19 18:00:00', '2025-05-18 14:00:00', 1);


/*
Quando o dataPrazo de uma tarefa for alterado, 
envia uma notificação ao usuário avisando que o prazo foi atualizado.
*/

DELIMITER $$ 
CREATE TRIGGER tgr_update_tarefa_cria_not AFTER UPDATE ON tarefa FOR EACH ROW
BEGIN
	DECLARE titulonot VARCHAR(100);
	SET titulonot = CONCAT('Tarefa ', NEW.nome, ' teve seu prazo alterado.');
	IF OLD.dataPrazo != NEW.dataPrazo THEN
		INSERT INTO notificacao(titulo, mensagem, idtarefa, idusuario) VALUES
		(titulonot,'Confira o novo prazo da sua tarefa!', NEW.idtarefa, NEW.idusuario);
	END IF;
END $$
DELIMITER ;

UPDATE tarefa
SET dataPrazo = NOW()
WHERE idtarefa = 4;

SELECT * FROM NOTIFICACAO ORDER BY idnotificacao DESC LIMIT 1;
