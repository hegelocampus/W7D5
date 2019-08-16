DROP TABLE cattoys;
DROP TABLE cats;
DROP TABLE toys;

CREATE TABLE cats (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  color VARCHAR(100) NOT NULL,
  breed VARCHAR(100) NOT NULL
);

CREATE TABLE toys(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INTEGER NOT NULL,
    color VARCHAR(100) NOT NULL
);

CREATE TABLE cattoys(
    id SERIAL PRIMARY KEY,
    cat_id INTEGER NOT NULL,
    toy_id INTEGER NOT NULL,

  FOREIGN KEY (cat_id) REFERENCES cats(id),
  FOREIGN KEY (toy_id) REFERENCES toys(id)
);

INSERT INTO
  cats (name, color, breed)
VALUES
  ('Norman', 'multi', 'calico');
INSERT INTO
  cats (name, color, breed)
VALUES
  ('Loretta', 'Orange', 'Tabby');
INSERT INTO
  cats (name, color, breed)
VALUES
  ('Carlos', 'Grey', 'Maine Coon');
INSERT INTO
  cats (name, color, breed)
VALUES
  ('Star', 'Tan', 'Brazilian Shorthair');
INSERT INTO
  cats (name, color, breed)
VALUES
  ('Fern', 'multi', 'calico');

INSERT INTO
  toys (name, price, color)
VALUES
  ('mouse', 50000, 'blue'); 

INSERT INTO 
  toys (name, price, color)
VALUES 
  ('bird thing', 2, 'white');

INSERT INTO 
  toys (name, price, color)
VALUES 
  ('yo-yo', 4, 'black'); 

INSERT INTO 
  toys (name, price, color)
VALUES 
  ('bowl', 2, 'brown');
  
INSERT INTO 
  toys (name, price, color)
VALUES 
  ('feather', 3, 'orange');




INSERT INTO
  cattoys
  (cat_id, toy_id)
VALUES
  (1, 1), (2, 2), (3, 3), (4, 4), (5, 5);

/*
INSERT INTO
  cattoys
  (toy_id)
VALUES
  (
    SELECT id
    FROM toys
    WHERE name = 'bowl');


INSERT INTO
  cattoys
  (cat_id, toy_id)
VALUES
  ((SELECT id
    FROM cats
    WHERE name IN ('Loretta', 'Norman')),
    (SELECT id
    FROM toys
    WHERE name = 'feather'));
    

INSERT INTO
  cattoys
  (cat_id, toy_id)
VALUES
  ( 
    SELECT id
    FROM toys
    WHERE name = 'bird thing');


INSERT INTO
  cattoys
  (cat_id, toy_id)
VALUES
  ((SELECT id
    FROM cats
    WHERE name = 'Fern'),
    (SELECT id
    FROM toys
    WHERE name = 'yo-yo'));
*/  


--   COPY toys (name, price, color) FROM stdin;
--   yo-yo 4 black 
--   bowl 2 white 
--   feather 3 orange 
--   \.
  



-- UPDATE
--   users
-- SET
--   name = 'Eddard Stark', house = 'Winterfell'
-- WHERE
--   name = 'Ned Stark';