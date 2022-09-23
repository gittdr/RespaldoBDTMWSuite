SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[getstatOTpayrate] (@driver varchar(8)
, @holiday datetime)
AS
/**
 * 
 * NAME:
 * dbo.getstatOTpayrate
 *
 * TYPE:
 * [StoredProcedure] 
 *
 * DESCRIPTION:
 * This procedure determines the hours and rate to be used to compute a drivers stat holiday
 * pay rate for the holiday date passed
 *
 * RETURNS:
 * A rate and the hours to be payed for the holiday
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @driver a valid driver ID
 * 002 - @holiday a holiday date
 *
 * REFERENCES: (called by nvo_final_settlements of_createstatotpay function)
 
 * 
 * REVISION HISTORY:
 * 09/07/2004.01 ? PTS24576 - Dan Klein ? Created
 * 10/31/2005.03 - PTS20443 - Donna Petersen - found date field on pdhours might contain a time other than 00:00
 *                              such records are not processed
 **/

DECLARE
  @TotalPay Decimal(9,2)
, @TotalHours Float
, @HolidayHours Float
, @OTRate Decimal(9,2)
, @StatPyt VARCHAR(6)
, @StatOTPyt VARCHAR(6)
, @OTPyt VARCHAR(6)
, @holidayend datetime

declare @Maxhours smallint

CREATE TABLE #temp1 (pyd_number int, asgn_type varchar(6), asgn_id varchar(8), pyd_amount decimal(9, 2))

SELECT @StatPyt = gi_string1 FROM generalinfo WHERE gi_name = 'StatPayCode'
SELECT @StatOTPyt = gi_string1 FROM generalinfo WHERE gi_name = 'StatOTPayCode' 
SELECT @OTPyt = gi_string1 FROM generalinfo WHERE gi_name = 'OTPayCode'
Select @holidayend =  DateAdd(mi,-1,DateAdd(dd,1,@holiday))


INSERT INTO #temp1
SELECT DISTINCT paydetail.pyd_number, paydetail.asgn_type, paydetail.asgn_id, paydetail.pyd_amount
FROM		paydetail, pdhours
WHERE		pdhours.pdh_date  between @holiday and @holidayend --= @holiday
  AND		pdhours.pyd_number = paydetail.pyd_number
  AND		paydetail.asgn_type = 'DRV'
  AND		paydetail.asgn_id = @driver
  AND		paydetail.pyt_itemcode <> @StatPyt
  AND		paydetail.pyt_itemcode <> @StatOTPyt
  AND		paydetail.pyt_itemcode <> @OTPyt

SELECT @totalpay = sum(pyd_amount) from #temp1

SELECT 	@TotalHours = SUM(pdhours.pdh_standardhours)
FROM 		pdhours
WHERE 	pdhours.pyd_number IN 
				(SELECT 	paydetail.pyd_number 
					FROM	paydetail, pdhours
					WHERE	pdhours.pyd_number = paydetail.pyd_number
					  AND	paydetail.asgn_type = 'DRV'
					  AND	paydetail.asgn_id = @driver
					  AND	pdhours.pdh_date  between @holiday and @holidayend )
SELECT 	@holidayhours = SUM(pdhours.pdh_standardhours)
FROM		paydetail, pdhours
WHERE		pdhours.pdh_date  between @holiday and @holidayend 
  AND		pdhours.pyd_number = paydetail.pyd_number
  AND		paydetail.asgn_type = 'DRV'
  AND		paydetail.asgn_id = @driver

IF @totalhours <= 0 OR @holidayhours <= 0 
	SET @OTRate = 0
ELSE
	SET 	@OTRate = ((@totalpay * (@holidayhours/@totalhours))/@holidayhours) / 2 -- divide by two to get the half of the time and a half (already paid the regular)

DROP TABLE #temp1

--	LOR	PTS# 40764
select @Maxhours = convert(smallint,gi_string1) from generalinfo where gi_name = 'MaxStatOTHours'
select @maxhours = isnull(@maxhours,14)
if @HolidayHours > @maxhours set @HolidayHours = @maxhours
--	LOR

SELECT @HolidayHours, @OTRate

GO
GRANT EXECUTE ON  [dbo].[getstatOTpayrate] TO [public]
GO
