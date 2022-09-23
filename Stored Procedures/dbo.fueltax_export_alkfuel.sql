SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[fueltax_export_alkfuel] @startdate datetime,
					    @enddate datetime

AS

SELECT 	CONVERT(char(3),fp_state) state,
	CONVERT(char(7),fp_quantity) quantity,
	CONVERT(char(3), 'FP') stoptype,
	CONVERT(char(9),trc_number) tractor,
	CONVERT(char(11),fp_date,110) fp_date,
	CONVERT(char(8),CONVERT(float,fp_amount)) total,
	ISNULL(CONVERT(char(19),cty_name),'                   ') city,
	CONVERT(char(11),fp_invoice_no) invoice,
	CONVERT(char(31),fp_vendorname) vendor,
	uom = CASE fp_uom
			WHEN 'GAL' THEN 'G'
			WHEN 'LIT' THEN 'L'
			ELSE 'G'
		END	
FROM fuelpurchased, city
WHERE fuelpurchased.fp_date >= @startdate AND fuelpurchased.fp_date < DATEADD(dd,1,@enddate)
        AND ISNULL(fuelpurchased.lgh_number, 0) = 0
        AND fuelpurchased.fp_city *= city.cty_code
ORDER BY fp_date, tractor

GO
GRANT EXECUTE ON  [dbo].[fueltax_export_alkfuel] TO [public]
GO
