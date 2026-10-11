-- ============================================================
-- THE UNLOX ACADEMY - Weekly Assessment (Week 4)
-- Name: Navyashree
-- ============================================================

USE bookmart;

-- ====================================================
-- SECTION A - THEORY (write the answer letter only)
-- =====================================================

-- A1. What is the key difference between INNER JOIN and LEFT JOIN?
--     a) INNER JOIN always returns more rows than LEFT JOIN
--     b) INNER JOIN returns only matched rows; LEFT JOIN returns all left-table rows with NULL for nonmatches
--     c) LEFT JOIN can only be applied to the primary table
--     d) They produce identical results in all cases
-- Your answer: b

-- A2. What does OVER (PARTITION BY department) do in a window function?
--     a) Filters rows to only one department
--     b) Groups rows by department and collapses them into one row per group
--     c) Restarts the aggregate calculation for each department while keeping all input rows
--     d) Sorts the result by department
-- Your answer: c

-- A3. Why is NATURAL JOIN considered a production anti-pattern?
--     a) MySQL doesn't support it
--     b) It's always slower than INNER JOIN
--     c) It silently joins on ALL columns with matching names - behaviour can change unexpectedly when the schema is modified
--     d) It always produces duplicate rows
-- Your answer: c

-- A4. When should you prefer UNION ALL over UNION?
--     a) When you specifically want to remove duplicates
--     b) When the two queries cannot produce overlapping rows, OR when performance matters more than deduplication
--     c) When you have exactly two SELECT statements
--     d) When the two queries return the same table
-- Your answer: b

-- A5. What is the NOT IN + NULL trap?
--     a) NOT IN cannot be used with VARCHAR columns
--     b) If the subquery inside NOT IN returns any NULL value, the entire NOT IN silently returns zero rows
--     c) NOT IN is always slower than NOT EXISTS
--     d) NOT IN only works with numeric columns
-- Your answer: 

-- A6. What defines a correlated subquery?
--     a) A subquery that runs once before the outer query
--     b) The inner query references a column from the outer query, causing it to re-execute for each outer row
--     c) A subquery that returns exactly one row
--     d) A subquery nested inside another subquery
-- Your answer: b

-- A7. Why can't you use WHERE with a window function alias directly?
--     a) Window functions cannot produce aliases
--     b) WHERE runs BEFORE window functions are calculated, so the alias doesn't exist yet
--     c) Aliases work only in the SELECT clause
--     d) This is a MySQL-specific bug
-- Your answer: b

-- A8. What is a CTE (Common Table Expression)?
--     a) A permanent table stored in the database
--     b) A named temporary result set defined with the WITH clause, existing only for the duration of the query
--     c) A syntax for creating indexes
--     d) A special type of JOIN operation
-- Your answer: b

-- ============================================================
-- SECTION B - OUTPUT PREDICTION (describe row count / values)
-- ============================================================

-- B1. How many rows does this query return?

SELECT * FROM books b
INNER JOIN authors a ON b.author_id = a.author_id;
-- Your answer: 25 rowsw

-- B2. How many rows does this query return?
    SELECT a.name FROM authors a
	LEFT JOIN books b ON a.author_id = b.author_id
	WHERE b.book_id IS NULL;
-- Your answer: 0 rows returned

-- B3. How many rows does this self-join return, and who are they?
     SELECT a.name AS author, m.name AS mentor
     FROM authors a
     JOIN authors m ON a.mentor_id = m.author_id;
-- Your answer: 3 rows

-- B4. How many rows does this UNION return?
     SELECT name FROM authors WHERE country = 'India'
     UNION
     SELECT a.name FROM authors a
     JOIN books b ON a.author_id = b.author_id
     WHERE b.genre = 'Mythology';
-- Your answer: 5 rows

-- B5. What single value does this query return?
     SELECT COUNT(*) FROM books
     WHERE price > (SELECT AVG(price) FROM books);
-- Your answer: 1 row

-- B6. How many rows does this query return?
     SELECT * FROM books b
     WHERE NOT EXISTS (
	 SELECT 1 FROM sales s WHERE s.book_id = b.book_id );
-- Your answer: 15 rows 

-- B7. What is the total_qty of the top-selling book (first row)?
     SELECT b.title, SUM(s.quantity) AS total_qty
     FROM sales s JOIN books b ON s.book_id = b.book_id
     GROUP BY b.book_id
     ORDER BY total_qty DESC
     LIMIT 1;
-- Your answer: 1 row returned

