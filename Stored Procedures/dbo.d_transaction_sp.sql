SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  PROC [dbo].[d_transaction_sp] (@startdt DATETIME, @enddt DATETIME,
       @cfb_employeenum VARCHAR(16), @cfb_cardnumber VARCHAR(20), @cfb_unitnumber VARCHAR(8), 
       @cfb_tripnumber VARCHAR(10)) 
AS

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	--DECLARE 
	
	--check the arguments
	SET @enddt = CONVERT(DATETIME, CONVERT(VARCHAR(12), @enddt, 101) + ' 23:59')
	IF @cfb_employeenum IS NULL or LTRIM(RTRIM(@cfb_employeenum)) = ''
		SELECT @cfb_employeenum = 'UNKNOWN'
	IF @cfb_cardnumber IS NULL or LTRIM(RTRIM(@cfb_cardnumber)) = ''
		SELECT @cfb_cardnumber = 'UNKNOWN'
	IF @cfb_unitnumber IS NULL or LTRIM(RTRIM(@cfb_unitnumber)) = ''
		SELECT @cfb_unitnumber = 'UNKNOWN'
	IF @cfb_tripnumber IS NULL or LTRIM(RTRIM(@cfb_tripnumber)) = ''
		SELECT @cfb_tripnumber = 'UNKNOWN'

	SELECT cfb_accountid,   
			cfb_customerid,   
			cfb_cardnumber,   
			cfb_transnumber,   
			cfb_transdate,   
			cfb_unitnumber,   
			cfb_tripnumber,   
			cfb_trcgallons,   
			cfb_totaldue,   
			cfb_employeenum  
		FROM cdfuelbill  
		WHERE cfb_transdate >= @startdt AND  
			cfb_transdate <= @enddt and
			(cfb_employeenum = @cfb_employeenum or @cfb_employeenum = 'UNKNOWN') and
			(cfb_cardnumber = @cfb_cardnumber or @cfb_cardnumber = 'UNKNOWN') and
			(cfb_unitnumber = @cfb_unitnumber or @cfb_unitnumber = 'UNKNOWN') and
			(cfb_tripnumber = @cfb_tripnumber or @cfb_tripnumber = 'UNKNOWN') and
			(cfb_error is null or cfb_error = '')
		order by cfb_employeenum, cfb_transdate desc

GO
GRANT EXECUTE ON  [dbo].[d_transaction_sp] TO [public]
GO
