/*Criando tabelas */
create table Clientes(
	codigo numeric(5) not null,
    nome char(30) not null,
	endereco char(30),
    cidade char(30),
    fone char(12),
    primary key(codigo)
);

create table produtos(
	codigo numeric(5) not null,
    descricao char(30) not null,
    qtde_est numeric(5),
    preco numeric(5,2),
    /*check (qtde_est >= 0)*/
    constraint checar_qtde_est
		check (qtde_est >= 0),
	constraint checar_preco
		check (preco >=0),
	primary key(codigo)
);

create table notas(
	num_nota numeric(6) not null,
    cod_cli numeric(5) not null,
    data date not null,
   constraint FK_cod_cli foreign key (cod_cli)
   references clientes (codigo),
   primary key(num_nota)
);

create table itens_nota(
	num_nota numeric(6) not null,
    cod_prod numeric(5) not null,
    qtde numeric(5),
    constraint checar_qtde 
		check(qtde>=0),
	constraint FK_cod_prod foreign key(cod_prod)
    references produtos(codigo),
    primary key (num_nota, cod_prod)
);
/*Fim da Criaçao das tabelas*/

/*Inserindo Dados*/

/*Cliente*/
insert into clientes (codigo,nome,endereco,cidade,fone) values
	(1,'Jose', 'Av. Brasil', 'Rio de Janeiro','111-111'),
    (2,'Rita','R. X', 'X', '222-222'),
    (3,'Carlos', 'Av. 500', 'Gama', '333-333');

insert into produtos (codigo, descricao, qtde_est,preco) values
	(1,'Tomate',50.0, 2),
    (2,'Macarrao', 10, 5),
    (3, 'Alface',100,1);
    
    

insert into notas(num_nota, cod_cli, data) values
			(1, 1, "2020-09-10"),
            (2, 2, "2020-08-20");

insert into itens_nota(num_nota, cod_prod, qtde) values
			(1,1,2),
            (1,2,3),
            (2,3,10);
            
 
/*3*/
/*Visão Gastos */
create view vGastosClientes
	as
    select C.codigo, C.nome,sum((P.preco * I.qtde)) as total_gasto
    from clientes C inner join notas N
    on C.codigo = N.cod_cli
    inner join itens_nota I 
    on N.num_nota = I.num_nota
    inner join produtos P
    on P.codigo = I.cod_prod
    where (curdate() - data ) <=30
    group by  C.codigo, C.nome;
    
/*4 */

create view vBusca
	as  
    select C.codigo, C.nome, C.cidade 
    from clientes C 
    where C.cidade = "Samambaia" or C.cidade = "Sao Paulo";
  
  /*
    insert into clientes (codigo,nome,endereco,cidade,fone) values
	(4,'Pedro', 'Av. sem nome', 'Samambaia','444-444'),
    (5,'Maria','R. da maria', 'Sao Paulo', '555-555'),
    (6,'Joao', 'Rua sem fim', 'Samambaia', '666-666');
    
    */
    
    delete from clientes 
    where codigo > 3;
    
   
/*5 Nao e recomedado inserir dados por meio visao */
insert into Vbusca (codigo,nome,cidade) values
	(123,"Joao", "Samambaia"),
    (321,"Ana", "Gama");

/*6*/
create view vSomaDeVendas 
	as 
    select P.codigo, P.descricao, sum(I.qtde) as TotalDeQuantidade,
    sum(I.qtde * P.preco) as TotalVendido
    from produtos as P 
    inner join itens_nota as I
    on P.codigo = I.cod_prod
    inner join notas as N
    on N.num_nota = I.num_nota
    where(curdate() - N.data) <= 30 
    group by P.descricao;
    
/*7*/
select codigo,descricao from vsomadevendas
where TotalDeQuantidade >100;


/*8*/
create view vCodigoNome
	as
    select C.codigo, C.nome,I.cod_prod,P.descricao, I.qtde,(I.qtde * P.preco) as Total
    from clientes as C
    inner join notas as N
    on C.codigo = N.cod_cli
    inner join itens_nota as I
    on N.num_nota = I.num_nota
    inner join produtos as P
    on I.cod_prod = P.codigo
    where (curdate() - N.data) <=30 
    group by C.codigo, C.nome,I.cod_prod, P.descricao;

