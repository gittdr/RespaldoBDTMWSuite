SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_Validate_Expiration] 	@sStartDate varchar(30), 
												@sEndDate varchar(30), 
												@sExpID varchar(8), 
												@sExpType varchar(3), 
												@sExpCompleted varchar(1),  
												@sExpKey varchar(12), 
												@sFlags as varchar(12)

AS
--Called by GetExpirations view and UpdateMove.

--Parameters
--
--@sStartDate 		Start Date of range to check. Only used if Auto_Complete is found on LabelFile Table
--@sEndDate			End date of range to check. 
--						if Auto_Complete is not found on LabelFile table, less than expiration_date
--						if Auto_Complete is found on LabelFile table and is set to Y, expiration_date must be equal or less than this date
--@sExpID			ID of resource
--@sExpType			Resource type to look up, defaults to TRC
--@sExpCompleted	Filter to completed date on lookup, defaults to N
--@sExpKey			Filter for Key to find, defaults to ALL
--
--@sFlags
--
-- 1	= Error if Due priority is Required
--

SET NOCOUNT ON 

CREATE TABLE #HeaderFields ( lcnt int, lpriority char(1), lpriorityexpkey int)

DECLARE @lcnt int , @dteStartDate datetime, @dteEndDate datetime, @lExpKey int, @lFlags int
DECLARE @lpriority char(1), @lPriorityExpKey as int, @lAutoCompletePresent int
DECLARE @SQLString NVARCHAR(2000), @chkcompleted varchar(1), @lbldeftype varchar(6), @sMainWhereStatement NVARCHAR(500)

SELECT @chkcompleted = CASE ISNULL(@sExpCompleted, '')
							WHEN '' THEN 'N'
							WHEN 'Y' THEN 'Y'
							WHEN 'N' THEN 'N' 
							WHEN '0' THEN 'N' 
							WHEN '1' THEN 'Y' 
							ELSE 'N' END

SELECT @lbldeftype = CASE ISNULL(@sExpType, '')
							WHEN 'CAR' THEN 'CarExp'
							WHEN 'DRV' THEN 'DrvExp' 
							WHEN 'TRL' THEN 'TrlExp'
							ELSE 'TrcExp' END 

if isdate(@sStartDate) = 1
	SET @dteStartDate = convert(datetime, @sStartDate)
else
	SET @dteStartDate = GetDate()

if isdate(@sEndDate) = 1
	SET @dteEndDate = convert(datetime, @sEndDate)
else
	SET @dteEndDate = GetDate()

if isnumeric(@sExpKey) = 1 
	SET @lExpKey = convert(int, @sExpKey)
else
	SET @lExpKey = 0

SET @lFlags = convert(int, @sFlags)

--See if the auto_complete field exists on the LabelFile table
--		if found we need to respect it. If set to Y, exp_compldate will be respected
--		if not found exp_compldate will not be respected
SELECT @lAutoCompletePresent = ISNULL(a.id, 0) FROM syscolumns a, sysobjects b WHERE a.name = 'auto_complete' AND a.id = b.id AND b.name = 'labelfile'

--Build Main WHERE clause for all select statements below
SELECT @sMainWhereStatement = N'( exp_completed = @chkCompleted) and 
							   ( exp_idtype = @sExpType  ) and 
							   ( exp_id = @sExpID ) AND
							   ( exp_Key = CASE @lExpKey WHEN 0 THEN exp_key ELSE @lExpKey END ) AND '	

if ISNULL(@lAutoCompletePresent,0) = 0 
	SET @sMainWhereStatement = @sMainWhereStatement + N'
		( exp_expirationdate <= @dteEndDate )'
else --Auto_complete field found
  	SET @sMainWhereStatement = @sMainWhereStatement + N'
		(exp_expirationdate < @dteEndDate AND
	      	((exp_compldate > @dteStartDate ) OR (ISNULL(l.auto_complete, ''N'') <> ''Y'')))'
--End building Main WHERE clause

