/*Condi��es para Clientes Qualificados
Para que um cliente seja considerado "novo" e qualificado, ele deve cumprir todas as seguintes regras:

Padr�o de Pedidos: Fazer pedidos em cada um dos seus primeiros 3 meses consecutivos desde a data do primeiro pedido.

Crescimento no M�s 2: O n�mero de pedidos no segundo m�s deve ser exatamente o dobro dos pedidos do primeiro m�s.

Crescimento no M�s 3: O n�mero de pedidos no terceiro m�s deve ser exatamente o triplo dos pedidos do primeiro m�s.

�ltimo Pedido com Cupom: O pedido mais recente do cliente deve ter sido feito com um cupom (cupom_code n�o pode ser nulo).*/


/*==========================================================================================================================================*/


/*1. cte (Tabela de Informa��es Agregadas)
A primeira CTE, cte, � a base de tudo. Ela pega todos os pedidos e adiciona informa��es essenciais usando fun��es de janela.

DATETRUNC(month, order_date) as order_month: Essa fun��o trunca a data do pedido para o primeiro dia do m�s, o que � �til para agrupar os pedidos por m�s.

MIN(datetrunc(month, order_date)) over(partition by customer_id) as first_order_month: Esta fun��o de janela encontra o m�s do primeiro pedido de cada cliente. A palavra-chave partition by customer_id garante que a data do primeiro pedido seja calculada separadamente para cada cliente.

LAST_VALUE(coupon_code) over(partition by customer_id order by order_date rows between unbounded preceding and unbounded following) as last_coupon: Esta � a parte mais complexa da primeira CTE. Ela encontra o valor do coupon_code do �ltimo pedido de cada cliente.

partition by customer_id novamente divide os dados por cliente.

order by order_date garante que a ordem dos pedidos seja cronol�gica.

rows between unbounded preceding and unbounded following � crucial, pois informa ao SQL para examinar todas as linhas de um cliente para encontrar o �ltimo valor. Se a �ltima linha tiver um cupom (IS NOT NULL), esse valor � retornado; caso contr�rio, ser� NULL.*/

with cte as (
select
	customer_id,
	coupon_code,
	order_date,
	DATETRUNC(month, order_date) as order_month,
	MIN(datetrunc(month, order_date)) over(partition by customer_id) as first_order_month,
	LAST_VALUE(coupon_code) over(partition by customer_id order by order_date rows between unbounded preceding and unbounded following) as last_coupon
from
	orders
),

/*==========================================================================================================================================*/

/*2. cte_two (Filtrando Clientes e Numerando Meses)
A segunda CTE, cte_two, usa os resultados da cte para come�ar a filtrar os dados.

DATEDIFF(month, first_order_month, order_month) + 1 as month_number: Esta linha calcula o n�mero do m�s relativo ao primeiro pedido do cliente. Por exemplo, se o primeiro pedido foi em janeiro e o atual � em mar�o, a diferen�a � de 2 meses, mas o month_number ser� 3.

where last_coupon is not null: Este WHERE � o primeiro filtro importante, eliminando imediatamente todos os clientes cujo �ltimo pedido n�o tinha cupom.*/



cte_two as (
select *,
	DATEDIFF(month, first_order_month, order_month)+1 as month_number

from cte
where last_coupon is not null
),
/*==========================================================================================================================================*/
/*3. cte_three (Contando Pedidos por M�s)
A terceira CTE, cte_three, � onde a l�gica de contagem de pedidos por m�s � aplicada.

sum(case when month_number = 1 then 1 else 0 end) as count_first_month: Esta linha usa uma express�o CASE para contar o n�mero de pedidos feitos no primeiro m�s (quando month_number = 1). A soma s� adiciona 1 se a condi��o for verdadeira.

O mesmo � feito para os meses 2 e 3 (count_second_month e count_third_month).

where month_number in (1,2,3): Este filtro garante que apenas os pedidos dos tr�s primeiros meses consecutivos de cada cliente sejam considerados para a contagem.*/


cte_three as (
select	
	customer_id,
	sum(case when month_number = 1 then 1 else 0 end) as count_first_month,
	sum(case when month_number = 2 then 1 else 0 end) as count_second_month,
	sum(case when month_number = 3 then 1 else 0 end) as count_third_month
from
	cte_two
where month_number in (1,2,3)
group by customer_id
)
/*==========================================================================================================================================*/


/*A Resposta Final
A �ltima parte da consulta seleciona os clientes da cte_three que atendem �s condi��es finais.

where count_second_month = 2*count_first_month: Filtra os clientes onde o n�mero de pedidos no segundo m�s � o dobro do primeiro.

and count_third_month = 3*count_first_month: Filtra os clientes onde o n�mero de pedidos no terceiro m�s � o triplo do primeiro.

A consulta final retorna apenas os customer_id que satisfazem todas as condi��es da pergunta, combinando a contagem de pedidos nos tr�s meses consecutivos e a condi��o do �ltimo pedido ter um cupom.*/

select
	*
from
	cte_three
where count_second_month = 2*count_first_month and count_third_month = 3*count_first_month