/*9*/ 
select nome from vCodigoNome as V
inner join notas as N
on N.cod_cli = V.codigo
	where (curdate() - N.data) <= 30 and V.descricao = "Mesa Redonda de Mogno";
    
/*Adcionando os dados da messa redonda para testa*/
insert into produtos (codigo, descricao, qtde_est,preco) values
	(4,'Mesa Redonda de Mogno',5, 2000);
    
    insert into notas(num_nota, cod_cli, data) values
			(3, 1, "2020-09-01");
    
insert into itens_nota(num_nota, cod_prod, qtde) values
			(1,4,2);

delete from produtos 
    where codigo = 4;
/*----------------------------*/

/*10 arruamar*/

    
    create view vDadosProdutos
	as  select P.codigo, P.descricao,P.qdte_est
    from produtos as P
    where P.codigo not in (
    select codigo 
    from itens_nota as I
    inner join notas as N
    on I.cod_prod = N.num_nota
    where N.data > "2019-01-01"); 
    
    /*Adcionando dados antes de 2019 para teste*/
    insert into produtos (codigo, descricao, qtde_est,preco) values
	(4,'Sapatos',10, 80);
	insert into notas(num_nota, cod_cli, data) values
			(3, 3, "2018-12-20");
    insert into itens_nota(num_nota, cod_prod, qtde) values
			(3,4,2);
            
/*11*/
select descricao
from vDadosProdutos as V
inner join itens_nota as I
	on I.cod_prod = V.codigo
inner join notas as N
    on N.num_nota = I.num_nota
where not (N.data = "2018") and V.qtde_est >100;

/*12*/
SET SQL_SAFE_UPDATES = 0;

   UPDATE produtos 
set produtos.preco = 
    produtos.preco * 1.2
	where (produtos.preco >= 100 );
    
    UPDATE produtos 
set produtos.preco = 
  produtos.preco= produtos.preco * 1.1
	where (produtos.preco < 100 );

/*13*/
SET SQL_SAFE_UPDATES = 0;

delete from itens_nota
where cod_prod in(
	select codigo from produtos
    where descricao = "cd"
);

delete from produtos where 
	descricao='cd';

 select * from produtos;
 select * from itens_nota;
 
 insert into itens_nota(num_nota, cod_prod, qtde) values
			(2,4,1);
 insert into produtos (codigo, descricao, qtde_est,preco) values
	(5,'cd',10, 20);
 
 /*14*/
 alter table itens_nota
 add preco_uni decimal(5,2);
 
  alter table itens_nota
  add check (preco_uni >=0);
 /*15*/
 DELIMITER //
	create procedure atribueValor()
    begin
		update itens_nota	
        inner join produtos 
        on produtos.codigo = itens_nota.cod_prod
			set itens_nota.preco_uni = produtos.preco;
	END //
 DELEMITER ;
 
   select * from itens_nota;
 
 call atribueValor();
 drop procedure atribueValor;
 


 /*16*/
create function Num_Notas(numNota int)
returns int
return (
	select (sum(I.qtde * P.preco)) 
    from itens_nota as I
    inner join produtos as P 
    on P.codigo = I.cod_prod
    where (I.num_nota = numNota)
    );
    
	select Num_Notas(4) as TotalGastoNota;
    
/*17*/
DELiMITER $
create trigger Tgr_Reduzir_Insert after insert
on itens_nota
for each row
begin
	update produtos set qtde_est = qtde_est - New.qtde
where codigo = new.cod_prod;
END $
/*Inserindo o produto diminuir a quantidade de estoque na tabela Produtos*/
insert into itens_nota(num_nota, cod_prod, qtde) values
			(4,2,5);
            
  /*18*/          
DELiMITER $
create trigger Tgr_Alteracao_Insert after update
on itens_nota
for each row
begin
	update produtos set qtde_est = qtde_est - New.qtde
where codigo = new.cod_prod;
END $
            