--Find Count of due Expirations and highest due priority
SET @SQLString = N'
SELECT @lcnt = count(*) , @lpriority = min ( exp_priority )  
FROM expiration (NOLOCK)
LEFT join LabelFile l on exp_code = abbr AND labeldefinition = @lbldeftype
WHERE ' + @sMainWhereStatement

EXECUTE sp_executesql @SQLString, 
						N'@lcnt int OUT,
					    @lpriority char(1) OUT,
						@dteStartDate varchar(30), 
						@dteEndDate varchar(30), 
						@sExpID varchar(8), 
						@lbldeftype varchar(6), 
						@chkCompleted varchar(1),  
						@lExpKey int,
						@sExpType varchar(3)',
						@lcnt OUT,
						@lpriority OUT,
						@dteStartDate, 
						@dteEndDate, 
						@sExpID, 
						@lbldeftype, 
						@chkCompleted,  
						@lExpKey,
						@sExpType

--Find Due Expiration Key
SET @SQLString = N'
SELECT @lPriorityExpKey = min(exp_key)
FROM expiration (NOLOCK)
LEFT join LabelFile l on exp_code = abbr AND labeldefinition = @lbldeftype
WHERE ' + @sMainWhereStatement + N' AND ( exp_priority = @lpriority )'

EXECUTE sp_executesql @SQLString, 
						N'@lPriorityExpKey int OUT,
					    @lpriority char(1),
						@dteStartDate varchar(30), 
						@dteEndDate varchar(30), 
						@sExpID varchar(8), 
						@lbldeftype varchar(6), 
						@chkCompleted varchar(1),  
						@lExpKey int,
						@sExpType varchar(3)',
						@lPriorityExpKey OUT,
						@lpriority,
						@dteStartDate, 
						@dteEndDate, 
						@sExpID, 
						@lbldeftype, 
						@chkCompleted,  
						@lExpKey,
						@sExpType

--Return all expirations for range and criteria
SET @SQLString = N'
SELECT 	@lcnt ExpCount, 
	   	CASE @lPriority WHEN 1 THEN 1 ELSE 0 END DuePriorityIsRequired, 
		@lPriorityExpKey DueExpirationKey,
	   	exp_code Code, 
       	exp_lastdate LastDate, 
		exp_expirationdate ExpirationDate, 
		exp_routeto RouteTo, 
		exp_completed IsCompleted, 
		exp_priority Priority, 
		CASE exp_priority WHEN 1 THEN 1 ELSE 0 END IsRequired,
		exp_compldate CompleteDate, 
		exp_creatdate CreateDate, 
		CASE ISNULL(exp_description, '''') WHEN '''' THEN l.Name ELSE exp_description END ExpDescription, 
		exp_milestoexp MilesToExp, 
		exp_key ExpKey, 
		cty_nmstct City,
		exp_city CityKey 
FROM Expiration (NOLOCK)
LEFT join LabelFile l (NOLOCK) on exp_code = abbr AND labeldefinition = @lbldeftype
LEFT join city (NOLOCK) on exp_city = cty_code
WHERE ' + @sMainWhereStatement + N' 
ORDER BY Priority, ExpirationDate'

EXECUTE sp_executesql @SQLString, 
						N'@lcnt int,
						@lPriorityExpKey int,
					    @lpriority char(1),
						@dteStartDate varchar(30), 
						@dteEndDate varchar(30), 
						@sExpID varchar(8), 
						@lbldeftype varchar(6), 
						@chkCompleted varchar(1),  
						@lExpKey int,
						@sExpType varchar(3)', 
						@lcnt,
						@lPriorityExpKey,
						@lpriority,
						@dteStartDate, 
						@dteEndDate, 
						@sExpID, 
						@lbldeftype, 
						@chkCompleted,  
						@lExpKey,
						@sExpType

if (@lFlags & 1) = 1
	if @lpriority = 1
		raiserror ('Expiration Error: There is a priority 1 expiration.', 16, 1)

GO
GRANT EXECUTE ON  [dbo].[tmail_Validate_Expiration] TO [public]
GO
