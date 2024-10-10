DROP TABLE IF EXISTS open_paris CASCADE;
DROP TABLE IF EXISTS access_l CASCADE;
DROP TABLE IF EXISTS tag_asso CASCADE;
DROP TABLE IF EXISTS tag_list CASCADE;
DROP TABLE IF EXISTS body CASCADE;
DROP TABLE IF EXISTS groupe_list CASCADE;
DROP TABLE IF EXISTS contact CASCADE;
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS occurence CASCADE;
DROP TABLE IF EXISTS cover CASCADE;
DROP TABLE IF EXISTS info CASCADE;

CREATE TABLE open_paris (
    id INT,
    url TEXT,
    titre TEXT,
    lead_text TEXT,
    description TEXT,
    date_start TIMESTAMPTZ,
    date_end TIMESTAMPTZ,
    occurrences TEXT,
    date_description TEXT,
    cover_url TEXT,
    cover_alt TEXT,
    cover_credit TEXT,
    tags TEXT,
    address_name TEXT,
    address_street TEXT,
    address_zipcode TEXT,
    adress_city TEXT,
    lat_lon TEXT,
    pmr TEXT,
    blind TEXT,
    deaf TEXT,
    transport TEXT,
    contact_url TEXT,
    contact_phone TEXT,
    contact_email TEXT,
    contact_facebook TEXT,
    contact_twitter TEXT,
    price_type TEXT,
    price_detail TEXT,
    access_type TEXT,
    access_link TEXT,
    access_link_text TEXT,
    updated_at TEXT,
    image_couverture TEXT,
    programs TEXT,
    address_url TEXT,
    address_url_text TEXT,
    address_text TEXT,
    title_event TEXT,
    audience TEXT,
    childrens TEXT,
    groupe TEXT
);

CREATE TABLE info (
    id INT PRIMARY KEY,
    pmr boolean,
    blind boolean,
    deaf boolean,
    price_type TEXT,
    access_type TEXT
--- check les valeur de price_type et access_type
);

CREATE TABLE cover (
    cover_url TEXT PRIMARY KEY,
    cover_alt TEXT,
    cover_credit TEXT
);
 
CREATE TABLE occurence(
    id INT,
    occ_d TIMESTAMPTZ,
    occ_f TIMESTAMPTZ,
    PRIMARY KEY(id, occ_d),
	FOREIGN KEY(id) REFERENCES info(id) ON DELETE CASCADE ON UPDATE CASCADE
);
   
CREATE TABLE address (
    address_name TEXT PRIMARY KEY,
    address_street TEXT,
    address_zipcode TEXT,
    adress_city TEXT,
    lat_lon TEXT,
    transport TEXT
);


CREATE TABLE contact (
    contact_url TEXT default 'aucun',
    contact_phone TEXT default 'aucun',
    contact_email TEXT default 'aucun',
    contact_facebook TEXT,
    contact_twitter TEXT,
    PRIMARY KEY(contact_url, contact_phone, contact_email)
);

CREATE TABLE groupe_list (
    groupe TEXT PRIMARY KEY
);

CREATE TABLE access_l (
    access_link TEXT PRIMARY KEY,
    access_link_text TEXT
);

