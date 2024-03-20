USE SALAO

-------- CARGA DIM_SALAO --------
CREATE OR ALTER PROCEDURE SP_DIM_SALAO (@DATA_CARGA DATETIME)
AS
BEGIN
	DECLARE @CODIGO_SALAO INT, @NOME_SALAO VARCHAR(100), @CIDADE VARCHAR(100), @UF VARCHAR(2)

	DECLARE C_SALAO CURSOR FOR (SELECT CODIGO_SALAO, NOME_SALAO, CIDADE, UF
								FROM TB_AUX_SALAO
								WHERE @DATA_CARGA = DATA_CARGA)

	OPEN C_SALAO

	FETCH C_SALAO INTO @CODIGO_SALAO, @NOME_SALAO, @CIDADE, @UF

	WHILE(@@FETCH_STATUS = 0)
	BEGIN	
		IF(EXISTS(SELECT * FROM DIM_SALAO WHERE @CODIGO_SALAO = COD_SALAO))
		BEGIN
			UPDATE DIM_SALAO
			SET NM_SALAO = @NOME_SALAO, CIDADE = @CIDADE, UF = @UF
			WHERE @CODIGO_SALAO = COD_SALAO
		END
		ELSE
		BEGIN
			INSERT INTO DIM_SALAO
			VALUES(@CODIGO_SALAO, @NOME_SALAO, @CIDADE, @UF)
		END

		FETCH C_SALAO INTO @CODIGO_SALAO, @NOME_SALAO, @CIDADE, @UF
	END
	CLOSE C_SALAO
	DEALLOCATE C_SALAO
END


-------- CARGA DIM_FUNCIONARIO --------
CREATE OR ALTER PROCEDURE SP_DIM_FUNCIONARIO (@DATA_CARGA DATETIME)
AS
BEGIN
	DECLARE @CODIGO_FUNCIONARIO INT, @NOME_FUNCIONARIO VARCHAR(100), @CPF VARCHAR(45), @TELEFONE VARCHAR(45)

	DECLARE C_FUNCIONARIO CURSOR FOR SELECT CODIGO_FUNCIONARIO, NOME_FUNCIONARIO, CPF, TELEFONE
								   FROM TB_AUX_FUNCIONARIO
								   WHERE @DATA_CARGA = DATA_CARGA

	OPEN C_FUNCIONARIO

	FETCH C_FUNCIONARIO INTO @CODIGO_FUNCIONARIO, @NOME_FUNCIONARIO, @CPF, @TELEFONE

	WHILE(@@FETCH_STATUS = 0)
	BEGIN	
		IF(EXISTS(SELECT * FROM DIM_FUNCIONARIO WHERE @CODIGO_FUNCIONARIO = COD_FUNCIONARIO))
		BEGIN
			UPDATE DIM_FUNCIONARIO
			SET NM_FUNCIONARIO = @NOME_FUNCIONARIO, CPF = @CPF, TELEFONE = @TELEFONE
			WHERE @CODIGO_FUNCIONARIO = COD_FUNCIONARIO
		END
		ELSE
		BEGIN
			INSERT INTO DIM_FUNCIONARIO
			VALUES(@CODIGO_FUNCIONARIO, @NOME_FUNCIONARIO, @CPF, @TELEFONE)
		END

		FETCH C_FUNCIONARIO INTO @CODIGO_FUNCIONARIO, @NOME_FUNCIONARIO, @CPF, @TELEFONE
	END
	CLOSE C_FUNCIONARIO
	DEALLOCATE C_FUNCIONARIO
END


-------- CARGA DIM_TIPO_SERVICO --------
CREATE OR ALTER PROCEDURE SP_DIM_TIPO_SERVICO (@DATA_CARGA DATETIME)
AS
BEGIN
	
END


-------- CARGA DIM_CLIENTE --------
CREATE OR ALTER PROCEDURE SP_DIM_CLIENTE (@DATA_CARGA DATETIME)
AS
BEGIN

END


-------- CARGA FATO_AGENDAMENTO --------
CREATE OR ALTER PROCEDURE SP_FATO_AGENDAMENTO (@DATA_CARGA DATETIME)
AS
BEGIN
	
END

