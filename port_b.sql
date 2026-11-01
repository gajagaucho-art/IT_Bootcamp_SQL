
select
count(*) as br_utakmica,
sum(home_goals + away_goals) as br_golova,
round(avg(home_goals + away_goals),2) as prosecan_br_golova,
sum(case when home_goals > away_goals then 1 else 0 end) as pobede_domacina,
sum(case when home_goals < away_goals then 1 else 0 end) as pobede_gostiju,
sum(case when home_goals = away_goals then 1 else 0 end) as neresene
from matches 
where season = '2024/25';
-- br utakmica 380, br golova 1092 , prosek golova 2.87, pobede domacina 157, pobede gostiju 128, neresene 95

select 
month(kickoff_ts) as mesec,
count(match_id) as br_utakmica_po_mesecu,
sum(home_goals + away_goals) as br_golova_po_mesecu,
round(avg(home_goals + away_goals),2)  as prosek_golova_po_mesecu
from matches
where season = '2024/25'
group by mesec
order by  prosek_golova_po_mesecu desc;
--izdvaja se avgust mesec jer je tu najveci prosek golova po mesecu a najmanji broj utakmica

select 
round(avg(m.attendance),2) as prosek_poseta,
round(100 * sum(m.attendance  / s.capacity)/ count(*),2) as  procenat,
sum(case when m.attendance= 0 then 1 else 0 end) as utakmice_bez_publike,
sum(case when m.attendance is null then 1 else 0 end) utakmice_bez_podataka
from matches m join stadiums s on m.stadium_id = s.stadium_id
where season = '2024/25';



with kartoni as (
select 
match_id,
count(*) as cards_in_match
from match_events
where event_type IN ('yellow_card', 'second_yellow', 'red_card')
group by match_id
)
select 
r.referee_name,
count(m.match_id) as total_matches,
coalesce(sum(k.cards_in_match), 0) as total_cards,
round(coalesce(sum(k.cards_in_match), 0) / count(m.match_id), 2) as cards_per_match
from matches m
join referees r on m.referee_id = r.referee_id
left join kartoni k on m.match_id = k.match_id
where m.season = '2024/25'
group by r.referee_id, r.referee_name
order by cards_per_match desc, total_matches desc;

--igraci
select 
p.player_id,
coalesce(p.known_as, p.first_name || ' ' || p.last_name) as ime_igraca,
count(*) as uk_golova
from match_events me join matches m on me.match_id = m.match_id 
join players p on me.player_id = p.player_id
where m.season = '2024/25' and me.event_type in ('goal', 'penalty_goal')
group by p.player_id, p.first_name, p.last_name, p.known_as
order by uk_golova desc
limit 5; 
/*

34  Mattéo O'Brien
32  Leo Marsh
24  José Muñoz
17  Marko Stanković
16  Leo Marsh*/

select 
    p.player_id,
    coalesce(p.known_as, p.first_name || ' ' || p.last_name) as ime,
    count(*) AS uk_asistencija
from match_events me
join matches m on me.match_id = m.match_id
join players p on me.related_player_id = p.player_id
where m.season = '2024/25' 
  and me.event_type = 'goal' 
  and me.related_player_id is not null
group by p.player_id, p.first_name, p.last_name, p.known_as
order by uk_asistencija desc
limit 5;
/* lista najboljih asistenata
Jota	9
Filip Petrović	7
Eirik Solberg	7
Lucas Pereira	7
Kieran Bradley	6
*/
select   
    m.match_id,
    m.matchday,
    m.kickoff_ts,
    t.team_name,
    t.team_id
from matches m
join teams t on t.team_id in (m.home_team_id, m.away_team_id)
left join manager_spells ms on t.team_id = ms.team_id
and date(m.kickoff_ts) >= ms.start_date
and(ms.end_date is null or date(m.kickoff_ts) <= ms.end_date)
where m.season = '2024/25'and ms.spell_id is null;
-- tim Westmere Town nije imao prijavljenog trenera u tabeli 
select 
me.event_id,
me.match_id,
m.matchday,
me.team_id,
me.player_id,
me.event_type,
me.minute
from match_events me
join matches m on me.match_id = m.match_id
left join players p on me.player_id = p.player_id
where m.season = '2024/25' and me.player_id is not null  and p.player_id is null;
-- utakmica nema igraca u tabeli 
