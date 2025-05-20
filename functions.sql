use apptarefas;

DELIMITER $$
CREATE FUNCTION getEstado(cidade VARCHAR(30))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
	DECLARE estado VARCHAR(30);
    
	IF cidade = 'São Paulo' OR cidade = 'Campinas' OR cidade = 'Sorocaba' OR cidade = 'Santos' THEN
		SET estado = 'Sao Paulo';
	ELSEIF cidade = 'Rio de Janeiro' OR cidade = 'Niterói' OR cidade = 'Nova Iguaçu' THEN
		SET estado = 'Rio de Janeiro';
	ELSEIF cidade = 'Belo Horizonte' OR cidade = 'Uberlândia' OR cidade = 'Ouro Preto' THEN
		SET estado = 'Minas Gerais';
	ELSEIF cidade = 'Vitória' OR cidade = 'Vila Velha' OR cidade = 'Serra' OR cidade = 'Cariacica' THEN
		SET estado = 'Espírito Santo';
	ELSE 
		SET estado = 'não cadastrado no sistema';
	END IF;
    
    RETURN estado;

END $$
DELIMITER ;

SELECT cidade, getEstado(cidade) estado
FROM usuario;

-- -------------------------------------------------------------------------

DELIMITER $$
CREATE FUNCTION getIdade(dataNasc DATE)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE idade INT;
	IF (DAY(CURDATE()) < day(dataNasc) AND MONTH(CURDATE()) < MONTH(dataNasc)) OR MONTH(CURDATE()) < MONTH(dataNasc) THEN
		SET idade = YEAR(CURDATE()) - YEAR(dataNasc) - 1;
	ELSE 
		SET idade = YEAR(CURDATE()) - YEAR(dataNasc);
	END IF;
    RETURN idade;
END $$
DELIMITER ;

SELECT CONCAT(nome, ' ', sobrenome) as nome, getIdade(dataNasc), dataNasc
FROM usuario;


-- -------------------------------------------------------------------------

DELIMITER $$
CREATE FUNCTION grupoEtario(dataNasc DATE)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN

	DECLARE grupo VARCHAR(10);
    DECLARE idade INT;
    
    SET idade = getIdade(dataNasc);
    IF idade > 59 THEN
		SET grupo = 'Idoso';
	ELSEIF idade > 29 THEN
		SET grupo = 'adulto';
	ELSE
		SET grupo = 'jovem';
	END IF;
    
    RETURN grupo;

END $$
DELIMITER ;

SELECT CONCAT(nome, ' ', sobrenome) as nome, getIdade(dataNasc), grupoEtario(dataNasc) 
FROM usuario;

SELECT grupoEtario(dataNasc) grupo, COUNT(*) 'Número de pessoas'
FROM usuario
GROUP BY 1;

-- -------------------------------------------------------------------------

DELIMITER $$
CREATE FUNCTION diasRestantes(dataPrazo DATETIME)
RETURNS INT
DETERMINISTIC
BEGIN

	DECLARE diasRestantes INT;

	IF dataPrazo <= NOW() OR dataPrazo IS NULL THEN
		RETURN 0;
	ELSE
		RETURN DATEDIFF(dataPrazo,now());
	END IF;

END $$
DELIMITER ;

drop FUNCTION diasRestantes;

SELECT nome, diasRestantes(dataPrazo), dataPrazo
FROM tarefa;

-- -------------------------------------------------------------------------

DELIMITER $$
CREATE FUNCTION diasDesdeCriacao(dataCriacao DATETIME)
RETURNS INT
DETERMINISTIC
BEGIN

	RETURN ABS(DATEDIFF(now(),dataCriacao));

END $$
DELIMITER ;


drop function diasDesdeCriacao;
SELECT nome, diasDesdeCriacao(dataCriacao), dataCriacao
FROM tarefa;

-- -------------------------------------------------------------------------

DELIMITER $$
CREATE FUNCTION prazoExpirado(dataPrazo DATETIME)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
	IF dataPrazo IS NOT NULL AND diasRestantes(dataPrazo) = 0 THEN
		RETURN TRUE;
	ELSE 
		RETURN FALSE;
	END IF;

END $$
DELIMITER ;

SELECT nome, dataPrazo
FROM tarefa
WHERE prazoExpirado(dataPrazo);

-- -------------------------------------------------------------------------

DELIMITER $$
CREATE FUNCTION temTag(idtarefa INT, tag VARCHAR(50))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
	DECLARE existe INT;
	SELECT COUNT(*) INTO existe
	FROM tag_tarefa tt
	JOIN tag t USING(idtag)
	WHERE tt.idtarefa = idtarefa AND t.nome = tag;

  RETURN existe > 0;
END $$
DELIMITER ;

SELECT nome
FROM tarefa
WHERE temTag(idtarefa,'Urgente');