SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[fueltax_export_fuel] @startdate datetime,
					 @enddate datetime

AS

SELECT CONVERT(char(21),fp_date,10) fp_date,
	CONVERT(char(11),fp_date,8) time,
	ISNULL(CONVERT(char(19),cty_name),'                   ') city,
	CONVERT(char(149),fp_state) state,
	CONVERT(char(24),trc_number) tractor,
	CONVERT(char(48),mpp_id) driver,
	CONVERT(char(25),fp_quantity) quantity,
	CONVERT(char(9),fp_uom) UOM,
	CONVERT(char(11),fp_fueltype) type,
	CONVERT(char(25),fp_cost_per) cost,
	CONVERT(char(53),CONVERT(float,fp_amount)) total,
	CONVERT(char(9),ts_code) sta,
	CONVERT(char(41),fp_vendorname) vendor,
	CONVERT(char(26),fp_invoice_no) invoice
FROM fuelpurchased, city
WHERE fp_date >= @startdate AND fp_date < DATEADD(dd,1,@enddate)
	AND fuelpurchased.fp_city *= city.cty_code
ORDER BY trc_number

GO
GRANT EXECUTE ON  [dbo].[fueltax_export_fuel] TO [public]
GO
