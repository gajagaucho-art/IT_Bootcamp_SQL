
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


select count(*) as br_utakmica,
r.referee_name,

from match_events e join matches m on e.match_id = m.match_id
join referees r on m.referee_id = r.referee_id
where season = '2024/25' and e.event_type in ('yellow_card','red_card')
group by r.referee_name

--igraci

--kvalitet podataka



