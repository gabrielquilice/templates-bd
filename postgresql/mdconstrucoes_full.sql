-- -----------------------------------------------------
-- Tabelas
-- -----------------------------------------------------
create table funcionario(
	idfuncionario serial primary key,
	nome varchar(45) not null,
	cpf char(14) not null,
	rg char(16) not null,
	sexo char(1) check (sexo in ('M', 'F')) not null,
	data_nascimento date not null,
	usuario varchar(45) unique not null,
	senha varchar(45) not null,
	fg_ativo char(1) check (fg_ativo in ('S', 'N')) not null
);

create table fornecedor(
	idfornecedor serial primary key,
	nome varchar(45) not null,
	estado char(2) not null,
	telefone varchar(11)
);

create table produto(
	idproduto serial primary key,
	f_idfornecedor int not null,
	nome varchar(200) not null,
	codigo_barras varchar(45),
	qt_estoque int not null,
	preco decimal(10, 2) not null,
	fg_ativo char(1) check (fg_ativo in ('S', 'N')) not null,
	foreign key (f_idfornecedor) references fornecedor(idfornecedor) on delete restrict on update cascade
);

create table tipo_pagamento(
	idtipo serial primary key,
	descricao varchar(45) not null
);

create sequence vendaseq increment by 1 start with 1;

create table venda(
	idvenda int primary key default nextval('vendaseq'),
	f_idfuncionario int not null,
	tp_idpagamento int not null,
	data_venda timestamp,
	preco_venda decimal(10, 2) not null,
	foreign key (f_idfuncionario) references funcionario(idfuncionario) on delete restrict on update cascade,
	foreign key (tp_idpagamento) references tipo_pagamento(idtipo) on delete restrict on update cascade
);

create table venda_item(
	v_idvenda int not null,
	p_idproduto int not null,
	quantidade int not null,
	total_preco_item decimal(10, 2) not null,
	foreign key (v_idvenda) references venda(idvenda) on delete restrict on update cascade,
	foreign key (p_idproduto) references produto(idproduto) on delete restrict on update cascade
);

-- -----------------------------------------------------
-- Views
-- -----------------------------------------------------
create view produtos_vendidos_mes as
	select 
		p.nome as produto,
		fo.nome as fornecedor,
		sum(vi.quantidade) as total_vendido
	from 
		produto p
		join fornecedor fo on (p.f_idfornecedor = fo.idfornecedor)
		join venda_item vi on (vi.p_idproduto = p.idproduto)
		join venda v on (vi.v_idvenda = v.idvenda)
	where
		extract (month from v.data_venda) = extract(month from now())
	group by 1, 2
	order by p.nome;

create view produtividade_funcionario as 
	select 
		f.nome as funcionario, 
		count(distinct v.idvenda) as total_vendas,
		sum(vi.quantidade) as total_itens_vendidos
	from
		funcionario f
		join venda v on (v.f_idfuncionario = f.idfuncionario)
		join venda_item vi on (v.idvenda = vi.v_idvenda)
	group by 1
	order by f.nome;

create view relatorio_venda as 
	select 
		v.idvenda, f.nome as funcionario,
		v.preco_venda as valor_total_venda,
		to_char(v.data_venda, 'dd/mm/yyy HH:MM') as data_venda,
		tp.descricao as tipo_pagamento,
		p.nome as produto, fo.nome as fornecedor,
		vi.quantidade as qtd_itens,
		vi.total_preco_item as sub_total
	from 
		venda v
		join funcionario f on (v.f_idfuncionario = f.idfuncionario)
		join tipo_pagamento tp on (v.tp_idpagamento = tp.idtipo)
		join venda_item vi on (vi.v_idvenda = v.idvenda)
		join produto p on (vi.p_idproduto = p.idproduto)
		join fornecedor fo on (p.f_idfornecedor = fo.idfornecedor)
	order by v.idvenda, p.nome;

