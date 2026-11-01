create or replace table dim_team as
select 
    team_id, 
    team_name, 
    short_name, 
    city, 
    founded_year, 
    stadium_id
from teams;

--
create or replace table dim_referee as
select 
    referee_id, 
    referee_name, 
    nationality, 
    debut_season
from referees;

--

create or replace table dim_player (
    player_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    known_as VARCHAR(100),
    birth_date DATE,
    nationality VARCHAR(100),
    position VARCHAR(50),
    preferred_foot VARCHAR(20),
    height_cm INT
);

--

insert into  dim_player (player_id, first_name, last_name, known_as, birth_date, nationality, position, preferred_foot, height_cm)
values (-1, 'Nepoznato', 'Nepoznato', 'Nepoznato', null, 'Nepoznato', 'Nepoznato', 'Nepoznato', null);

insert into dim_player
select 
    player_id, 
    first_name, 
    last_name, 
    known_as, 
    birth_date, 
    nationality, 
    position, 
    preferred_foot, 
    height_cm
from players;

create or replace table dim_date as
select  cast(DATE_FORMAT(d, 'yyyyMMdd') as int) as date_key,
       d                                       as full_date,
       DATE_FORMAT(d, 'EEEE')                  as weekday_name,
       DAYOFWEEK(d) IN (1, 7)                  as is_weekend,
       case when MONTH(d) >= 7 then CONCAT(YEAR(d), '/', SUBSTRING(CAST(YEAR(d) + 1 as string), 3, 2))
            ELSE CONCAT(YEAR(d) - 1, '/', SUBSTRING(CAST(YEAR(d) as string), 3, 2))
       end                                     as season
from (select  EXPLODE(SEQUENCE(DATE'2023-07-01', DATE'2025-06-30', interval 1 day)) as d); 



create or replace table fact_card AS
select 
me.event_id,
me.match_id,
date(m.kickoff_ts) as date_key,
me.team_id,
case when p.player_id is not null then me.player_id else -1 end as player_id,
m.referee_id,
me.event_type as card_type
from match_events me
join matches m on me.match_id = m.match_id
left join players p on me.player_id = p.player_id
where me.event_type in ('yellow_card', 'second_yellow', 'red_card');


-- upiti potvrde da ima isti broj redova za vrstu dogadjaja 'yellow_card', 'second_yellow', 'red_card'

select count(*) from fact_card
union all
select count(*) from match_events 
where event_type in ('yellow_card', 'second_yellow', 'red_card');