-- B8. What does this query output for Business genre books?
     SELECT title, price,
	 RANK() OVER (PARTITION BY genre ORDER BY price DESC) AS rank_in_genre
     FROM books WHERE genre = 'Business';
-- Your answer: 4 rows

-- ============================================================
-- SECTION C - APPLIED SQL
-- ============================================================

-- C1. Write a query using INNER JOIN to display each book's title alongside its author's name.
SELECT b.title, a.name
FROM books b
INNER JOIN authors a ON b.author_id = a.author_id;
-- 25 rows

-- C2. Write a LEFT JOIN query listing every author's name and every book they've written. Authors with no books should still appear (once) with NULL for book columns.
SELECT a.name, b.title
FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id;

-- C3. Write a query to compute total revenue (sum of quantity × price) per genre. Sort by revenue descending.

SELECT b.genre,
    SUM(s.quantity * b.price) AS revenue
FROM sales AS s
INNER JOIN books AS b
    ON s.book_id = b.book_id
GROUP BY b.genre
ORDER BY revenue DESC;


-- C4. Write a query to find the single city that has generated the most revenue.
SELECT
    s.city,
    SUM(s.quantity * b.price) AS revenue
FROM sales AS s
INNER JOIN books AS b
    ON s.book_id = b.book_id
GROUP BY s.city
ORDER BY revenue DESC
LIMIT 1;

-- C5. Write a RIGHT JOIN query showing every book (via RIGHT JOIN from authors) alongside its author. Explain briefly why the result count matches INNER JOIN here.
SELECT b.title, a.name
FROM authors a
RIGHT JOIN books b ON a.author_id = b.author_id;
-- because every book in database is linked to valid author_id

-- C6. Write a FULL OUTER JOIN of authors and books using the UNION trick (since MySQL doesn't support FULL OUTER directly).
SELECT a.author_id, a.name AS author, b.book_id, b.title AS book
FROM authors AS a
LEFT JOIN books AS b ON a.author_id = b.author_id
UNION
SELECT a.author_id, a.name AS author, b.book_id, b.title AS book
FROM authors AS a
RIGHT JOIN books AS b ON a.author_id = b.author_id;

-- C7. Write a SELF JOIN query showing the name of every mentored author alongside their mentor's name.
SELECT n.name AS author, m.name AS mentor
FROM authors AS n
INNER JOIN authors AS m ON n.mentor_id = m.author_id;

-- C8. Write a CROSS JOIN query generating every possible combination of city and customer_type from the sales table (use SELECT DISTINCT subqueries).
SELECT c.city, ct.customer_type
FROM (
    SELECT DISTINCT city
    FROM sales
) AS c
CROSS JOIN (
    SELECT DISTINCT customer_type
    FROM sales
) AS ct
ORDER BY c.city, ct.customer_type;

-- C9. Write a UNION query combining: (a) all Indian authors, (b) all authors born after 1970. Result should be deduplicated.
SELECT name
FROM authors
WHERE country = 'India'
UNION
SELECT name
FROM authors
WHERE born_year > 1970;

-- C10. Write an anti-join query using LEFT JOIN + IS NULL to find all books that have NEVER been sold.
SELECT b.title
FROM books AS b
LEFT JOIN sales AS s
    ON b.book_id = s.book_id
WHERE s.book_id IS NULL;

-- C11. Write a scalar subquery to find all books priced above the overall average book price.
SELECT
    *
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
);								

-- C12. Write a query using IN with a subquery to show all sales of books whose genre is either 'History' or 'Mythology'.

SELECT *
FROM sales
WHERE book_id IN (
    SELECT book_id
    FROM books
    WHERE genre IN ('History', 'Mythology')
);
-- C13. Write a query using > ALL to find books priced higher than every single Fiction book.
SELECT
    *
FROM books
WHERE price > ALL (
    SELECT price
    FROM books
    WHERE genre = 'Fiction'
);
-- C14. Write a correlated subquery to find books priced above their genre's average price.
SELECT b.*
FROM books AS b
WHERE b.price > (
    SELECT AVG(bn.price)
    FROM books AS bn
    WHERE bn.genre = bn.genre
);

-- C15. Write an EXISTS query to find all authors who have written at least one book published after 2018.
SELECT name
FROM authors a
WHERE EXISTS (
    SELECT 1 FROM books b
    WHERE b.author_id = a.author_id AND b.published_year > 2018 )
			
-- C16. Write a NOT EXISTS query to find all authors who have never written a book in the 'Business' genre.
 