-- -----------------------------------------------------
-- Inserts
-- -----------------------------------------------------
insert into funcionario(nome, cpf, rg, sexo, data_nascimento, usuario, senha, fg_ativo) values
	('Yasmin Laura Silvana Fernandes', '558.054.463-40', '27.133.164-1', 'F', '2000-05-14', 'yasmin@tes', md5('usuario1'), 'S'),
	('Levi Igor Henrique Assunção', '694.221.682-87', '39.474.311-8', 'M', '1987-04-05', 'levi123', md5('usuario2'), 'S'),
	('Luís Guilherme Lopes', '852.216.516-53', '28.843.998-3', 'M', '1982-04-10', 'jokerTT', md5('usuario3'), 'N'),
	('José Enzo Pinto', '192.880.029-79', '43.416.788-5', 'M', '1999-05-03', 'teste1', md5('usuario4'), 'S'),
	('Alessandra Rita Vieira', '785.755.691-20', '21.700.262-6', 'F', '1961-03-01', 'aleDDy', md5('usuario5'), 'N'),
	('Eloá Raquel da Cunha', '554.127.053-75', '26.031.882-6', 'F', '1986-05-20', 'teste2', md5('usuario6'), 'S'),
	('Maya Giovana Assis', '775.802.058-58', '23.748.595-3', 'F', '1954-02-21', 'maya@em.com', md5('usuario7'), 'S'),
	('Bárbara Mariane Campos', '105.389.486-47', '32.844.278-1', 'F', '1977-05-11', 'barb123', md5('usuario8'), 'N'),
	('André João Julio da Rocha', '341.731.707-00', '18.367.832-1', 'M', '1988-06-05', 'andre@br.tz', md5('usuario9'), 'S'),
	('Ian Manoel Barros', '158.000.584-58', '34.476.307-9', 'M', '1945-06-01', 'ian.manoe@icloud.com', md5('usuario10'), 'S'),
	('Anderson Anthony Silva', '729.395.357-79', '27.718.867-2', 'M', '1986-02-21', 'anderson_silva@br.festo.com', md5('oIgXAMFRKd'), 'S'),
	('João Sérgio Carlos Eduardo Sales', '129.079.474-00', '22.724.382-1', 'M', '1947-02-21', 'joao_sales@gastrolight.com.br', md5('myYWK6fZ2j'), 'S'),
	('Cláudia Andreia Helena Vieira', '323.274.579-20', '41.562.719-9', 'F', '1953-03-17', 'claudiaandreiavieira@cfaraujo.eng.br', md5('yqHXauumG8'), 'S'),
	('Sebastiana Louise Silva', '991.332.886-15', '24.656.074-5', 'F', '1943-06-17', 'sebastiana.louise.silva@jglima.com.br', md5('Ze1DjfCjoZ'), 'S'),
	('Arthur Theo Aragão', '683.043.421-11', '27.407.654-8', 'M', '1988-03-19', 'arthur-aragao76@cressem.com.br', md5('AWsZA9F2UI'), 'S'),
	('Heitor Marcelo Thiago Aparício', '636.289.009-48', '11.314.584-6', 'M', '1979-05-27', 'heitor_marcelo_aparicio@bernardino.co', md5('J6HdgXFzBW'), 'N'),
	('Carolina Allana Lavínia Gonçalves', '563.384.427-02', '42.333.841-9', 'F', '1997-04-23', 'carolina_allana_goncalves@c-a-m.com', md5('iRc3HDayYs'), 'S'),
	('Theo Gabriel Nascimento', '160.307.222-55', '37.482.154-9', 'M', '1976-06-12', 'theo.gabriel.nascimento@centrooleo.com.br', md5('nEHGNzP12j'), 'N'),
	('Flávia Carolina Brenda Carvalho', '839.443.828-89', '47.398.480-5', 'F', '1985-05-13', 'flaviaclcarvalho@yahoo.com.com.br', md5('Odpn7GePF3'), 'S'),
	('Bianca Daiane Luzia Moraes', '939.712.801-96', '13.971.318-9', 'F', '1971-05-21', 'bianca.moraes82@hotmail.de', md5('CpfyJbwLfJ'), 'N');

