---------------------------------------------------------------
---------------------------- EXERCÍCIOS
---------------------------------------------------------------

-- 1.1 Adicione uma coluna à tabela tb_pessoa chamada ativo. Ela indica se a pessoa está
-- ativa no sistema ou não. Ela deve ser capaz de armazenar um valor booleano. Por padrão,
-- toda pessoa cadastrada no sistema está ativa.
-- ALTER TABLE tb_pessoa 
-- ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT TRUE;

-- -- teste
-- SELECT * FROM tb_pessoa;

-- -- 1.2 Associe um trigger de DELETE à tabela. Quando um DELETE for executado, o trigger
-- -- deve atribuir FALSE à coluna ativo das linhas envolvidas. Além disso, o trigger não deve
-- -- permitir que nenhuma pessoa seja removida.

-- -- função
-- CREATE OR REPLACE FUNCTION fn_bloquear_delete_pessoa() RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
	
-- 	RAISE NOTICE 'Pessoa a ser removida: %', OLD.cod_pessoa;
	
-- 	UPDATE tb_pessoa 
-- 	SET ativo = FALSE
-- 	WHERE cod_pessoa = OLD.cod_pessoa;
	
-- 	RAISE NOTICE 'Remoção registro não permitida';
	
-- 	RETURN NULL;

-- END;
-- $$

-- -- trigger tg_bloquear_delete_pessoa
-- DROP TRIGGER IF EXISTS tg_bloquear_delete_pessoa ON tb_pessoa;
-- CREATE TRIGGER tg_bloquear_delete_pessoa
-- BEFORE DELETE ON tb_pessoa
-- FOR EACH ROW
-- EXECUTE FUNCTION fn_bloquear_delete_pessoa();

-- testes
SELECT * FROM tb_pessoa;

DELETE FROM tb_pessoa
WHERE cod_pessoa = 1;

---------------------------------------------------------------
----------------------------- TRIGGERS
---------------------------------------------------------------
-- Bloco de Código 2.4.1
-- CREATE table tb_teste_trigger(
-- 	cod_teste_trigger SERIAL PRIMARY KEY,
-- 	texto VARCHAR(200)
-- );

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Bloco de Código 2.4.2 - TG ANTES DO INSERT
-- --esta função especifica o que o trigger vai fazer
-- CREATE OR REPLACE FUNCTION fn_antes_de_um_insert() RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
-- --aqui escrevemos o que o trigger deve fazer
-- RAISE NOTICE 'Trigger foi chamado antes do INSERT!!';
-- -- Funções de trigger precisam devolver algo. Logo, não devolver registro
-- RETURN NULL; 
-- END;
-- $$


-- Bloco de Código 2.4.3 - A seguir, vinculamos a função à tabela
-- com CREATE TRIGGER. É nesse momento que especificamos detalhes como o tipo do
-- evento, o momento em que o trigger dispara e o nível do trigger. Observe que especificamos
-- que o trigger deve disparar antes de uma inserção acontecer

-- CREATE OR REPLACE TRIGGER tg_antes_do_insert --> antes de uma inserção acontecer na tabela tb_teste_trigger
-- BEFORE INSERT ON tb_teste_trigger  
-- FOR EACH STATEMENT --> executa apenas uma vez
-- EXECUTE PROCEDURE fn_antes_de_um_insert();

-- --teste
-- INSERT INTO tb_teste_trigger(texto) 
-- VALUES ('testando trigger');

-- SELECT * FROM tb_teste_trigger;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Bloco de Código 2.4.5 - FN/ TG DEPOIS DO INSERT
-- CREATE OR REPLACE FUNCTION fn_depois_de_um_insert() RETURNS TRIGGER
-- LANGUAGE plpgsql	
-- AS $$
-- BEGIN
-- 	RAISE NOTICE 'Trigger foi chamado DEPOIS do insert';
-- 	RETURN NULL;
-- END;
-- $$


-- Bloco de Código 2.4.6
-- CREATE OR REPLACE TRIGGER tg_depois_do_insert
-- AFTER INSERT ON tb_teste_trigger
-- FOR EACH STATEMENT	
-- EXECUTE FUNCTION fn_depois_de_um_insert();

-- --teste
-- INSERT INTO tb_teste_trigger (texto)
-- VALUES ('testando trigger DEPOIS do insert'); 