CREATE TABLE body (
    id INT PRIMARY KEY,
    title TEXT,
    cover_url TEXT,
    lead_text TEXT,
    description TEXT,
    date_description TEXT,
    address_name TEXT,
    contact_url TEXT,
    contact_phone TEXT,
    contact_email TEXT,
    price_detail TEXT,
    access_link TEXT,        
    updated_at TIMESTAMPTZ,
    programs TEXT,
    address_url TEXT,
    address_text TEXT,
    title_event TEXT,
    people TEXT,    --ajouter un check
    age_min INT,
    age_max INT,
    childrens TEXT,
    groupe TEXT,
	FOREIGN KEY(id) REFERENCES info(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(address_name) REFERENCES address(address_name) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(contact_url, contact_phone, contact_email) REFERENCES contact(contact_url, contact_phone, contact_email) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(groupe) REFERENCES groupe_list(groupe) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(access_link) REFERENCES access_l(access_link) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(cover_url) REFERENCES cover(cover_url) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE tag_list (
    tag TEXT PRIMARY KEY
);

CREATE TABLE tag_asso (
    id INT,
    tag TEXT,
    PRIMARY KEY(id, tag),
	FOREIGN KEY(id) REFERENCES info(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(tag) REFERENCES tag_list(tag) ON DELETE CASCADE ON UPDATE CASCADE
);



\copy open_paris from './que-faire-a-paris-.csv' with (header, format csv, delimiter ';');


UPDATE open_paris
SET contact_url = 'Aucun'
WHERE contact_url is null;

UPDATE open_paris
SET contact_phone = 'Aucun'
WHERE contact_phone is null;

UPDATE open_paris
SET contact_email = 'Aucun'
WHERE contact_email is null;

INSERT INTO info (id, pmr, blind, deaf, price_type, access_type)
SELECT id, Cast(pmr as boolean), Cast(blind as boolean), Cast(deaf as boolean), price_type, access_type
FROM open_paris;

INSERT INTO cover(cover_url, cover_alt, cover_credit)
SELECT distinct(cover_url), cover_alt, cover_credit
FROM open_paris
where cover_url is not null;

UPDATE open_paris
SET date_start = '2024-04-22T20:00:00+02:00'
WHERE id = 49078;

INSERT INTO occurence(id, occ_d, occ_f)
SELECT id, Cast(date_start as TIMESTAMP), Cast(date_end as TIMESTAMP)
FROM open_paris
WHERE occurrences is null and date_start is not null;

With tuple_date as
(
Select id, string_to_array(unnest(string_to_array(occurrences, ';')), '_') as tuple
FROM open_paris
WHERE occurrences is not null
)
INSERT INTO occurence(id, occ_d, occ_f)
SELECT DISTINCT ON (id, tuple[1]) id, Cast(tuple[1] as TIMESTAMP), Cast(tuple[2] as TIMESTAMP)
FROM tuple_date;

INSERT INTO address(address_name, address_street, address_zipcode, adress_city, lat_lon, transport)
SELECT distinct(address_name), max(address_street), max(address_zipcode), max(adress_city), max(lat_lon), max(transport)
FROM open_paris
where address_name is not null
group by address_name;


INSERT INTO contact(contact_url, contact_phone, contact_email, contact_facebook, contact_twitter)
SELECT contact_url, contact_phone, contact_email, max(contact_facebook), max(contact_twitter)
FROM open_paris
Group by contact_url, contact_phone, contact_email;

INSERT INTO tag_list(tag)
SELECT distinct unnest(string_to_array(tags, ','))
FROM open_paris;

INSERT INTO tag_asso(id, tag)
SELECT id, unnest(string_to_array(tags, ','))
FROM open_paris;

INSERT INTO groupe_list(groupe)
SELECT groupe
FROM open_paris
Group by groupe;

INSERT INTO access_l(access_link, access_link_text)
SELECT access_link, max(access_link_text)
FROM open_paris
Where access_link is not null
Group by access_link;
-------------------------------------------------------------------------------------------------------
With audi1 as(
Select id, SPLIT_PART(audience, '.', 1) as ppl,
    Cast(SUBSTRING((regexp_matches(audience, 'de \d+', 'g'))[1],4) as INT) AS age_min,
    Cast(SUBSTRING((regexp_matches(audience, 'à \d+', 'g'))[1],3) as INT) AS age_max
From open_paris
),
audi2 as(
Select id, SPLIT_PART(audience, '.', 1) as ppl,
    Cast(SUBSTRING((regexp_matches(audience, 'de \d+', 'g'))[1],4) as INT) AS age_min
From open_paris
),
audi3 as(
Select id, SPLIT_PART(audience, '.', 1) as ppl,
    Cast(SUBSTRING((regexp_matches(audience, 'à \d+', 'g'))[1],3) as INT) AS age_max
From open_paris
),
audi4 as(
Select id, audience as ppl
From open_paris
where id not in (Select id from audi1 union Select id from audi2 union Select id from audi3)
)
SELECT count(open_paris.id)
FROM open_paris join audi1 on (open_paris.id=audi1.id)
UNION
SELECT count(open_paris.id)
FROM open_paris join audi2 on (open_paris.id=audi2.id)
UNION
SELECT count(open_paris.id)
FROM open_paris join audi3 on (open_paris.id=audi3.id)
UNION
SELECT count(open_paris.id)
FROM open_paris join audi4 on (open_paris.id=audi4.id);
--------------------------------------------------------------------------------------------------------
With audi as(
Select id, SPLIT_PART(audience, '.', 1) as ppl,
    Cast(SUBSTRING((regexp_matches(audience, 'de \d+', 'g'))[1],4) as INT) AS age_min,
    Cast(SUBSTRING((regexp_matches(audience, 'à \d+', 'g'))[1],3) as INT) AS age_max
From open_paris
)
INSERT INTO body (id, title, cover_url, lead_text, description, date_description, address_name, contact_url, contact_phone, contact_email, price_detail, access_link, updated_at, programs, address_url, address_text, title_event, people, age_min, age_max, childrens, groupe)
SELECT open_paris.id, Titre, cover_url, lead_text, description, date_description, address_name, contact_url, contact_phone, contact_email, price_detail, access_link, Cast(updated_at as TIMESTAMP), programs, address_url, address_text, title_event, ppl, age_min, age_max, childrens, groupe
FROM open_paris join audi on (open_paris.id=audi.id);

