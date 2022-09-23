SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[tcg_customer_names_sp] (@mileagetype int)AS
SELECT LEFT(cmp_name + SPACE(30), 30) customer_name,
       LEFT(STR(cmp_city, 9, 0) + SPACE(20), 20) id_field,
       LEFT(cmp_id + SPACE(12), 12) customer_code
FROM   company
ORDER BY customer_name

GO
