SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mwgames
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mwgames` DEFAULT CHARACTER SET utf8 ;
USE `mwgames` ;

-- -----------------------------------------------------
-- Table `funcionario`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `funcionario` ;

CREATE TABLE IF NOT EXISTS `funcionario` (
  `idfuncionario` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `cpf` CHAR(14) NOT NULL,
  `rg` CHAR(16) NOT NULL,
  `sexo` ENUM('M', 'F') NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `sys_user` VARCHAR(45) NOT NULL,
  `sys_password` VARCHAR(45) NOT NULL,
  `fg_ativo` ENUM('S', 'N') NOT NULL,
  PRIMARY KEY (`idfuncionario`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `produto`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `produto` ;

CREATE TABLE IF NOT EXISTS `produto` (
  `idproduto` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(200) NOT NULL,
  `codigo_barras` VARCHAR(45) NULL,
  `qt_estoque` INT NOT NULL,
  `preco` DOUBLE NOT NULL,
  `url_imagem` TEXT NOT NULL,
  `fg_ativo` ENUM('S', 'N') NOT NULL,
  PRIMARY KEY (`idproduto`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tipo_pagamento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tipo_pagamento` ;

CREATE TABLE IF NOT EXISTS `tipo_pagamento` (
  `idtipo` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idtipo`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `venda`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `venda` ;

CREATE TABLE IF NOT EXISTS `venda` (
  `idvenda` INT NOT NULL AUTO_INCREMENT,
  `f_idfuncionario` INT NOT NULL,
  `tp_idpagamento` INT NOT NULL,
  `data_venda` DATETIME NOT NULL,
  `preco_venda` DOUBLE NOT NULL,
  PRIMARY KEY (`idvenda`),
  INDEX `fk_venda_funcionario_idx` (`f_idfuncionario` ASC) VISIBLE,
  INDEX `fk_venda_tipo_pagamento_idx` (`tp_idpagamento` ASC) VISIBLE,
  CONSTRAINT `fk_venda_funcionario`
    FOREIGN KEY (`f_idfuncionario`)
    REFERENCES `funcionario` (`idfuncionario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_tipo_pagamento1`
    FOREIGN KEY (`tp_idpagamento`)
    REFERENCES `tipo_pagamento` (`idtipo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `venda_item`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `venda_item` ;

CREATE TABLE IF NOT EXISTS `venda_item` (
  `v_idvenda` INT NOT NULL,
  `p_idproduto` INT NOT NULL,
  `quantidade` INT NOT NULL,
  `total_preco_item` DOUBLE NOT NULL,
  PRIMARY KEY (`v_idvenda`, `p_idproduto`),
  INDEX `fk_venda_item_produto_idx` (`p_idproduto` ASC) VISIBLE,
  INDEX `fk_venda_item_venda_idx` (`v_idvenda` ASC) VISIBLE,
  CONSTRAINT `fk_venda_item_venda`
    FOREIGN KEY (`v_idvenda`)
    REFERENCES `venda` (`idvenda`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_item_produto`
    FOREIGN KEY (`p_idproduto`)
    REFERENCES `produto` (`idproduto`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- -----------------------------------------------------
-- Views
-- -----------------------------------------------------
CREATE VIEW relatorio_venda AS 
	SELECT 
		v.idvenda, p.nome AS produto, vi.quantidade, vi.total_preco_item AS preco_item,
		DATE_FORMAT(v.data_venda, '%d/%m/%Y %H:%i') AS data_venda, 
		v.preco_venda, tp.descricao AS tipo_pagamento,
		f.nome AS vendido_por, f.idfuncionario
	FROM 
		venda v
		JOIN venda_item vi ON(v.idvenda = vi.v_idvenda)
		JOIN tipo_pagamento tp ON(v.tp_idpagamento = tp.idtipo)
		JOIN produto p ON(vi.p_idproduto = p.idproduto)
		JOIN funcionario f ON(v.f_idfuncionario = f.idfuncionario)
	ORDER BY 
		v.idvenda, p.nome;

-- -----------------------------------------------------
-- Inserts
-- -----------------------------------------------------
INSERT INTO funcionario(nome, cpf, rg, sexo, data_nascimento, sys_user, sys_password, fg_ativo) VALUES
	('João da Silva', '520.380.988-78', '40.630.200-5', 'M', '2000-10-11', 'joaozinho123', 'joaozinho123', 'S'),
	('Maria de Souza', '090.250.100-80', '22.747.940-3', 'F', '1982-05-23', 'mariazinha123', 'mariazinha123', 'S'),
 	('Pedro dos Santos', '333.180.743-12', '33.284.038-4', 'M', '1980-04-07', 'pedro123', 'pedro123', 'N'),
 	('Júlia Ribeiro', '200.451.190-72', '42.780.928-X', 'F', '1991-06-02', 'julia123', 'julia123', 'S');


INSERT INTO produto(nome, codigo_barras, qt_estoque, preco, url_imagem, fg_ativo) VALUES 
	('Star Wars Jedi Fallen Order - PS4', '1234567', 50, 150.58, 'https://uploads.jovemnerd.com.br/wp-content/uploads/2019/06/star-wars-jedi-fallen-order-capa2.jpg', 'S'),
	('Forza Horizon 5 - Xbox SX', '1234568', 42, 250.99, 'https://m.media-amazon.com/images/I/71LSwnEXpXL._AC_SX425_.jpg', 'S'),
	('Pokémon Arceus - Nintendo Switch', NULL, 1, 299.99, 'https://m.media-amazon.com/images/I/71HYKF4rO9L._AC_SY550_.jpg', 'S'),
	('God of War - PS4', NULL, 0, 99.90, 'https://cdn.awsli.com.br/600x450/1295/1295135/produto/59377037/901a930f4d.jpg', 'N'),
	('Halo The Master Chief Collection - Xbox One', '658286743', 50, 80, 'https://media.s-bol.com/K83QQkwjyy1n/550x695.jpg', 'S'),
	('Mass Effect Legendary Edition - PS5', '683487679', 2, 250.99, 'https://cdn.awsli.com.br/600x700/2155/2155174/produto/131803745/mass-effect-legendary-edition-ps5-psn-ingles-0917c6a6.jpg', 'S'),
	('Fifa 22 - PS4', NULL, 42, 149, 'https://m.media-amazon.com/images/I/810V2t+RstL._AC_SX425_.jpg', 'S'),
	('The Elder Scrolls V: Skyrim - Special Edition - Xbox One', NULL, 10, 80, 'https://m.media-amazon.com/images/I/81dDIETeEiL._AC_SX385_.jpg', 'S'),
	('Grand Theft Auto 5 - PS5', '2548294643', 1, 134, 'https://cdn.awsli.com.br/800x800/2155/2155215/produto/134087821/grand-theft-auto-gta-v-5-ps5-midia-digital-929115a9.jpg', 'S'),
	('Elden Ring - Xbox SX', NULL, 70, 233.91, 'https://m.media-amazon.com/images/I/81AXuMBqy9L._AC_SL1500_.jpg', 'S'),
	('Super Mario Bros. U Deluxe - Nintendo Switch', '278492', 150, 339, 'https://m.media-amazon.com/images/I/813JPZr+pCL._AC_SL1500_.jpg', 'S'),
	('The Legend Of Zelda: Breath Of The Wild - Nintendo Switch', '84393', 135, 418, 'https://m.media-amazon.com/images/I/81yCdxV54SL._AC_SL1500_.jpg', 'S');


INSERT INTO tipo_pagamento(descricao) VALUES
	('DINHEIRO'),
	('CARTÃO DE DÉBITO'),
	('CARTÃO DE CRÉDITO');


-- -----------------------------------------------------
-- Procedures
-- -----------------------------------------------------
DELIMITER $$
$$
CREATE PROCEDURE mwgames.ATUALIZA_ESTOQUE(IN `idproduto` int, IN `qtde_retirada` int)
BEGIN
	DECLARE qtde_anterior int;
			
	SELECT p.qt_estoque INTO qtde_anterior FROM produto p WHERE p.idproduto = idproduto;
	UPDATE produto p SET p.qt_estoque = (qtde_anterior - qtde_retirada) WHERE p.idproduto = idproduto;
END;

CREATE PROCEDURE mwgames.ATUALIZA_PRECO_VENDA(IN `id_venda` INT, IN `valor_soma` DOUBLE)
BEGIN
	DECLARE preco_anterior DOUBLE;
	SELECT preco_venda INTO preco_anterior FROM venda WHERE idvenda = id_venda;
	UPDATE venda SET preco_venda = (preco_anterior + valor_soma) WHERE idvenda = id_venda;
END;

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------
CREATE TRIGGER TRG_ATUALIZA_ESTOQUE
AFTER INSERT
ON venda_item FOR EACH ROW
BEGIN
	CALL ATUALIZA_ESTOQUE(new.p_idproduto, new.quantidade);
	CALL ATUALIZA_PRECO_VENDA(new.v_idvenda, new.total_preco_item);
END; 
$$
DELIMITER ;