insert into fornecedor(nome, estado, telefone) values 
	('Matheus e Henry Comercios ME', 'SP', '11986421428'),
	('Josefa e Martin Inc. ME', 'SP', '11994114718'),
	('Vicente e Vitor Elet. ME', 'MG', '35984131835'),
	('Delix Ltda', 'MG', '3535495034'),
	('ERD Ltda', 'MG', '3426324379'),
	('Gabriel e Juan ME', 'MG', '34982016952'),
	('Valentina e Bruno Comercio Inc.', 'SE', '7927334207'),
	('BeR Ltda', 'SE', '7927034943'),
	('Daniela e Letícia ME', 'PR', '41982849848'),
	('Ricardo Lopes M Ltda', 'PR', '4339055750'),
	('Matheus e Marcos Ferragens Ltda', 'PR', '44994679110'),
	('José e Simone ME', 'RN', '8438597166'),
	('Rayssa e Yago Express', 'RN', '8438205702'),
	('Oliver e Osvaldo ME', 'RN', '84988854228'),
	('Isabelle e Stefany Padaria ME', 'RN', '8438056308'),
	('Yuri e Pietra Ens Ltda', 'MA', '98986346455'),
	('SD Ltda', 'MA', '98994184184'),
	('Igor e Laura GR Ltda', 'MA', '9929965703'),
	('Restoe ME', 'MA', '98991192613'),
	('Theo e Tereza Ltda', 'AC', '68996699900');

insert into produto(f_idfornecedor, nome, codigo_barras, qt_estoque, preco, fg_ativo) values
	(1, 'Abracadeira Fix 32MM Branca Amanco', null, 300, 1.59, 'S'),
	(2, 'Acessorios para Varal Teto Maxeb', '338472910', 0, 15.80, 'S'),
	(3, 'Cera Laca para Cimento Queimado 500ML Portokoll', null, 16, 40.32, 'S'),
	(4, 'Chave Fenda (A) 1/8X5 C/PI Cabo Amarelo Thompson', '8394057729', 3, 7.89, 'N'),
	(5, 'Cimento Queimado Fendi Balde 5KG Portokoll', '13888888', 40, 88.59, 'S'),
	(6, 'Dobradica 1400 FLO com Anel 3.1/2 Cartela 3PC Schild', null, 150, 2.76, 'S'),
	(7, 'Grampeador Tapeceiro Revolver 4 14MM C/100 Grampos Thompson', null, 1, 30, 'N'),
	(8, 'Kit Ferramentas 8PC Thompson', '8385830', 78, 66.32, 'S'),
	(8, 'Mini Disjuntor Tripolar 63A 3KA Tramontina', null, 22, 15.28, 'N'),
	(8, 'Vedax Chapisco PVA 3,6L Vedax', null, 60, 99.30, 'S'),
	(9, 'Cavadeira 2 Cabos Articulada Madeira Tucano 1,65M Alpe', null, 124, 45, 'S'),
	(15, 'Facão Cana PP CB/310MM Alpe', '0038485', 76, 30.50, 'N'),
	(20, 'Arco De Serra Para Madeira Tipo C 21" Ramada', null, 382, 22, 'S'),
	(11, 'Esquadro Cabo Aluminio 14" Ramada', '637292', 12, 6.45, 'S'),
	(10, 'Pá De Bico C/Cabo Y Plastico N.3', null, 14, 35, 'S'),
	(14, 'Serrote Costa 12" 9 Dentes', '44442564859', 1, 33, 'N'),
	(18, 'Rejunte Ceramicas Caramelo 1KG Quartzolit', null, 4, 55, 'S'),
	(19, 'Rejunte Porcelanato Onix 1KG Quartizolit', null, 72, 61, 'S'),
	(17, 'Desempenadeira Pvc Corrugada 22x34 Seniors', '9847133', 81, 25.9, 'S'),
	(1, 'Disco De Fibra Reforcado Basic 115x22 S4 A Tyrolit', null, 90, 101, 'S');

insert into tipo_pagamento(descricao) values 
	('Cartão de crédito'),
	('Cartão de débito'),
	('À vista'),
	('Pix'),
	('Boleto'),
	('Transferência bancária');
	