-- SELECT * FROM tb_teste_trigger;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Bloco de Código 2.4.8 - ORDEM DE EXECUÇÃO - ALFABÉTICA nome dados

-- * BEFORE vem antes do AFTER --> BEFORE → operação → AFTER
-- * Ordem alfabética --> Mesmo tipo → ordem alfabética

-- CREATE OR REPLACE TRIGGER tg_antes_do_insert2
-- BEFORE INSERT ON tb_teste_trigger
-- FOR EACH STATEMENT
-- EXECUTE PROCEDURE fn_antes_de_um_insert();

-- CREATE OR REPLACE TRIGGER tg_depois_do_insert2
-- AFTER INSERT ON tb_teste_trigger
-- FOR EACH STATEMENT
-- EXECUTE PROCEDURE fn_depois_de_um_insert();

-- INSERT INTO tb_teste_trigger (texto)
-- VALUES ('testando ordem dos triggers'); 

-- SELECT * FROM tb_teste_trigger;
-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Bloco de Código 2.5.1 - REMOVER TGs E DADOS TABELA

-- DELETE FROM tb_teste_trigger_cod_teste_trigger_seq;

-- SELECT * FROM tb_teste_trigger_cod_teste_trigger_seq;

-- começa do 1 de novo. Use WITH n para começar de n
-- ALTER SEQUENCE tb_teste_trigger_cod_teste_trigger_seq RESTART WITH 1;

-- DROP TRIGGER IF EXISTS tg_antes_do_insert2 ON tb_teste_trigger;
-- DROP TRIGGER IF EXISTS tg_depois_do_insert2 ON tb_teste_trigger;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Bloco de Código 2.5.3 - O próximo passo consiste em
-- ajustar os triggers para que eles passem alguns valores para as functions que chamam.

-- CREATE OR REPLACE TRIGGER tg_antes_do_insert
-- BEFORE INSERT OR UPDATE ON tb_teste_trigger
-- FOR EACH STATEMENT 
-- -- pode-se inserir parâmetros na chamada 
-- EXECUTE PROCEDURE fn_antes_de_um_insert('Antes: V1', 'Antes: V2')

-- CREATE OR REPLACE TRIGGER tg_depois_do_insert
-- BEFORE INSERT OR UPDATE ON tb_teste_trigger
-- FOR EACH STATEMENT 
-- EXECUTE PROCEDURE fn_depois_de_um_insert('Depois: V1', 'Depois: V2', 'Depois: V3')


-- Bloco de Código 2.5.4 - Ajuste nas functions: elas passam a exibir os valores
-- existentes nas variáveis especiais

-- CREATE OR REPLACE FUNCTION fn_antes_de_um_insert()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     RAISE NOTICE 'Estamos no trigger BEFORE';
--     RAISE NOTICE 'OLD: %', OLD;
--     RAISE NOTICE 'NEW: %', NEW;
--     RAISE NOTICE 'OLD.texto: %', OLD.texto;
--     RAISE NOTICE 'NEW.texto: %', NEW.texto;
--     RAISE NOTICE 'TG_NAME: %', TG_NAME;
--     RAISE NOTICE 'TG_LEVEL: %', TG_LEVEL;
--     RAISE NOTICE 'TG_WHEN: %', TG_WHEN;
--     RAISE NOTICE 'TG_TABLE_NAME: %', TG_TABLE_NAME;
--     RAISE NOTICE 'TG_NARGS: %', TG_NARGS;

--     FOR i IN 0..TG_NARGS - 1
	
-- 		LOOP
-- 			RAISE NOTICE '%', TG_ARGV[i];
-- 		END LOOP;

--     RETURN NEW;
-- END;
-- $$;


-- CREATE OR REPLACE FUNCTION fn_depois_de_um_insert()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql AS $$
-- BEGIN

-- 	RAISE NOTICE 'Estamos no trigger AFTER';
-- 	RAISE NOTICE 'OLD: %', OLD;
-- 	RAISE NOTICE 'NEW: %', NEW;
-- 	RAISE NOTICE 'OLD.texto: %', OLD.texto;
-- 	RAISE NOTICE 'NEW.texto: %', NEW.texto;
-- 	RAISE NOTICE 'TG_NAME: %', TG_NAME;
-- 	RAISE NOTICE 'TG_LEVEL: %', TG_LEVEL;
-- 	RAISE NOTICE 'TG_WHEN: %', TG_WHEN;
-- 	RAISE NOTICE 'TG_TABLE_NAME: %', TG_TABLE_NAME;
-- 	RAISE NOTICE 'TG_NARGS: %', TG_NARGS;
-- 	FOR i IN 0..TG_NARGS - 1 LOOP
	
