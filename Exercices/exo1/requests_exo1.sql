-- 1
CREATE OR REPLACE VIEW sql_avance1.v_public_piece AS
SELECT title, duration_s, name 
	FROM sql_avance1.tracks
	INNER JOIN sql_avance1.artists ON tracks.artist_id = artists.artist_id;

SELECT * FROM sql_avance1.v_public_piece
ORDER BY title;

-- 2
CREATE OR REPLACE VIEW sql_avance1.v_subscription_by_France AS
SELECT * FROM sql_avance1.users
WHERE subscription = 'Premium' AND country = 'France';

SELECT * FROM sql_avance1.v_subscription_by_France
ORDER BY username;

-- 3
CREATE OR REPLACE VIEW sql_avance1.v_listen_info AS
SELECT users.user_id, 
	   users.username, 
	   users.country, 
	   tracks.title, 
	   artists.name, 
	   listenings.listened_at,
	   listenings.seconds_played
FROM sql_avance1.users
INNER JOIN sql_avance1.listenings ON users.user_id = listenings.user_id
INNER JOIN sql_avance1.tracks ON listenings.track_id = tracks.track_id
INNER JOIN sql_avance1.artists ON tracks.artist_id = artists.artist_id;

SELECT * FROM sql_avance1.v_listen_info
WHERE country = 'France';

-- 4
CREATE MATERIALIZED VIEW sql_avance1.mv_listen_detailed2 AS
SELECT artists.name, 
	   artists.country,
	   COUNT(listened_at) AS nb_ecoute, 
	   SUM(seconds_played) AS nb_total_seconde_ecoute,
	   ROUND(AVG(seconds_played)) AS moyenne_ecoute
FROM sql_avance1.artists
INNER JOIN sql_avance1.tracks ON artists.artist_id = tracks.artist_id 
INNER JOIN sql_avance1.listenings ON tracks.track_id = listenings.track_id
GROUP BY artists.name, artists.country;

SELECT * FROM sql_avance1.mv_listen_detailed
ORDER BY nb_total_seconde_ecoute DESC;

SELECT * FROM sql_avance1.mv_listen_detailed
ORDER BY nb_ecoute DESC;

SELECT * FROM sql_avance1.mv_listen_detailed
ORDER BY moyenne_ecoute DESC;


-- 5
SELECT country, 
	   COUNT(name) AS nb_artistes, 
	   SUM(nb_ecoute) AS volume_ecoute_total
FROM sql_avance1.mv_listen_detailed2
GROUP BY country;


--6
CREATE INDEX idx_total_seconds
	ON sql_avance1.mv_listen_detailed2 (nb_total_seconde_ecoute);

CREATE INDEX idx_moyenne_ecoute
	ON sql_avance1.mv_listen_detailed2 (moyenne_ecoute);