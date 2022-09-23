SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[fueltax_export_callin] @startdate datetime,
					   @enddate datetime

AS

SELECT  CONVERT(char(21),cty_name) ckc_cityname,
	CONVERT(char(9), 0) trip_id,
	CONVERT(char(17), ckc_tractor) ckc_tractor,
	CONVERT(char(9), ckc_date, 10) date,
	CONVERT(char(4),'RV') stop_type,
	CONVERT(char(3),cty_state) cty_state,
	CONVERT(char(6), 0) volume,
	CONVERT(char(2), 'G') volume_units,
	CONVERT(char(8), 0) cost,
	CONVERT(char(18), 'UNK') vendor,
	CONVERT(char(11), 0) invoice,
	CONVERT(char(2), 'Y') valid_receipt,
	CONVERT(char(2), 'Y') taxable,
	CONVERT(char(2), 'Y') tax_paid,
	CONVERT(char(2), 'Y') bulkflag,
	CONVERT(char(11), 0) order_number,  
	CONVERT(char(8), ckc_date,8) time,
	CONVERT(char(8), '') driver,
	ISNULL(CONVERT(char(8), ckc_latseconds), '        ') ckc_latseconds,
	ISNULL(CONVERT(char(8), ckc_longseconds), '        ') ckc_longseconds,
	CONVERT(char(2), '?') loaded_status,
	CONVERT(char(1), '') gps_type,
	CONVERT(char(8), 0) odometer_start,
	CONVERT(char(8), 0) odometer_end,
	ISNULL(CONVERT(char(8), ckc_lghnumber), '        ') ckc_lghnumber,
	CONVERT(char(8), 0) sequence,
	CONVERT(char(1), 'C') call_type   
FROM checkcall,city
WHERE ckc_date >= @startdate AND ckc_date < DATEADD(dd,1,@enddate)
AND ckc_city *= city.cty_code
AND ckc_updatedby <> 'TMAIL'
AND ckc_event <> 'FUL'
ORDER BY ckc_date desc

GO
GRANT EXECUTE ON  [dbo].[fueltax_export_callin] TO [public]
GO
