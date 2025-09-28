/*Em um torneio de Futebol, alguns dados são registrados. Toda equipe vencedora ganha um ponto e a equipe perdedora perde um ponto. Ao final do torneio, um ranking é dado a todas as equipes com base em seus pontos totais. O total de pontos de uma equipe pode ser negativo.

São fornecidas tabelas: Registro de Partidas e Detalhes da Equipe.

O ranking deve ser calculado de acordo com as seguintes regras:

O total de pontos deve ser classificado do maior para o menor.

Se duas equipes tiverem o mesmo total de pontos, a equipe com o maior número de gols de vitória (gols marcados em partidas vencidas) será classificada mais alto.

Tarefa: escreva a consulta para encontrar os rankings dos times.

*/

with cte as (
select
	winning_team_id,
	1 as points,
	winning_team_goals
from
	matches
union all
select
	lost_team_id,
	-1 as points, 
	0 goals_won
from
	matches
),


cte_two as (
select
	winning_team_id,
	sum(points) total_points,
	sum(winning_team_goals) total_goals
from
	cte
group by winning_team_id
)

select
	*,
	dense_rank() over(order by total_points desc, total_goals desc) team_rank
from
	cte_two