SELECT a.*
FROM authors AS a
WHERE NOT EXISTS (
    SELECT 1
    FROM books AS b
    WHERE b.author_id = a.author_id
      AND b.genre = 'Business'
);

-- C17. Write a query using IN with a subquery to find all sales made for books written by Indian authors.
SELECT
    *
FROM sales
WHERE book_id IN (
    SELECT b.book_id
    FROM books AS b
    INNER JOIN authors AS a
        ON b.author_id = a.author_id
    WHERE a.country = 'India'
);
-- C18. Write a query showing every book alongside its genre's average price (using AVG OVER PARTITION BY) - all 25 rows should appear.
SELECT
    b.title,
    b.genre,
    b.price,
    AVG(b.price) OVER (
        PARTITION BY b.genre
    ) AS genre_avrg_price
FROM books AS b;

-- C19. Write a query using ROW_NUMBER to find the top 2 highest-priced books in each genre.
WITH ranked_books AS (
    SELECT b.*,
        ROW_NUMBER() OVER ( PARTITION BY b.genre ORDER BY b.price DESC, b.book_id
        ) AS rns
    FROM books AS b
)
SELECT *
FROM ranked_books
WHERE rns <= 2
ORDER BY genre, rns;

-- C20. Using LAG, write a query showing each sale of book_id 115 (Atomic Habits) alongside the quantity of the previous sale (sorted by sale_date). The first sale should show NULL for previous quantity.
SELECT
    sale_id,
    book_id,
    sale_date,
    quantity,
    LAG(quantity) OVER (
        ORDER BY sale_date, sale_id
    ) AS previous_sale_quantity
FROM sales
WHERE book_id = 115
ORDER BY sale_date, sale_id;



-- C21. Write a query using SUM() OVER (ORDER BY sale_date) to compute a running total of quantity across all sales.;

SELECT
    sale_id,
    sale_date,
    quantity,
    SUM(quantity) OVER (
        ORDER BY sale_date, sale_id) AS total_quantity
FROM sales
ORDER BY sale_date, sale_id;

-- C22. Rewrite this query using a CTE (WITH clause) for readability. Compute total quantity sold per book, then join to book details showing title and total.
;
WITH book_totals AS (
    SELECT book_id,
        SUM(quantity) AS total_quantity
    FROM sales
    GROUP BY book_id
)
SELECT b.title, bt.total_quantity
FROM book_totals AS bt
INNER JOIN books AS b ON bt.book_id = b.book_id
ORDER BY b.book_id;

-- C23. Write a multi-CTE query: first CTE computes revenue per genre, second CTE ranks genres by revenue using RANK(). Final SELECT shows genre, revenue, and rank.
WITH genre_revenue AS (
    SELECT b.genre,
        SUM(s.quantity * b.price) AS revenue
    FROM sales AS s
    INNER JOIN books AS b
        ON s.book_id = b.book_id
    GROUP BY b.genre
),
ranked_genres AS (
    SELECT genre, revenue,
        RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM genre_revenue
)
SELECT genre, revenue, revenue_rank
FROM ranked_genres
ORDER BY revenue_rank, genre;

-- C24. Write a comprehensive query: for each genre, show the top-selling book (by total quantity sold), its author's name, its total quantity, 
-- and the genre's total revenue. Use CTEs + window functions + joins. Sort by genre revenue descending.

WITH book_sales AS (
    SELECT b.book_id, b.title, b.author_id, b.genre, b.price,
        COALESCE(SUM(s.quantity), 0) AS total_quantity,
        COALESCE(SUM(s.quantity * b.price), 0) AS book_revenue
    FROM books AS b
    LEFT JOIN sales AS s
        ON b.book_id = s.book_id
    GROUP BY b.book_id, b.title, b.author_id, b.genre, b.price
),
genre_totals AS (
    SELECT
        genre,
        SUM(book_revenue) AS genre_revenue
    FROM book_sales
    GROUP BY genre
),
ranked_books AS (
    SELECT
        bs.*,
        ROW_NUMBER() OVER (
            PARTITION BY bs.genre
            ORDER BY bs.total_quantity DESC, bs.book_id
        ) AS rn
    FROM book_sales AS bs
)
SELECT
    rb.genre,
    rb.title,
    a.name AS author,
    rb.total_quantity,
    gt.genre_revenue
FROM ranked_books AS rb
INNER JOIN authors AS a
    ON rb.author_id = a.author_id
INNER JOIN genre_totals AS gt
    ON rb.genre = gt.genre
WHERE rb.rn = 1
ORDER BY gt.genre_revenue DESC, rb.genre;