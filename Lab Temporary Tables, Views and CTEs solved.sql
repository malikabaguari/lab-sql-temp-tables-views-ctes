-- ============================================================
-- Step 1: Create a View - Rental Summary per Customer
-- ============================================================
CREATE VIEW rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Verify the view
SELECT * FROM rental_summary;


-- ============================================================
-- Step 2: Create a Temporary Table - Payment Summary per Customer
-- ============================================================
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    rs.customer_id,
    SUM(p.amount) AS total_paid
FROM rental_summary rs
JOIN payment p ON rs.customer_id = p.customer_id
GROUP BY rs.customer_id;

-- Verify the temporary table
SELECT * FROM customer_payment_summary;


-- ============================================================
-- Step 3: Create a CTE and the Customer Summary Report
-- ============================================================

-- 3a: CTE joining the view with the temporary table
WITH customer_summary_cte AS (
    SELECT 
        rs.customer_name,
        rs.email,
        rs.rental_count,
        cps.total_paid
    FROM rental_summary rs
    JOIN customer_payment_summary cps ON rs.customer_id = cps.customer_id
)

-- 3b: Final report using the CTE, with derived average_payment_per_rental
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY total_paid DESC;