-- 		RAISE NOTICE '%', TG_ARGV[i];
	
-- 	END LOOP;	
	
-- 	RETURN NEW;
	
-- END;
-- $$


-- --teste
-- INSERT INTO tb_teste_trigger (texto)
-- VALUES ('testando trigger NOVAMENTE');

-- SELECT * FROM tb_teste_trigger;

-- -- Resultado saída - NOTAS:

-- TG_NARGS = quantidade de argumentos enviados

-- TG_ARGV = onde os argumentos ficam

-- TG_NARGS = 2
-- ↓
-- TG_ARGV[0], TG_ARGV[1]

-- TG_NARGS = 0
-- ↓
-- array vazio
-- ↓
-- loop não executa

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- CREATE OR REPLACE TRIGGER tg_antes_do_insert
-- BEFORE INSERT OR UPDATE ON tb_teste_trigger
-- FOR EACH ROW
-- EXECUTE PROCEDURE fn_antes_de_um_insert('A: V1', 'A: v2');

-- INSERT INTO tb_teste_trigger (texto)
-- VALUES ('Texto sendo inserido...');

-- SELECT * FROM tb_teste_trigger;

-- UPDATE tb_teste_trigger SET texto = 'outro novo texto...'
-- WHERE cod_teste_trigger = 2;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
-- Bloco de Código 2.5.6 - ALTERANDO PARA NÍVEL ROW

-- Os triggers que definimos têm nível STATEMENT, o que quer dizer que executam uma única
-- vez por evento, e não uma vez por tupla impactada. Numa única operação de UPDATE, por
-- exemplo, múltiplas tuplas podem ser afetadas e, assim, não faz sentido usar NEW e OLD.
-- Por isso, altere o nível dos dois triggers para ROW.

-- --before trigger
-- CREATE OR REPLACE TRIGGER tg_antes_do_insert
-- BEFORE INSERT OR UPDATE ON tb_teste_trigger
-- FOR EACH ROW
-- EXECUTE PROCEDURE fn_antes_de_um_insert('Antes: V1', 'Antes: V2');

-- --after trigger
-- CREATE OR REPLACE TRIGGER tg_depois_do_insert
-- AFTER INSERT OR UPDATE ON tb_teste_trigger
-- FOR EACH ROW
-- EXECUTE PROCEDURE fn_depois_de_um_insert('Depois: V1', 'Depois: V2', 'Depois: V3');

-- -- teste
-- INSERT INTO tb_teste_trigger (texto)
-- VALUES ('Texto sendo inserido...AQUI');

-- SELECT * FROM tb_teste_trigger;

-- UPDATE tb_teste_trigger SET texto = 'outro novo texto...'
-- WHERE cod_teste_trigger = 2;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- --***** VEJA NOTAS! *****
-- 2.6.1 Trigger: sistema com auditoria - registrar em uma tabela todas 
-- as movimentações monetárias realizadas: tanto novos cadastros quanto 
-- atualização dos já existentes.

-- Bloco de Código 2.6.1 - criação tabelas
-- DROP TABLE IF EXISTS tb_pessoa;
-- CREATE TABLE IF NOT EXISTS tb_pessoa(
-- 	cod_pessoa SERIAL PRIMARY KEY,
-- 	nome VARCHAR(200) NOT NULL,
-- 	idade INT NOT NULL,
-- 	saldo NUMERIC(10, 2) NOT NULL
-- );

-- --populando table pessoa
-- INSERT INTO tb_pessoa (nome, idade, saldo)
-- VALUES
--     ('João Silva', 25, 1500.75),
--     ('Ana Pereira', 28, 4570.90),
--     ('Sem dinheiro', 36, 500),
-- 	('William Santos', 30, -500);

-- DROP TABLE IF EXISTS tb_auditoria;
-- CREATE TABLE IF NOT EXISTS tb_auditoria(
-- 	cod_auditoria SERIAL PRIMARY KEY,
-- 	cod_pessoa INT NOT NULL,
-- 	idade INT NOT NULL,
-- 	saldo_antigo NUMERIC (10, 2),
-- 	saldo_atual NUMERIC(10, 2)
-- );


