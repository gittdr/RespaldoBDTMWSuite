SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdateCarrierScore_sp]
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE carrier
	SET car_score = ISNULL(sub.avgRating, 0)
	FROM carrier c
	LEFT JOIN (SELECT CONVERT(int, ROUND(AVG(CONVERT(decimal, cr.cra_rating)), 0)) AS avgRating, cr.car_id AS car_id
				FROM carrierrating cr
				GROUP BY cr.car_id) sub
	ON sub.car_id = c.car_id
	
END
GO
GRANT EXECUTE ON  [dbo].[UpdateCarrierScore_sp] TO [public]
GO
