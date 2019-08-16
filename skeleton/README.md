SQL Optimizing (with Cats!)
Learning Goals:

    Know how to Create, Update, and Delete a Table using Pure SQL
    How to Measure the Performance of a SQL Query
    How to Increase Performance Using Indices
    Understanding how Indices affect Inserting into Tables
    Measure the Effectiveness of Sub Queries
    Learn to Optimize the Performance of a SQL Query

Phase 1: Setting Up a Table

Let's start off by taking a moment to review the SQL for the Impatient reading. Keep this tab open as a reference throughout the project. For the first phase of this project we'll be setting up our database so we have something to work with. This will be a simpler version of what you did for setting up Postgres so feel free to reference that guide if you need a more in-depth explanation. Accessing this on GitHub? Use this link. First off we'll create a database in Postgres. We'll be using the CLI to do - so we'll start by typing in psql in the terminal. Once in there we can create a shiny new database by running:

~$ psql
<!-- Your Version Might be Newer Than Mine -->
psql (10.4, server 10.5)

rkoron=# CREATE DATABASE meowtime;
CREATE DATABASE
rkoron=# \q

Now we'll want to create some tables in our DB to have some data to work with.

Create a new file called import_db.sql and this will be where we'll set up our tables. We'll start by creating three tables:

    a table for cats
        each cat should have an id, name, color, and a breed
    a table toys
        each toy should have an id, price, color and a name
    a table for cattoys (which will be the connection between cats and toys)
        each cattoy should have an id, a cat_id and a toy_id

If you need tips on how to create a SQL table look here. One thing to watch out for is making sure your primary key increments properly as you are creating new entries in your tables. PostgreSQL has a specific datatype to automatically increment for you.

