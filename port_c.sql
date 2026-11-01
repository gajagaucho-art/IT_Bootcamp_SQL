with team_goals as (
select 
t.team_name,
sum(case when m.home_team_id = t.team_id then m.home_goals
when  m.away_team_id = t.team_id then m.away_goals
else 0 end) as golovi
from teams t
join matches m on t.team_id in (m.home_team_id, m.away_team_id)
where m.season = '2024/25'
group by t.team_id, t.team_name
)
select 
team_name,
golovi,
sum(golovi) over () as uk_gol_liga,
round(100.0 * golovi / sum(golovi) over (), 2) as gol_procenat
from team_goals
order by gol_procenat desc;

--najveci udeo u golovima ima Kingsbridge City 7.6


with poseta_stadiona as (
select 
s.stadium_name,
s.city,
s.capacity,
avg(m.attendance) as avg_poseta,
dense_rank() over (order by AVG(m.attendance) desc) as rank_num
from matches m join stadiums s on m.stadium_id = s.stadium_id
where m.season = '2024/25'  and m.attendance is not null
group by s.stadium_id, s.stadium_name, s.city, s.capacity
)
select 
rank_num as pozicija,
stadium_name as naziv_stadiona,
city as grad,
capacity as kapacitet,
round(avg_poseta, 2) as prosecna_poseta
from poseta_stadiona
where rank_num <= 3
order by rank_num;

-- tri stadiona sa najvecom proscnom posetom su Harbourside Park,Kingsbridge Stadium,Northport Arena


with poslednji_gol as (
select 
me.team_id,
me.player_id,
m.kickoff_ts,
m.matchday,
me.minute,
coalesce(me.added_time, 0) as dodato_vreme,
row_number() over (partition by me.team_id order by  m.kickoff_ts desc, me.period desc, me.minute desc, coalesce(me.added_time, 0) desc,  me.event_id desc) as rn
from match_events me
join matches m on me.match_id = m.match_id
where m.season = '2024/25' and me.event_type IN ('goal', 'penalty_goal')
)
select 
t.team_name,
pg.matchday,
pg.kickoff_ts,
pg.minute as min_igre
from poslednji_gol pg join teams t on pg.team_id = t.team_id
join players p on pg.player_id = p.player_id
where pg.rn = 1
order by pg.kickoff_ts, pg.minute , pg.dodato_vreme;
-- prvi poslednji gol je dala ekipa  Elmsworth Wanderers u 36 kolu , jer u naredna dva kola nisu dali golove


with utakmice_kuci as (
select 
m.matchday,
m.kickoff_ts,
m.attendance,
lag(m.attendance) over (order by m.kickoff_ts ) as pret_poseta,
m.attendance - LAG(m.attendance) over (order by m.kickoff_ts ) as promena_poseta
from matches m join teams t_home on m.home_team_id = t_home.team_id
join teams t_away on m.away_team_id = t_away.team_id
where m.season = '2024/25' and t_home.team_name = 'Northport United'
)
select 
matchday,
kickoff_ts as datum_i_vreme,
attendance as poseta,
pret_poseta as prethodna_poseta,
promena_poseta as promena_posete
from utakmice_kuci
order by  kickoff_ts;
--najveca promena je bila u 11 kolu tu je zabelezen pad od 10267 posetilaca u odnosu na prethodnu utakmicu


select 
m.matchday as kolo,
date(m.kickoff_ts) as datum,
case when (m.home_team_id = t.team_id and m.home_goals > m.away_goals) or (m.away_team_id = t.team_id and m.away_goals > m.home_goals) then 3
when m.home_goals = m.away_goals then 1 
else 0 end as osvojeno_bodova,
sum(case when (m.home_team_id = t.team_id and m.home_goals > m.away_goals) or (m.away_team_id = t.team_id and m.away_goals > m.home_goals) then 3
when m.home_goals = m.away_goals then 1 else 0 end) over (order by m.kickoff_ts ) as ukupno_bodova
from matches m join teams t on t.team_name = 'Northport City' and (m.home_team_id = t.team_id or m.away_team_id = t.team_id)
where m.season = '2024/25'
order by m.kickoff_ts ;
-- Ekipa  Northport Cityje je u 21. kolu  stigla do 50 bodova 
