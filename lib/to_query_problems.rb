# == Schema Information
#
# Table name: cats
#
#  id          :integer      not null, primary key
#  name        :string
#  color       :string
#  breed       :string
#
# Table name: toys
#
#  id          :integer      not null, primary key
#  name        :string
#  color       :string
#  price       :integer
#
# Table name: cattoys
#
#  id          :integer      not null, primary key
#  cat_id      :integer      not null, foriegn key
#  toy_id      :integer      not null, foreign key

require_relative '../data/query_tuning_setup.rb'

# For this part of the project you'll be be asking yourself:
# TO QUERY OR NOT TO QUERY? 

# For that is the question!
# For each of the following problems you will try to write each
# problem WITH and WITHOUT subqueries, testing the efficiency
# of each query as you go. 

def frey_example
  # Find all the cats that are the same color as the cat named 'Freyja'.
  # Including 'Freyja' in the results.
  # DO NOT USE A SUBQUERY

  execute(<<-SQL)
    SELECT
      color_cats.name
    FROM
      cats AS freyja_cats
    JOIN
      cats AS color_cats ON freyja_cats.color = color_cats.color
    WHERE
      freyja_cats.name = 'Freyja';
  SQL
end

def frey_example_sub
  # Find all the cats that are the same color as the cat named 'Freyja'.
  # Including 'Freyja' in the results.

  # Using Explain you can see these queries are very similiar! Since our 
  # subquery is only performed on one table it is more efficient to use a subquery 
  # in this scenario instead of building the larger table.
  execute(<<-SQL)
    SELECT
      cats.name
    FROM
      cats
    WHERE
      cats.color = (
                    SELECT  
                      cats.color
                    FROM
                      cats
                    WHERE
                      name = 'Freyja'
                    );
  SQL
end

def harder_example
  # Find the toys and price for all the cats with the 
  # breed 'British Shorthair'.
  # Order alphabetically by toys name. 
  # DO NOT USE A SUBQUERY

  # Whereas in this query it is more efficient to not perform a subquery 
  # because we don't have to do the extra cost of a large subquery.
  execute(<<-SQL)
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
    ORDER BY
      toys.name ASC;
  SQL
end

def harder_example_sub
  # Find the toys and price for all the cats with the 
  # breed 'British Shorthair'.
  # Order alphabetically by toys name. 

  # USE A SUBQUERY
  execute(<<-SQL)
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
    ORDER BY
      toys.name ASC;
  SQL
end


def no_apples_for_blair
  # Blair has was too many apple toys! Find the name of all the cats that
  # own toys named `Apple` that aren't `Blair`. 
  # Order by cat name alphabetically.

  # DO NOT USE A SUBQUERY
  execute(<<-SQL)
    SELECT cats.name
    FROM cats
    JOIN cattoys ON cats.id = cattoys.cat_id
    JOIN toys ON cattoys.toy_id = toys.id
    WHERE cats.name != 'Blair' AND toys.name = 'Apple'
    ORDER BY cats.name ASC
    

  SQL
end


def no_apples_for_blair_sub
  # Blair has was too many apple toys! Find the name of all the cats that
  # own toys named `Apple` that aren't `Blair`. 
  # Order by cat name alphabetically.

  # USE A SUBQUERY
  execute(<<-SQL)
    
    SELECT a.cat_name
  
    FROM (
      SELECT cats.name AS cat_name, t.name AS toy_name
      FROM cats
      JOIN cattoys AS c ON cats.id = c.cat_id
      JOIN toys AS t ON c.toy_id = t.id
      WHERE cats.name != 'Blair') AS a -- return cats named not Blair
    
    WHERE a.toy_name = 'Apple'
    ORDER BY a.cat_name ASC 
    LIMIT 10

  SQL
end


def toys_that_brendon_owns
  # List the all the toy names for all the cats named 'Brendon'.
  # Order alphabetically by toy name. 

  # DO NOT USE A SUBQUERY
  execute(<<-SQL)
    SELECT toys.name
    FROM cats
    JOIN cattoys ON cats.id = cattoys.cat_id
    JOIN toys ON cattoys.toy_id = toys.id
    WHERE cats.name = 'Brendon' 
    ORDER BY toys.name ASC
  SQL
end

