/* Questão 1 - Escreva uma query trazendo abaixo o quanto temos de usuários para cada segmento e quanto desses usuários
reservaram  voos em abril de 2022 ? */


select
	u.segment, 
	count(distinct u.user_id) as total_users,
	count(distinct case when b.booking_date between '2022-04-01' and '2022-04-30' then u.user_id else null end) as total_apr_users
from
	user_table u
left join booking_table b on u.user_id = b.user_id
group by u.segment


/*Questão 3 - Escreva uma consulta para identificar usuários que fizeram a sua primeira reserva em um hotel e não reserva de voo*/


select 
	*
from
	(
select
	*,
	ROW_NUMBER() over(partition by user_id order by booking_date) as rn
from
	booking_table) a
where rn = 1 and line_of_business = 'Hotel'

/* Questão 4 - Escreva uma consulta para calcular os dias entre o primeiro e a última reserva de cada user_id */


select
	user_id,
	min(booking_date) as primeira_reserva,
	max(booking_date) as última_reserva,
	DATEDIFF(DAY, min(booking_date), max(booking_date)) dias_entre_prim_e_ultm
from
	booking_table 
group by user_id

/*Escreva uma consulta para contar os números de voos e reservas de hotéis de cada user_id no ano de 2022;*/

select
	u.segment,
	sum(case when b.line_of_business='flight' then 1 else 0 end) as no_of_flight_bookings,
	sum(case when b.line_of_business='Hotel' then 1 else 0 end) as no_of_hotel_bookings
from
	user_table u 
inner join booking_table b on u.user_id= b.user_id
group by u.segment


/*Encontre para cada segment, o user que fez a reserva mais recente em 2022 e também retorne quantas reservas este user fez em abril de 2022*/

with cte as (
select
	b.*,
	u.segment,
	ROW_NUMBER() over(partition by u.segment order by b.booking_date, b.booking_date) as rn,
	count(*) over(partition by u.segment, u.user_id) as count_of_bookings
from
	user_table u
left join booking_table b on u.user_id = b.user_id
where b.booking_date between '2022-04-01' and '2022-04-30'
)

select 
	*
from
	cte
where rn = 1