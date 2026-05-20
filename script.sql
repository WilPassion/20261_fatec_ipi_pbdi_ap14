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

-- Bloco de Código 2.4.5 - - TG DEPOIS DO INSERT
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

--* BEFORE vem antes do AFTER --> BEFORE → operação → AFTER
--* Ordem alfabética --> Mesmo tipo → ordem alfabética

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

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- DELETE FROM tb_teste_trigger_cod_teste_trigger_seq;

-- SELECT * FROM tb_teste_trigger_cod_teste_trigger_seq;

-- ALTER SEQUENCE tb_teste_trigger_cod_teste_trigger_seq RESTART WITH 1;

-- DROP TRIGGER IF EXISTS tg_antes_do_insert2 ON tb_teste_trigger;
-- DROP TRIGGER IF EXISTS tg_depois_do_insert2 ON tb_teste_trigger;

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- CREATE OR REPLACE TRIGGER tg_antes_do_insert
-- BEFORE INSERT OR UPDATE ON tb_teste_trigger
-- FOR EACH STATEMENT 
-- -- pode-se inserir parâmetros na chamada 
-- EXECUTE PROCEDURE fn_antes_de_um_insert('Antes: V1', 'Antes: V2')

-- CREATE OR REPLACE TRIGGER tg_depois_do_insert
-- BEFORE INSERT OR UPDATE ON tb_teste_trigger
-- FOR EACH STATEMENT 
-- EXECUTE PROCEDURE fn_depois_de_um_insert('Depois: V1', 'Depois: V2', 'Depois: V3')


-- Bloco de Código 2.5.4
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
--     LOOP
--         RAISE NOTICE '%', TG_ARGV[i];
--     END LOOP;

--     RETURN NEW;
-- END;
-- $$;

-- --teste
-- INSERT INTO tb_teste_trigger (texto)
-- VALUES ('testando trigger');

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

-- 2.6 (Trigger: um sistema com auditoria) Suponha que temos uma tabela que armazena
-- dados de pessoas incluindo valores monetários que possuem. Desejamos registrar em uma
-- tabela todas as movimentações monetárias realizadas: tanto novos cadastros quanto a
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
--     ('Maria Oliveira', 32, 3200.50),
--     ('Carlos Souza', 41, 980.00),
--     ('Ana Pereira', 28, 4570.90),
--     ('Sem dinheiro', 36, 500);

-- DROP TABLE IF EXISTS tb_auditoria;
-- CREATE TABLE IF NOT EXISTS tb_auditoria(
-- 	cod_auditoria SERIAL PRIMARY KEY,
-- 	cod_pessoa INT NOT NULL,
-- 	idade INT NOT NULL,
-- 	saldo_antigo NUMERIC (10, 2),
-- 	saldo_atual NUMERIC(10, 2)
-- );

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

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

-- --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Bloco de Código 2.6.3 - trigger para fazer o VÍNCULO entre functionXtable
-- DROP TRIGGER IF EXISTS tg_validador_de_saldo ON tb_pessoa;
-- CREATE TRIGGER tg_validador_de_saldo
-- BEFORE INSERT OR UPDATE ON tb_pessoa
-- FOR EACH ROW
-- EXECUTE FUNCTION fn_validador_de_saldo();

-- UPDATE tb_pessoa SET saldo = -100
-- WHERE cod_pessoa = 5;

-- SELECT * FROM tb_pessoa;

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