The table setup you've just made is the perfect example of a Many-to-Many relationship. You have separate cats who many or may not have toys, separate toys who may or may not belong to a cat and then a third table linking them. Many-to-many relationships require a third table, known as an joins or linking table, because relational systems can't directly accommodate the relationship (a toy doesn't just belong to one cat, but could belong to many cats).

Next you'll need some data in each of these tables to practice with. Write 5 INSERT statements for each table (15 total) at the bottom of your import_db.sql file. We call this 'seeding the database'. Whenever we have a foreign key column in a table we want to make sure that the id we provide actually references a record in the corresponding table. So make sure to enforce foreign key constraints in your cattoy table and make sure it is referencing specific cats and toys in your database.

After you've written the SQL, run the SQL commands and create the db - in terminal, run:

cat import_db.sql | psql meowtime

Important:In order to ensure you can reseed (if you need to recreate any tables) you will want to add DROP TABLE statements for each of your tables at the top of your import_db.sql file. This will ensure that your tables are completely destroyed so you won't be attempting to recreate the same table twice each time you run your script.

However, you'll need to make sure you're dropping the tables in the right order. If you drop a table that is dependent upon by a foreign key in another table, you will get an error telling you you've violated the foreign key constraint.

Now go into your meowtime database and try making some basic queries to make sure you seeding worked as intended. Try finding all the cats of a certain color or breed. Then find all toys below a certain price, and finally finding all toys that belong to a certain cat.

Phase 1a: Inserting and Updating your Database Using SQL

Now that you've created your own tables let's try updating and deleting records within that table. Go into psql meowtime and update the color of one of your toys. Then query that toy in the database to make sure the color has changed.

Next try to update a cat, then update a row in cattoys. Finally, update the color of all the toys above a certain price. Make sure to query your database to ensure that your updates all worked as expected. Keep updating rows until you feel comfortable with the syntax.

Nice! So far you've created a table, created rows within that table, and updated the rows you've created.

What if you need to remove a row from a table? First, delete a toy that is not linked to a cat through a cattoy. Second, delete a toy that you know is linked to a cat through a cattoy. You'll see an error like this appear:

meowtime=# DELETE from toys WHERE toys.name = 'Pear';
ERROR:  update or delete on table "toys" violates foreign key constraint "cattoys_toy_id_fkey" on table "cattoys"
DETAIL:  Key (id)=(4045) is still referenced from table "cattoys".

This error is warning you that your cattoys table needs a particular toy (in this case the Pear toy) to exist in order to maintain data integrity. Otherwise you would have a row of cattoys.toy_id pointing to a toy that didn't exist. It is never a good idea to completely remove a foreign key constraint from your tables because you can lose data integrity between tables. However, you can alter your foreign key restraint so that if you deleted a toy it would also delete all references to that toy in other tables. We'll cover this concept more when you learn Rails- but if you are curious how it could be done in PostgreSQL read here.

Make sure you always have a WHERE in your UPDATE and DELETE SQL statements. Otherwise all of your rows will be updated or deleted!

Phase 2: Measuring Performance

By this point you've written many SQL queries. You also know that one query can be written in a variety of different ways and still get the same results (i.e. using subqueries vs. joins) and you may wonder - how can you tell which queries are more efficient than others?

First let's quickly go over what happens when you run a SQL query. There are three different processes that happen every time a SQL query is interpreted:

sql.png

    Query Parser - The query parser makes sure that the query is syntactically correct and semantically correct (i.e. the tables being queried exist), and returns an error if not. If everything is correct, then it turns it into an algebraic expression and passes it to the next step.

    Query Planner & Optimizer - The query planner and optimizer does the hard work. It considers different query plans which may have different optimizations, estimates the cost (CPU and time) of each query plan based on the number of rows in the relevant tables, then it picks the optimal plan and passes it on to the next step.

    Query Executor - The query executor takes the plan and turns it into operations for the database, returning the results back to us if there are any.

Reading the above you've probably guessed that if we want to measure the performance of a SQL query we want to rely on the query planner for information. All SQL languages give us a way to view how the query will be run, or the query plan, ahead of time. In most SQL databases, including Postgres, the word that we can use to view the query plan is EXPLAIN. EXPLAIN which will show the plan generated and chosen by the query planner.

Let's try it out!

We'll start by making simple queries on your database. Prepend the word EXPLAIN to a query to see the cost of the operation.

Examine the query plans for the following queries using explain:

    Find all the cats with a particular name
    Find all the toys that belong to a particular cat
    Find all the toys and cats the are a particular color
    Find all the toys that belong to a particular breed of cat

You should see something like the following:

                      QUERY PLAN
------------------------------------------------------
 Seq Scan on cats  (cost=0.00..202.01 rows=2 width=6)
   Filter: ((name)::text = 'Jet'::text)
(2 rows)

You don't just have to use the keyword EXPLAIN on querying a table either!

Now try using EXPLAIN with:

    updating a cat
    deleting a toy
    inserting into the cattoys table.

Understanding your Query Plan

Each query plan comes with four things:

  1.  starting cost - the start-up time before the first row can be returned.
  2.  total cost - the total cost to return all the rows.
  3.  rows - the number of rows returned.
  4.  width - the width of those rows in bytes.

The cost, while not an exact number of milliseconds, corresponds to how much processing needs to be done to complete the query. The number is useful for determining how one query compares to another, similar to how Big O analysis can give us a sense for how efficient an algorithm is without concerning ourselves with how long an operation would literally take to complete. The rows refers to the number of rows discharged at that point of the plan (This is often less than the number scanned, as a result of filtering by WHERE). The width refers to the estimated average width (in bytes) of the rows output by the step you are on.

While EXPLAIN is a handy tool you may sometimes need to run the query and see the query plan at the same time. To see how long your computer actually took to execute a query, you can use EXPLAIN ANALYZE. EXPLAIN ANALYZE will generate a query plan and run the query showing you the breakdown of the actual number of milliseconds it took to run. Here is a great tool for visualizing the break down of your Query Plan.

Use the visualization tool above comparing both EXPLAIN and EXPLAIN ANALYZE with your previous query to find all the cats with a particular name. We recommend keeping this tool open in a separate tab for the rest of the project for whenever you need a visual breakdown of a query plan.

Aside

Your ANALYZE run times will not always be the same. ANALYZE can be used for benchmarking of a query but the statistics produced by ANALYZE are taken from a randomized sample of the table so they aren't concrete. Expect the measured time to differ slightly between runs. In general EXPLAIN should be what you use for query tuning.

Building Bigger Tables

At this point you know how to create and drop a table in SQL, as well as how to insert, update, and delete rows in a table. Now that you are familiar with the syntax of working in pure SQL, and the structure of tables in Postgres, you are now prepared for the next phase of this project.

When you are working as a developer in the field you'll see databases with thousands, if not millions and millions of rows of data. When you are working with millions of rows an inefficient query can became incredibly slow and costly in terms of processing power. Optimizing a query is one of the easiest, cheapest, and most effective ways to scale your application!

For this next phase of the project we'll emulate an environment where making your queries more efficient will really count. Meaning, you are gonna need a lot more data in your tables. However, instead of making you write out all those insert statements - we'll help you out.

Download and unzip this folder and take a look inside of cat_tables.sql. There are some setup lines which you can read more about here, but you'll see familiar statements lower down in the file. On line 34 you'll see the table creation for each of the three tables you just made. Starting below line 68, there are thousands of seeds that you will use to flesh out your tables with more seed data.

Run the following command to rebuild the three cat tables with the seed data you just viewed.

bundle install
data/import_cat_db.sh

When you had a small amount of data in your tables you probably noticed that your query plans looked pretty similar. Now try to EXPLAIN and EXPLAIN ANALYZE to find a cat that is 'Silver'. The query plan looks very different in terms of cost now right?

Try running the following queries and see how the cost differs from when you had a smaller database:

    Find all of the breeds for the cats named 'Noel'
    Find all the toys that belong to the cat named 'Freyja'
    Find all the toys and cats that are the color 'Red'
    Find all the toys that belong to the cats with the breed of 'British Shorthair'
    Find all the toys with a price of less than 10.

When working with a larger database like this one query tuning,the process of making SQL queries more efficient, becomes especially important. So let's try it out!

Phase 3: To Subquery or Not to Subquery?

One of the most obvious cases where query planning comes into play is when choosing when to use a subquery and when to choose to create a larger table through JOINing. Joins and subqueries are both used to combine data from different tables into a single result.

A subquery is used to run a separate query from within the main query. One common use for a subquery is to calculate a summary value or filter for use in the main query. The downside to this approach is two separate queries will be run. The total cost of this query will also contain the cost of the inner query.

-- Find the names of the cats that are the same color at Freyja
SELECT
  name
FROM
  cats
WHERE
  cats.color = (
    --  Here is a subquery being used as a filter by returning a single result
    SELECT
      cats.color
    FROM
      cats
    WHERE
      name='Freyja'
  );

Contrast this with a join whose main purpose is to combine rows from one or more tables based on a match condition. The downside to this approach is it takes more processing power to create larger tables.

-- This gives us the same answer as the previous query.
SELECT
  c2.name
  -- This builds a large table with duplicated data so we can filter
FROM
  cats AS c1
JOIN
  cats AS c2 ON (c1.color = c2.color)
WHERE
  c1.name = 'Freyja'

Knowing the differences and when to use either a join or subquery to search data from one or more tables is key to mastering SQL.

A good rule of thumb is to think of how large are the tables you need to query and making a decision based on that. If you have a problem that requires you to look through one table twice (like in the example problem above) it probably isn't too costly to subquery. However, let's take the example from the next problem set:

-- This query uses a subquery to find the toys name and price for all the cats with the
-- breed 'British Shorthair'.
SELECT
  toys.name, toys.price
FROM
  toys
WHERE
  toys.id IN (SELECT
                toys.id
              FROM
                toys
              JOIN
                cattoys ON toys.id = cattoys.toy_id
              JOIN
                cats ON cats.id = cattoys.cat_id
              WHERE
                cats.breed = 'British Shorthair')

If your subquery has to create a join to query three seperate tables then that is going to add up! If the cost of your inner query is more that the cost of building a larger table through a JOIN then the JOIN will be always be more efficient.

-- Creating the larger table is more efficient in this scenario!
SELECT
  toys.name, toys.price
FROM
  cats
JOIN
  cattoys ON cats.id = cattoys.cat_id
JOIN
  toys ON toys.id = cattoys.toy_id
WHERE
  cats.breed = 'British Shorthair'

Sometimes Postgres will even internally “rewrite” a subquery, creating a join, but this of course increases the time it takes to come up with the query plan. In terms of query tuning you'll usually discover the cost is reduced using one method or the other so make sure to experiment! Professional query tuning is done by rewriting a query multiple ways and running the numbers to see what is most efficient.

Head over to lib/to_query_problems.rb to get started. When you are ready to run the specs for these problems, you can use the following syntax:

bundle exec rspec spec/to_query_spec.rb

If you'd rather run a single example from the test group, you can run it by appending the line number, like so:

bundle exec rspec spec/to_query_spec.rb:42

To run sample queries open a separate terminal window and enter your database using the psql meowtime command. You can additionally add method calls to the bottom of your lib/ files and then run them.

Phase 4: Indexing

As you've gone over in the readings last night you can create an index within Postgres to optimize certain queries. To view the current indices on any given table by entering the database in psql database and running the command: \d #{tablename}. Running this command will show you a table's columns and any indices that currently on that table.

IMPORTANT: Indexing comes with a cost. Whenever you create an index you slow down all operations for UPDATE, DELETE, and INSERT. This is because the indices also need to be updated every time the table changes. The cost of indexing won't be obvious in a test database of this size, but in a production database with millions of rows the cost of over indexing becomes very apparent. For the sake of scaling, the general rule is to only create indices on columns that will be frequently searched against (foreign keys being the perfect example).

Head over to lib/index_problems.rb for some practice on identifying when an index is needed.
Phase 5: Query Tuning

Now you know how to view a query plan, create indices, and how to optimize your queries. Let's put those skills to the test!

BEFORE STARTING THE NEXT SECTION MAKE SURE TO RESEED!! You'll want to reseed to avoid any of your previous indices effecting the next problem set. You can reseed by running the table creation script again. You can run this script with the command:

data/import_cat_db.sh

Go on over to lib/query_tuning_problems.rb and start building efficient queries. Run the specs and make sure to use the EXPLAIN command to build the most efficient queries you can!
Bonus A:

Pick up where you left off in SQLZoo. Accessing this on GitHub? Use this link. Finish up to Part 9 and if anything doesn't make sense along the way watch the video walkthroughs for both the Julie Andrews and Craiglockhart to Sighthill problems.
Bonus B:

Finish the bonus phases from SQL Zoo (03a, 04a, and 07a)!
Bonus C:

Go through and complete SQL Zoo again. Strong SQL skills are a huge asset to every developer's career. A better understanding of SQL will make you a better developer.