def toys_that_brendon_owns_sub
  # List the all the toy names for all the cats named 'Brendon'.
  # Order alphabetically by toy name. 

  # USE A SUBQUERY
  execute(<<-SQL)
    SELECT a.toy_name
  
    FROM (
      SELECT cats.name AS cat_name, t.name AS toy_name
      FROM cats
      JOIN cattoys AS c ON cats.id = c.cat_id
      JOIN toys AS t ON c.toy_id = t.id
      WHERE cats.name = 'Brendon') AS a -- return cats named Brendan
    ORDER BY a.toy_name ASC 

  SQL
end

def price_like_shiny_mouse
  # There are multiple 'Shiny Mouse' toys that all have different prices.
  # Your goal is to list all names and prices of the toys with the same prices 
  # as the different 'Shiny Mouse' toys. 

  # Exclude the 'Shiny Mouse' toy from your results.
  # Order your alphabetically by toy name.

  # DO NOT USE A SUBQUERY
  execute(<<-SQL) 
    SELECT toys_2.name, toys_2.price
    FROM toys
    JOIN toys AS toys_2 ON toys.price = toys_2.price
    WHERE toys.name = 'Shiny Mouse'
      AND toys_2.name != 'Shiny Mouse'
    
  SQL
end

def price_like_shiny_mouse_sub
  # There are multiple 'Shiny Mouse' toys that all have different prices.
  # Your goal is to list all names and prices of the toys with the same prices 
  # as the different 'Shiny Mouse' toys. 

  # Exclude the 'Shiny Mouse' toy from your results.
  # Order your alphabetically by toy name.

  # USE A SUBQUERY
  execute(<<-SQL) 

      SELECT toys.name, toys.price
      FROM toys
      WHERE toys.name != 'Shiny Mouse'
        AND toys.price IN --all toys with same price as:
      (SELECT toys.price
      FROM toys
      WHERE toys.name = 'Shiny Mouse') --prices of all 'Shiny Mouse' toys
      ORDER BY toys.name ASC
  SQL
end

def just_like_orange
  # Find the breed of the cat named 'Orange'. 
  # Then list the cats names and the breed of all the cats of Orange's breed.
  # Exclude the cat named 'Orange' from your results.
  # Order by cats name alphabetically.

  # DO NOT USE A SUBQUERY
  execute(<<-SQL)
    SELECT kats.name, kats.breed
    FROM cats
      JOIN cats as kats on cats.breed = kats.breed
    WHERE cats.name = 'Orange' 
      AND kats.name != 'Orange'
    ORDER BY kats.name
  SQL
end

def just_like_orange_sub
  # Find the breed of the cat named 'Orange'. 
  # Then list the cats names and the breed of all the cats of Orange's  breed.
  # Exclude the cat named 'Orange' from your results.
  # Order by cats name alphabetically.

  # USE A SUBQUERY
  execute(<<-SQL)
    SELECT cats.name, cats.breed
    FROM cats
    WHERE cats.name != 'Orange' 
      AND cats.breed in
        (SELECT cats.breed
        FROM cats
        WHERE cats.name = 'Orange')
    ORDER BY cats.name
  SQL
end



def toys_that_jet_owns
  # Find all of the toys that Jet owns. Then list the the names of all 
  # the other cats that own those toys as well as the toys names.
  # Exclude Jet from the results.
  # Order alphabetically by cat name. 

  # DO NOT USE A SUBQUERY
  execute(<<-SQL)
    SELECT DISTINCT c.name, toys.name
    FROM cats
    JOIN cattoys ON cattoys.cat_id = cats.id
    JOIN toys ON cattoys.toy_id = toys.id 
    JOIN cattoys AS ct ON ct.toy_id = cattoys.toy_id
    JOIN cats AS c ON c.id = ct.cat_id
    WHERE cats.name = 'Jet' 
      AND c.name != 'Jet'
      
    ORDER BY c.name
      
  SQL
end

def toys_that_jet_owns_sub
  # Find all of the toys that Jet owns. Then list the the names of all 
  # the other cats that own those toys as well as the toys names.
  # Exclude Jet from the results.
  # Order alphabetically by cat name. 

  # USE A SUBQUERY
  execute(<<-SQL)
    
    SELECT cats.name, toys.name
    FROM cats
    JOIN cattoys ON cattoys.cat_id = cats.id
    JOIN toys ON cattoys.toy_id = toys.id
    WHERE cats.name != 'Jet'
      AND toys.id IN
        (SELECT DISTINCT toys.id
        FROM toys
        JOIN cattoys ON cattoys.toy_id = toys.id
        JOIN cats ON cattoys.cat_id = cats.id
        WHERE cats.name = 'Jet') --all toys that Jet owns
    ORDER BY cats.name
    
  SQL
end