-------- CARGA FATO_SERVICO --------
CREATE OR ALTER PROCEDURE SP_FATO_SERVICO (@DATA_CARGA DATETIME)
AS
BEGIN
	-- VARIAVEIS DO CURSOR
	DECLARE @DATA_AGENDAMENTO DATETIME, @COD_SERVICO INT, @COD_CLIENTE INT, @COD_SALAO INT, @COD_FUNCIONARIO INT, @COD_TIPO_SERVICO INT, @VALOR NUMERIC(10,2)

	-- VARIAVEIS PARA CONSULTAS
	DECLARE @AGENDAMENTO BIGINT, @SALAO INT, @FUNCIONARIO INT, @TIPO_SERVICO INT, @FAIXA_ETARIA INT, @CLIENTE INT, @IDADE INT

	DECLARE C_SERVICO CURSOR FOR (SELECT DATA_AGENDAMENTO, COD_SERVICO, COD_CLIENTE, COD_SALAO, COD_FUNCIONARIO, COD_TIPO_SERVICO, VALOR_SERVICO
								  FROM TB_AUX_SERVICO
								  WHERE DATA_CARGA = @DATA_CARGA)

	OPEN C_SERVICO

	FETCH C_SERVICO INTO @DATA_AGENDAMENTO, @COD_SERVICO, @COD_CLIENTE, @COD_SALAO, @COD_FUNCIONARIO, @COD_TIPO_SERVICO, @VALOR

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		SET @AGENDAMENTO = (SELECT ID_TEMPO FROM DIM_TEMPO WHERE DATA = @DATA_AGENDAMENTO)
		SET @SALAO = (SELECT ID_SALAO FROM DIM_SALAO WHERE COD_SALAO = @COD_SALAO)
		SET @FUNCIONARIO = (SELECT ID_FUNCIONARIO FROM DIM_FUNCIONARIO WHERE COD_FUNCIONARIO = @COD_FUNCIONARIO)
		SET @TIPO_SERVICO = (SELECT ID_TIPO_SERVICO FROM DIM_TIPO_SERVICO WHERE COD_TIPO_SERVICO = @COD_TIPO_SERVICO)
		SET @CLIENTE = (SELECT ID_CLIENTE FROM DIM_CLIENTE WHERE COD_CLIENTE = @COD_CLIENTE)
		SET @IDADE = (SELECT DATEDIFF(year, DT_NASCIMENTO, GETDATE()) FROM DIM_CLIENTE WHERE COD_CLIENTE = @COD_CLIENTE)

		IF(@IDADE <= 12)
		BEGIN	
			SET @FAIXA_ETARIA =(SELECT ID_FAIXA_ETARIA FROM DIM_FAIXA_ETARIA WHERE FAIXA_ETARIA = 'CRIANCA')
		END
		ELSE IF(@IDADE <= 18)
		BEGIN	
			SET @FAIXA_ETARIA =(SELECT ID_FAIXA_ETARIA FROM DIM_FAIXA_ETARIA WHERE FAIXA_ETARIA = 'ADOLESCENTE')
		END
		ELSE IF(@IDADE <= 60)
		BEGIN	
			SET @FAIXA_ETARIA =(SELECT ID_FAIXA_ETARIA FROM DIM_FAIXA_ETARIA WHERE FAIXA_ETARIA = 'ADULTO')
		END
		ELSE
		BEGIN
			SET @FAIXA_ETARIA =(SELECT ID_FAIXA_ETARIA FROM DIM_FAIXA_ETARIA WHERE FAIXA_ETARIA = 'IDOSO')
		END


		IF(@AGENDAMENTO IS NULL)
		BEGIN
			INSERT INTO TB_VIO_SERVICO
			VALUES(@DATA_CARGA, @AGENDAMENTO, @COD_SALAO, @COD_CLIENTE, @COD_FUNCIONARIO, @COD_TIPO_SERVICO, @VALOR, GETDATE(), 'DATA DE AGENDAMENTO N�O EXISTE')
		END
		ELSE IF(@SALAO IS NULL)
		BEGIN
			INSERT INTO TB_VIO_SERVICO
			VALUES(@DATA_CARGA, @AGENDAMENTO, @COD_SALAO, @COD_CLIENTE, @COD_FUNCIONARIO, @COD_TIPO_SERVICO, @VALOR, GETDATE(), 'SAL�O N�O EXISTE')
		END
		ELSE IF(@CLIENTE IS NULL)
		BEGIN
			INSERT INTO TB_VIO_SERVICO
			VALUES(@DATA_CARGA, @AGENDAMENTO, @COD_SALAO, @COD_CLIENTE, @COD_FUNCIONARIO, @COD_TIPO_SERVICO, @VALOR, GETDATE(), 'CLIENTE N�O EXISTE')
		END
		ELSE IF(@FUNCIONARIO IS NULL)
		BEGIN
			INSERT INTO TB_VIO_SERVICO
			VALUES(@DATA_CARGA, @AGENDAMENTO, @COD_SALAO, @COD_CLIENTE, @COD_FUNCIONARIO, @COD_TIPO_SERVICO, @VALOR, GETDATE(), 'FUNCION�RIO N�O EXISTE')
		END
		ELSE IF(@TIPO_SERVICO IS NULL)
		BEGIN
			INSERT INTO TB_VIO_SERVICO
			VALUES(@DATA_CARGA, @AGENDAMENTO, @COD_SALAO, @COD_CLIENTE, @COD_FUNCIONARIO, @COD_TIPO_SERVICO, @VALOR, GETDATE(), 'TIPO DE SERVI�O N�O EXISTE')
		END
		ELSE IF(@VALOR <= 0 OR @VALOR IS NULL)
		BEGIN
			INSERT INTO TB_VIO_SERVICO
			VALUES(@DATA_CARGA, @AGENDAMENTO, @COD_SALAO, @COD_CLIENTE, @COD_FUNCIONARIO, @COD_TIPO_SERVICO, @VALOR, GETDATE(), 'VALOR INV�LIDO')
		END
		ELSE
		BEGIN
			IF(EXISTS(SELECT * FROM FATO_SERVICO WHERE COD_SERVICO = @COD_SERVICO))
			BEGIN
				UPDATE FATO_SERVICO
				SET ID_DT_AGENDAMENTO = @AGENDAMENTO,
					ID_FAIXA_ETARIA = @FAIXA_ETARIA,
					ID_SALAO = @SALAO,
					ID_CLIENTE = @CLIENTE,
					ID_FUNCIONARIO = @FUNCIONARIO,
					ID_TIPO_SERVICO = @TIPO_SERVICO,
					VALOR_SERVICO = @VALOR
				WHERE COD_SERVICO = @COD_SERVICO
			END
			ELSE
			BEGIN
				INSERT INTO FATO_SERVICO
				VALUES(@COD_SERVICO, @AGENDAMENTO, @FAIXA_ETARIA, @SALAO, @CLIENTE, @FUNCIONARIO, @TIPO_SERVICO, 1, @VALOR)
			END
		END		

		FETCH C_SERVICO INTO @DATA_AGENDAMENTO, @COD_SERVICO, @COD_CLIENTE, @COD_SALAO, @COD_FUNCIONARIO, @COD_TIPO_SERVICO, @VALOR
	END
	CLOSE C_SERVICO
	DEALLOCATE C_SERVICO
END


-------- EXECU��O PROCEDIMENTOS DA CARGA --------

INSERT INTO DIM_FAIXA_ETARIA
VALUES('IDOSO'),
	  ('ADULTO'),
	  ('JOVEM'),
	  ('CRIANCA')

INSERT INTO DIM_STATUS
VALUES('AGENDADO'),
	  ('CANCELADO')

EXEC SP_DIM_TEMPO '20240101', '20240103'
SELECT * FROM DIM_TEMPO

EXEC SP_DIM_SALAO '20240101'
SELECT * FROM DIM_SALAO

EXEC SP_DIM_CLIENTE '20240103'
SELECT * FROM DIM_CLIENTE

EXEC SP_DIM_FUNCIONARIO '20240103'
SELECT * FROM DIM_FUNCIONARIO

EXEC SP_TIPO_SERVICO '20240103'
SELECT * FROM DIM_TIPO_SERVICO

EXEC SP_FATO_SERVICO '20240103'
SELECT * FROM FATO_SERVICO

EXEC SP_FATO_AGENDAMENTO '20240103'
SELECT * FROM FATO_AGENDAMENTO