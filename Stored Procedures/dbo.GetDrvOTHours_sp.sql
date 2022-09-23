SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[GetDrvOTHours_sp] @drvid varchar(8), @fromdate datetime, @todate datetime
AS

-- 30671
DECLARE @statpaycode VARCHAR(6) 
SELECT @statpaycode = gi_string1
FROM generalinfo
WHERE gi_name = 'StatPayCode'

/* returns the OT hours for the driver between two dates
   the Saturday field allows to to bring back multiple weeks
   and filter on the Saturday date which is used by the of_createotpay function
   in nvo_final settlements 

DPETE 27980 (created)
PTS40260 DPETE 4/17/08 recode Pauls

*/
SELECT 	pdh_othours
, pdh_date
, pdh_pyhpayperiod
, pdh_type
, yyyyww = Case(Datepart(dw,pdh_date)) 
   When 7 Then Datepart(yyyy,pdh_date) * 100 + Convert(char(2),Datepart(ww,pdh_date))
   Else Datepart(yyyy,DateAdd(d,7 - (Datepart(dw,pdh_date)),pdh_date)) * 100 + Convert(char(2),Datepart(ww,DateAdd(d,7 - (Datepart(dw,pdh_date)),pdh_date)) )
   End
-- 30671
--, IsHoliday = Case IsNull(holidays.description,'') When '' Then 'N' Else 'Y' End
, IsHoliday = Case WHEN (IsNull(holidays.description,'') = '' OR pyt_itemcode = @statpaycode) THEN 'N' ELSE 'Y' end
, pdh_identity
, Saturday = Case(Datepart(dw,pdh_date)) 
   When 7 Then pdh_date
   Else DateAdd(d,7 - (Datepart(dw,pdh_date)),pdh_date)
   End
--, dailyot = 'N'
, dd = Datepart(dd, pdh_date)		--	LOR	PTS# 60099
FROM pdhours pdh
   JOIN paydetail On pdh.pyd_number = paydetail.pyd_number
   Left Outer Join  holidays on Datepart(yyyy,holiday) = Datepart(yyyy,pdh_date) and datepart(dy,holiday) = datepart(dy,pdh_date)
WHERE pdh_date between @fromdate AND @todate
And paydetail.asgn_type = 'DRV'
AND paydetail.asgn_id =  @drvid

GO
GRANT EXECUTE ON  [dbo].[GetDrvOTHours_sp] TO [public]
GO