-- Bloco de Código 2.6.2 - Trigger para não permitir valores negativos
-- CREATE OR REPLACE FUNCTION fn_validador_de_saldo()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF NEW.saldo >= 0 THEN
	
--         RETURN NEW;
		
--     ELSE
	
--         RAISE NOTICE 'Valor de saldo inválido: %', NEW.saldo;
--         RETURN NULL;
		
--     END IF;
-- END;
-- $$;


-- Bloco de Código 2.6.3 - trigger VÍNCULO function X table

-- DROP TRIGGER IF EXISTS tg_validador_de_saldo ON tb_pessoa;
-- CREATE TRIGGER tg_validador_de_saldo
-- BEFORE INSERT OR UPDATE ON tb_pessoa
-- FOR EACH ROW
-- EXECUTE FUNCTION fn_validador_de_saldo();

-- -- teste
-- UPDATE tb_pessoa SET saldo = -200
-- WHERE cod_pessoa = 3;

-- INSERT INTO tb_pessoa (nome, idade, saldo)
-- VALUES('Shang Tsung', 150, -50);
	
-- SELECT * FROM tb_pessoa;

-- DROP TRIGGER tg_validador_de_saldo ON tb_pessoa;

-- ------------------------------------------------------------------------
-- **** PAGINA 26
-- Bloco de Código 2.6.7 - Trigger para fazer log de operações INSERT

-- -- função para log de operações INSERT
-- CREATE OR REPLACE FUNCTION fn_log_pessoa_insert()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN

--     INSERT INTO tb_auditoria (
--         cod_pessoa,
--         idade,
--         saldo_antigo,
--         saldo_atual
--     )
--     -- registro no INSERT não existia antes, logo, OLD é NULL
--     VALUES (NEW.cod_pessoa, NEW.idade, NULL,NEW.saldo);

--     RETURN NULL;

-- END;
-- $$;

-- -- trigger tb_log_auditoria x fn_log_pessoa_insert
-- CREATE OR REPLACE TRIGGER tg_log_pessoa_insert
-- AFTER INSERT ON tb_pessoa
-- FOR EACH ROW
-- EXECUTE PROCEDURE fn_log_pessoa_insert()

-- ---------------------------------------------------------------

-- --teste
-- INSERT INTO tb_pessoa
-- (nome, idade, saldo)
-- VALUES
-- ('João', 20, 100),
-- ('Pedro', 22, 100),
-- ('Maria', 22, 400);


-- SELECT * FROM tb_auditoria;

-- --função que faz log de operações update na tabela pessoa
-- CREATE OR REPLACE FUNCTION fn_log_pessoa_update()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql AS $$
-- BEGIN

-- 	INSERT INTO tb_auditoria (cod_pessoa, nome, idade, saldo_antigo, saldo_atual)
-- 	VALUES (NEW.cod_pessoa, NEW.nome, NEW.idade, OLD.saldo, NEW.saldo);

-- 	RETURN NEW;
	
-- END;
-- $$

---------------------------------------------------------------
----------------------------- NOTAS
---------------------------------------------------------------
-- 2.3 Um trigger é um bloco de código armazenado pelo servidor que executa
-- automaticamente quando um evento específico acontece.

-- Triggers são funções associadas a tabelas ou views.


-- * Eventos: INSERT, UPDATE, DELETE e TRUNCATE.


-- * Quando:
-- - BEFORE de as restrições serem verificadas e antes de o evento
-- especificado acontecer.


-- - AFTER de as restrições serem verificadas e depois de o evento
-- especificado acontecer.


-- - INSTEAD OF do evento especificado.

-- * Nível:
-- - ROW: o trigger executa uma vez para cada linha(row) envolvida na operação.

-- - STATEMENT: executa uma única vez mesmo nos casos em que múltiplas
-- linhas são envolvidas na operação.

-- - STATEMENT é o padrão caso nenhum seja especificado.


-- * Podemos associar um número ilimitado de triggers a uma tabela.

-- * Quando uma tabela tem a ela associados pelo menos dois triggers, eles são executados
-- em ordem alfabética.


-- * Para NEW sempre usar ROW

