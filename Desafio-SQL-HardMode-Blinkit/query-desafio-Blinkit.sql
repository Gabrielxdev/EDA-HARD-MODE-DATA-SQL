/*Condições para Clientes Qualificados
Para que um cliente seja considerado "novo" e qualificado, ele deve cumprir todas as seguintes regras:

Padrão de Pedidos: Fazer pedidos em cada um dos seus primeiros 3 meses consecutivos desde a data do primeiro pedido.

Crescimento no Mês 2: O número de pedidos no segundo mês deve ser exatamente o dobro dos pedidos do primeiro mês.

Crescimento no Mês 3: O número de pedidos no terceiro mês deve ser exatamente o triplo dos pedidos do primeiro mês.

Último Pedido com Cupom: O pedido mais recente do cliente deve ter sido feito com um cupom (cupom_code não pode ser nulo).*/


/*==========================================================================================================================================*/


/*1. cte (Tabela de Informações Agregadas)
A primeira CTE, cte, é a base de tudo. Ela pega todos os pedidos e adiciona informações essenciais usando funções de janela.

DATETRUNC(month, order_date) as order_month: Essa função trunca a data do pedido para o primeiro dia do mês, o que é útil para agrupar os pedidos por mês.

MIN(datetrunc(month, order_date)) over(partition by customer_id) as first_order_month: Esta função de janela encontra o mês do primeiro pedido de cada cliente. A palavra-chave partition by customer_id garante que a data do primeiro pedido seja calculada separadamente para cada cliente.

LAST_VALUE(coupon_code) over(partition by customer_id order by order_date rows between unbounded preceding and unbounded following) as last_coupon: Esta é a parte mais complexa da primeira CTE. Ela encontra o valor do coupon_code do último pedido de cada cliente.

partition by customer_id novamente divide os dados por cliente.

order by order_date garante que a ordem dos pedidos seja cronológica.

rows between unbounded preceding and unbounded following é crucial, pois informa ao SQL para examinar todas as linhas de um cliente para encontrar o último valor. Se a última linha tiver um cupom (IS NOT NULL), esse valor é retornado; caso contrário, será NULL.*/

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
A segunda CTE, cte_two, usa os resultados da cte para começar a filtrar os dados.

DATEDIFF(month, first_order_month, order_month) + 1 as month_number: Esta linha calcula o número do mês relativo ao primeiro pedido do cliente. Por exemplo, se o primeiro pedido foi em janeiro e o atual é em março, a diferença é de 2 meses, mas o month_number será 3.

where last_coupon is not null: Este WHERE é o primeiro filtro importante, eliminando imediatamente todos os clientes cujo último pedido não tinha cupom.*/



cte_two as (
select *,
	DATEDIFF(month, first_order_month, order_month)+1 as month_number

from cte
where last_coupon is not null
),
/*==========================================================================================================================================*/
/*3. cte_three (Contando Pedidos por Mês)
A terceira CTE, cte_three, é onde a lógica de contagem de pedidos por mês é aplicada.

sum(case when month_number = 1 then 1 else 0 end) as count_first_month: Esta linha usa uma expressão CASE para contar o número de pedidos feitos no primeiro mês (quando month_number = 1). A soma só adiciona 1 se a condição for verdadeira.

O mesmo é feito para os meses 2 e 3 (count_second_month e count_third_month).

where month_number in (1,2,3): Este filtro garante que apenas os pedidos dos três primeiros meses consecutivos de cada cliente sejam considerados para a contagem.*/


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
A última parte da consulta seleciona os clientes da cte_three que atendem às condições finais.

where count_second_month = 2*count_first_month: Filtra os clientes onde o número de pedidos no segundo mês é o dobro do primeiro.

and count_third_month = 3*count_first_month: Filtra os clientes onde o número de pedidos no terceiro mês é o triplo do primeiro.

A consulta final retorna apenas os customer_id que satisfazem todas as condições da pergunta, combinando a contagem de pedidos nos três meses consecutivos e a condição do último pedido ter um cupom.*/

select
	*
from
	cte_three
where count_second_month = 2*count_first_month and count_third_month = 3*count_first_month


