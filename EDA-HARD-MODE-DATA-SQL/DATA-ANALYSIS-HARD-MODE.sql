

/*Desafio: Escreva uma query para exibir o número total de hackers únicos que fizeram pelo menos 1 submissão em cada dia (a partir do primeiro dia do concurso) e encontre o hacker_id e o nome do hacker que realizou o maior número de submissões em cada dia.

Se mais de um hacker tiver o mesmo número máximo de submissões, exiba o hacker com o menor hacker_id.

A query deve mostrar essas informações para cada dia do concurso, ordenadas pela data.*/


select  * from submissions


with cte as (
select
	submission_date,
	hacker_id,
	count(*) as no_of_submissions,
	DENSE_RANK() over(order by submission_date) as day_number
from submissions
group by submission_date, hacker_id
),


cte_two as (
select
	*,
	/*conta cumulativamente em quantos dias distintos ele já apareceu até aquela data.*/
	count(*) over(partition by hacker_id order by submission_date) as till_date_submissions, 
	case when day_number = count(*) over(partition by hacker_id order by submission_date) then 1 else 0 end as unique_flag
from
	cte
),

cte_three as (

select
	*,
	/*soma, por data, quantos têm unique_flag = 1 → quantos hackers mantiveram a sequência perfeita até aquele dia.*/
	sum(unique_flag) over(partition by submission_date) as unique_count,
	ROW_NUMBER() over(partition by submission_date order by no_of_submissions desc, hacker_id) as rn
from
	cte_two
)


select
	submission_date, 
	unique_count,
	hacker_id
from
	cte_three
where rn = 1
order by submission_date


/* Campeão por dia (maior no_of_submissions, desempate pelo menor id):
2016-03-01: todos com 1 submissão → menor id = 20703.
2016-03-02: 79722 tem 2 submissões; os demais 1 → 79722.
2016-03-03: todos com 1 → menor id = 20703.
2016-03-04: todos com 1 → menor id = 20703.
2016-03-05: 36396 tem 2 submissões; demais 1 → 36396.
2016-03-06: só 20703 → 20703.*/

/*submission_date | unique_count | hacker_id
--------------- | ------------ | ---------
2016-03-01      | 4            | 20703
2016-03-02      | 2            | 79722
2016-03-03      | 2            | 20703
2016-03-04      | 2            | 20703
2016-03-05      | 1            | 36396
2016-03-06      | 1            | 20703



Dia 1: 4 hackers enviaram. Todos fizeram apenas 1 submissão. Empate → vence o de menor hacker_id → 20703.

Dia 2: apenas 2 hackers mantiveram submissões desde o dia 1 (streakers), mas o campeão do dia é quem fez mais envios no dia 2. O 79722 fez 2 envios, os outros só 1 → 79722 vence.

Dia 6: só 1 hacker manteve submissões desde o primeiro dia (20703). E como ele também foi o único que enviou nesse dia, ele vence automaticamente.

Resumindo a lógica:

unique_count = quantos hackers não perderam nenhum dia desde o dia 1 até aquele dia.

hacker_id campeão = quem fez mais submissões naquele dia (desempate pelo menor id).
*/