insert into venda(f_idfuncionario, tp_idpagamento, data_venda, preco_venda) values 
	(1, 6, now(), 1371.04), 
	(2, 4, (now() - interval '1 day'), 2318), 
	(3, 1, (now() - interval '1 day 14 minutes'), 1603.9), 
	(9, 5, (now() - interval '2 days 3 hours'), 85.56), 
	(20, 2, (now() - interval '2 days 4 hours'), 303.15), 
	(15, 3, (now() - interval '3 days 30 minutes'), 792), 
	(11, 6, (now() - interval '3 days 3 hours'), 9509.62), 
	(15, 3, (now() - interval '3 days 5 hours'), 489.8), 
	(6, 1, (now() - interval '4 days'), 1595), 
	(15, 3, (now() - interval '4 days 15 minutes'), 777), 
	(19, 4, (now() - interval '5 days'), 1838.58), 
	(12, 5, (now() - interval '5 days'), 1980), 
	(17, 1, (now() - interval '5 days'), 534.8), 
	(2, 4, (now() - interval '5 days'), 1169.28), 
	(14, 6, (now() - interval '1 week 10 minutes'), 875), 
	(13, 3, (now() - interval '1 week 30 minutes'), 1260.08),
	(11, 2, (now() - interval '1 week 45 minutes'), 640.5), 
	(9, 3, (now() - interval '1 week 5 hours'), 1419), 
	(14, 6, (now() - interval '3 weeks 10 hours'), 584.6), 
	(18, 2, (now() - interval '3 weeks 11 hours'), 1603.08);

insert into venda_item(v_idvenda, p_idproduto, quantidade, total_preco_item) values 
	(1, 8, 22, 1371.04),
	(2, 18, 38, 2318),
	(3, 12, 50, 1525),
	(3, 4, 10, 78.9),
	(4, 6, 31, 85.56),
	(5, 14, 47, 303.15),
	(6, 13, 36, 792),
	(7, 5, 28, 2480.42),
	(7, 10, 24, 2383.2),
	(7, 20, 46, 4646),
	(8, 2, 31, 489.8),
	(9, 17, 29, 1595),
	(10, 19, 30, 777),
	(11, 5, 20, 1771.8),
	(11, 1, 42, 66.78),
	(12, 11, 44, 1980),
	(13, 9, 35, 534.8),
	(14, 3, 29, 1169.28),
	(15, 15, 25, 875),
	(16, 8, 19, 1260.08),
	(17, 12, 21, 640.5),
	(18, 16, 43, 1419),
	(19, 2, 37, 584.6),
	(20, 5, 12, 1063.08),
	(20, 7, 18, 540);

-- -----------------------------------------------------
-- Functions
-- -----------------------------------------------------
create or replace function produtos_estoque_menor(qtd int, out produto varchar(200), out fornecedor varchar(45), out qtd_estoque int) 
    returns setof record as
$$
declare
    x record;
begin
    for x in (select p.*, fo.nome as fornecedor 
		    	from produto p 
		    		join fornecedor fo on (p.f_idfornecedor = fo.idfornecedor)
		    	where qt_estoque <= qtd)
    loop
	    produto := x.nome;
	    fornecedor := x.fornecedor;
	    qtd_estoque := x.qt_estoque;
        return next;
    end loop;
end;
$$
language plpgsql;

create or replace function retira_estoque(idprod int, qtde_retirada int) returns void as
$$
declare
	qtde_anterior int;
begin
	select p.qt_estoque into qtde_anterior from produto p where p.idproduto = idprod;
	update produto set qt_estoque = (qtde_anterior - qtde_retirada) where idproduto = idprod;
end;
$$
language plpgsql;

create or replace function repoe_estoque(idprod int, qtde_reposta int) returns void as
$$
declare
	qtde_anterior int;
begin
	select p.qt_estoque into qtde_anterior from produto p where p.idproduto = idprod;
	update produto set qt_estoque = (qtde_anterior + qtde_reposta) where idproduto = idprod;
end;
$$
language plpgsql;

create or replace function atualiza_preco_venda(id_venda int, valor_soma decimal(10,2)) returns void as 
$$
declare
	preco_anterior decimal(10, 2);
begin 
	select preco_venda into preco_anterior from venda where idvenda = id_venda;
	update venda set preco_venda = (preco_anterior + valor_soma) where idvenda = id_venda;
end;
$$
language plpgsql;

create or replace function atualiza_estoque() returns trigger as $$
begin 
	if (TG_OP = 'INSERT') then
		perform retira_estoque(new.p_idproduto, new.quantidade);
		perform atualiza_preco_venda(new.v_idvenda, new.total_preco_item);
		return new;
	elsif (TG_OP = 'DELETE') then
		perform repoe_estoque(old.p_idproduto, old.quantidade);
		return old;
	end if;
	return null;
end;
$$
language plpgsql;

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------
create trigger tgr_atualiza_estoque after insert or delete on venda_item for each row
execute procedure atualiza_estoque();