-- * ORDEM DE CRIAÇÃO -> TB > FN > TG
-- Tabela = onde o evento acontece
-- Função = o que será executado
-- Trigger = quando executar a função


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
------------- SIMULAÇÃO COMPLETA DO FLUXO DE TRIGGER:
--------------------------------------------------------------------------------

-- Exemplo: INSERT INTO tb_cliente(nome) VALUES ('pedro');

-- -----------------------------------------------------------
-- --------------- PASSO 1 - INSERT COMEÇA
-- -----------------------------------------------------------

-- Usuário executa:

-- INSERT INTO tb_cliente(nome)
-- VALUES ('pedro');

-- Nesse momento o PostgreSQL cria:   NEW.nome = 'pedro'

-- NEW representa: "registro novo chegando ao banco"

-- Fluxo: 📦 pedro

-- ---------------------------------------------------------
-- ------------- PASSO 2 - BEFORE TRIGGER 1
-- ---------------------------------------------------------

-- Objetivo: Transformar texto em maiúsculo

-- Recebe: NEW.nome = pedro

-- Transforma: NEW.nome = PEDRO

-- Executa: RETURN NEW;

-- Fluxo:
-- 📦 pedro
--       ↓
-- BEFORE 1
--       ↓
-- 📦 PEDRO
--       ↓
-- RETURN NEW

-- RETURN NEW significa: "Pode continuar para o próximo trigger"

-- ---------------------------------------------------------
-- PASSO 3 - BEFORE TRIGGER 2
-- ---------------------------------------------------------

-- Objetivo: Adicionar sobrenome

-- Recebe: NEW.nome = PEDRO

-- Transforma: NEW.nome = PEDRO SILVA

-- Executa: RETURN NEW;

-- Fluxo:
-- 📦 PEDRO
--       ↓
-- BEFORE 2
--       ↓
-- 📦 PEDRO SILVA
--       ↓
-- RETURN NEW

-- ---------------------------------------------------------
-- ------------ PASSO 4 - INSERT REAL ACONTECE
-- ---------------------------------------------------------

-- Banco recebe: NEW.nome = PEDRO SILVA

-- Então grava - tb_cliente:


-- cod_cliente | nome
-- --------------------------
-- 1           | PEDRO SILVA


-- Fluxo:
-- BEFORE terminou
--         ↓
-- INSERT executa
--         ↓
-- registro salvo

---------------------------------------------------------
---------------- PASSO 5 - AFTER TRIGGER 1
---------------------------------------------------------

-- Objetivo: Criar log

-- Recebe: NEW.nome = PEDRO SILVA

-- Executa algo parecido com:

-- INSERT INTO tb_log
-- VALUES (...);

-- Resultado - tb_log:


-- cod_log | descricao
-- --------------------------
-- 1       | Cliente criado


-- Fluxo:

-- INSERT concluído
--         ↓
-- AFTER 1
--         ↓
-- cria log

-- ---------------------------------------------------------
-- ---------------- PASSO 6 - AFTER TRIGGER 2
-- ---------------------------------------------------------

-- Objetivo: Mostrar aviso

-- Executa: RAISE NOTICE 'Cliente cadastrado';

-- Saída: Cliente cadastrado

-- =========================================================
-- ---------------------- FLUXO COMPLETO
-- =========================================================

-- INSERT pedro
--       ↓

-- BEFORE 1
-- pedro
-- → PEDRO
-- RETURN NEW

--       ↓

-- BEFORE 2
-- PEDRO
-- → PEDRO SILVA
-- RETURN NEW

--       ↓

-- INSERT REAL
-- tb_cliente ← PEDRO SILVA

--       ↓

-- AFTER 1
-- cria log

--       ↓

-- AFTER 2
-- mostra aviso

-- ---------------------------------------------------------
-- ----------- CASO ESPECIAL: RETURN NULL
-- ---------------------------------------------------------

-- INSERT:

-- INSERT INTO tb_cliente(nome)
-- VALUES ('pedro');

-- Trigger BEFORE executa:

-- RETURN NULL;

-- Fluxo:

-- INSERT pedro
--       ↓
-- BEFORE
-- RETURN NULL
--       ↓
-- INSERT CANCELADO
--       ↓
-- AFTER NÃO EXECUTA

-- Tabela:

-- tb_cliente

-- (vazia)

-- RETURN NULL significa -> "Não deixe o registro continuar"
