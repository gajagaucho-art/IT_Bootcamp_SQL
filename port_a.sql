-- Deo A
--1 Колико утакмица је одиграно у фебруару 2025?
select 
kickoff_ts,
match_id,*
from matches 
where kickoff_ts >= '2025-02-01' and kickoff_ts < '2025-03-01';
-- U Februaru 2025. je odigrano 40 utakmica.

--2 Који стадион има највећи капацитет, а који је највећи стадион неког клуба?
Select  
s.stadium_name, t.team_name,s.capacity
from stadiums s join teams t on s.stadium_id = t.stadium_id
order by capacity desc;
--Najveci stadion je National Stadium, a najveci stadion ima Northport United

--3 Колико играча у лиги има српско држављанство (nationality = 'Serbia')?
select
count(*)
from players where nationality = 'Serbia';
-- Ukupno 42 igraca ima imaju srpsko drzavljanstvo

--4 Колико утакмица је завршено резултатом 1:1?

select 
count(*),
home_goals, away_goals
from matches
where home_goals = 1 and  away_goals = 1
group by home_goals, away_goals;
-- Ukupno 94 utakmica je zavrseno rezultatom 1 : 1

--5 Колика је просечна посета по сезони?
select 
season,
round(avg(attendance),2) as avg_att
from matches
group by season;
--Za sezonu 2023/24 prosecna poseta je 24252.95, a za sezonu 2024/25 je prosek poseta 24199.49

--6 Колико голова је дато из пенала по сезони?
select  
m.season,
count(*)
from match_events e join matches m on e.match_id = m.match_id
where  e.event_type = 'penalty_goal'
group by m.season;
-- u sezoni 2023/24 je dato 104 gola iz penala, u sezoni  2024/25 je dato 109

--7 Колико различитих играча је дало бар један гол у сезони 2024/25?
select 
distinct p.player_id,
m.season
from match_events e join players p on e.player_id = p.player_id 
join matches m on e.match_id = m.match_id
where e.event_type in ('goal', 'penalty_goal')
and m.season = '2024/25';
-- Ukupno 308 razlicitih igraca je dalo barem jedan gol , bilo iz igre ili sa penala

--8 Који судија је највише пута судио утакмице клуба Northport United?

select 
count(*) as br_utakmica,r.referee_name
from matches m join referees r on m.referee_id = r.referee_id
join teams t on m.home_team_id = t.team_id or m.away_team_id = t.team_id
where t.team_name = 'Northport United'
group by r.referee_name
order by br_utakmica desc limit 2;
-- najvise puta utakmice kluba Northport United je sudio  Peter Lindgren, ukupno 9 puta za obe sezone

--9 Који судија је у сезони 2024/25 имао највећи удео утакмица у којима је досуђен бар једанпенал, дат или промашен?

select 
count(*) as br_dosudjenih_penala,
r.referee_name
from matches m join referees r on m.referee_id = r.referee_id
join match_events e on m.match_id = e.match_id
where e.event_type in ('penalty_miss', 'penalty_goal') and m.season = '2024/25'
group by r.referee_name
order by br_dosudjenih_penala desc;
-- najvise penala je dosudio  Peter Lindgren , ukupno 14

--10 Који тренер је освојио највише бодова у утакмицама у којима је његов тим губио наполувремену? Рачунајте и домаће и гостујуће утакмице.
select 
m.match_id,
m.home_team_id as team_id,
m.home_goals_ht as gol_polu_domacin,
m.away_goals_ht  as gol_gost_poluvreme
,m.home_goals as gol_dom,
m.away_goals as gol_gost
from matches m
union all
select 
m.match_id,
m.home_team_id as team_id,
m.home_goals_ht as gol_polu_domacin,
m.away_goals_ht  as gol_gost_poluvreme
,m.home_goals as gol_dom,
m.away_goals as gol_gost
from matches m

