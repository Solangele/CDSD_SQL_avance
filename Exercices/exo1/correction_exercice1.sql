
-- 1. Catalogue public des morceaux

CREATE OR REPLACE VIEW v_tracks_public AS
SELECT
    t.track_id,
    t.title,
    t.duration_s,
    a.name AS artist_name
FROM tracks AS t
JOIN artists AS a
    ON a.artist_id = t.artist_id;

-- utilisation
SELECT *
FROM v_tracks_public
ORDER BY artist_name, title;

-- 2. Utilisateurs Premium français

CREATE OR REPLACE VIEW v_premium_fr_users AS
SELECT
    user_id,
    username,
    country,
    subscription
FROM users
WHERE subscription = 'Premium'
  AND country = 'France';

-- utilisation
SELECT *
FROM v_premium_fr_users
ORDER BY username;

-- 3. Historique détaillé des écoutes
CREATE OR REPLACE VIEW v_listenings_detailed AS
SELECT
    l.listening_id,
    u.user_id,
    u.username,
    u.country,
    t.track_id,
    t.title,
    a.artist_id,
    a.name AS artist_name,
    l.listened_at,
    l.seconds_played
FROM listenings AS l
JOIN users     AS u ON u.user_id   = l.user_id
JOIN tracks    AS t ON t.track_id  = l.track_id
JOIN artists   AS a ON a.artist_id = t.artist_id;

-- utilisation
SELECT *
FROM v_listenings_detailed
WHERE country = 'France'
ORDER BY listened_at;

-- 4. Statistiques d’écoute par artiste

CREATE OR REPLACE MATERIALIZED VIEW v_artist_listening_stats AS
SELECT
    artist_id,
    artist_name,
    COUNT(*)                    AS total_listenings,
    SUM(seconds_played)         AS total_seconds,
    ROUND(AVG(seconds_played), 1) AS avg_seconds_per_listening
FROM v_listenings_detailed
GROUP BY artist_id, artist_name;

-- utilisation
SELECT *
FROM v_artist_listening_stats
WHERE total_listenings >= 3
ORDER BY total_seconds DESC;

-- 5. Analyse par pays d’artiste
SELECT
    a.country                        AS artist_country,
    SUM(v.total_seconds)             AS sum_seconds,
    COUNT(*)                         AS nb_artists
FROM v_artist_listening_stats AS v
JOIN artists AS a
    ON a.artist_id = v.artist_id
GROUP BY a.country
ORDER BY sum_seconds DESC;

-- 6. Optimisation et index
-- CREATE INDEX IF NOT EXISTS [nom de la contrainte]
-- ON [nom de la table](columnA,columnB)