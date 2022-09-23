SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[createavgfuelformula_withdate_sp] 	@pl_aff_id  	INTEGER,
							@process_date	DATETIME,
							@ps_returnmsg 	VARCHAR(255) OUTPUT 
AS

SET NOCOUNT ON

-- PTS 75085  3/19/2014:  execute 'create' proc first to eliminate creating 'bad' formulas for dates too far beyond 'current' doe max date.
-- 04/14/2014				Consolidated PTS List 65765, 68003, 65092 and 75085) 


---- PTS 75085.start don't create datarows beyond the effective date we SHOULD  have based on parent DOE max date.
declare @maxdate datetime
declare @Myid varchar(8)
declare @afpCount int
select @Myid = aff_formula_tableid from AvgFuelFormulaCriteria where aff_id = @pl_aff_id

select @afpCount = count(*) 
from averagefuelprice 
where afp_tableid = (select aff_formula_tableid from AvgFuelFormulaCriteria where aff_id = @pl_aff_id )
if @afpCount is null set @afpCount = 0

if @afpCount = 0
begin
	exec CreateAvgFuelFormula_sp @pl_aff_id , @ps_returnmsg  Output 	
	select  @maxdate = MAX(afp_date) from averagefuelprice where afp_tableid = @Myid
	select @afpCount = count(*) from averagefuelprice where afp_tableid = @Myid	
	set @ps_returnmsg = SPACE(255)
end 

if @afpCount > 0
begin	
	select @maxdate = MAX(afp_date) from averagefuelprice where afp_tableid = @Myid
	if @process_date >= @maxdate  RETURN
end
---- PTS 75085.end



DECLARE @afp_tableid 			VARCHAR(8), 	
	@aff_formula_tableid		VARCHAR(8), 
	@aff_Interval 			VARCHAR(8), 
	@aff_CycleDay			VARCHAR(8), 
	@aff_Formula 			VARCHAR(8), 	
	@aff_effective_day1 		INTEGER, 
	@aff_effective_day2 		INTEGER,
	@aff_formula_Acronym		VARCHAR(12) 
-----------
DECLARE @New_AFP			MONEY,
	@daycode			INTEGER,
	@todaydaycode			INTEGER,
	@previousdate			DATETIME,
	@maxdatefortableid		DATETIME,
	@maxseconds			INTEGER,
	@formulacount			INTEGER,
	@new_description		VARCHAR(30),
	@rowsec_rsrv_id			INTEGER,
	@afp_revtype1			VARCHAR(6)
-----------
-- Constants & Validations (due to QA testing/able to create corrupt data:) PTS 61286/5-9-12
DECLARE @g_genesis              	DATETIME,
 	@g_apocalypse           	DATETIME,
	@badidCount 			INTEGER,
	@afp_tableid_Count 		INTEGER,
	@String_afp_tableid 		VARCHAR(10),
	@minbad 			INTEGER,
	@maxbad 			INTEGER,
	@mindescr 			VARCHAR(40),
	@maxdescr 			VARCHAR(40),
	@msg1 				VARCHAR(140),
	@msg2 				VARCHAR(140),
	@msg3 				VARCHAR(140),
	@SAVEpl_aff_id			INTEGER

DECLARE @BeginWeekTHIS			DATETIME,
        @EndWeekTHIS			DATETIME,
        @BeginWeekLAST			DATETIME,
        @EndWeekLAST			DATETIME,
        @maxParentDate			DATETIME,
        @PREV_WEEK_ParentDate		DATETIME,
        @maxParentDate_dayofweek   	INTEGER,
        @maxParent_dow_name		VARCHAR(6),
        @TestDateBOD			DATETIME,
        @TestDateEOD			DATETIME,
        @specificMessage		VARCHAR(200),
	@NewFormulaEffectiveDate 	DATETIME,
	@daysaddnbr 			INTEGER,
	@chosenDate 			INTEGER

SET @g_genesis = Convert(DateTime,'1950-01-01 00:00:00')
SET @g_apocalypse = Convert(DateTime,'2049-12-31 23:59:59')

SET @SAVEpl_aff_id = @pl_aff_id 
---------------------------------------------

SELECT @afp_tableid = afp_tableid, 
       @aff_formula_tableid = aff_formula_tableid,
       @aff_Interval = aff_Interval, 
       @aff_CycleDay = aff_CycleDay, 
       @aff_Formula = aff_Formula,
       @aff_effective_day1 = aff_effective_day1,
       @aff_effective_day2 = aff_effective_day2,
       @new_description	= afp_Description + ': ' + aff_formula_Acronym	
 FROM  AvgFuelFormulaCriteria  
 WHERE aff_id = @pl_aff_id 

SET @ps_returnmsg = ''

SELECT @rowsec_rsrv_id = rowsec_rsrv_id,  
       @afp_revtype1 = afp_revtype1		
  FROM averagefuelprice  
 WHERE afp_tableid = @afp_tableid


-- Validation#1
IF @pl_aff_id IS NULL
   SET @pl_aff_id = 0

IF @pl_aff_id = 0
BEGIN
	SET @ps_returnmsg = 'Error: Data Not Valid!  CreateAvgFuelFormula_sp Proc received parameter: AverageFuelPrice TableId = Null or Zero.' 
	SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))	
	RETURN
END  	

SET @afp_tableid_Count = (SELECT COUNT(afp_tableid) 
                            FROM averagefuelprice 	
                           WHERE afp_tableid = @afp_tableid AND
                                 ISNULL(afp_IsFormula, 0) = 0) 								
-- Validation#2					
IF @afp_tableid_Count < 2 
BEGIN
   SET @String_afp_tableid = CAST(@afp_tableid AS VARCHAR(10))
   SET @msg1 = 'Error: Data Not Valid!  CreateAvgFuelFormula_sp Proc finds Less than TWO AverageFuelPrice Entries for TableId=' 
   SET @msg2 = 'A MINIMUM of TWO AverageFuelPrice Entries must exist to create a Formula! '		
   SET @ps_returnmsg = LTRIM(RTRIM(@msg1)) + @String_afp_tableid + '.  ' +  LTRIM(RTrim(@msg2))
   RETURN			
END  


-- Validation#3	(formula's exist but there is no matching avg fuel table entry: {deleted data with sql from only 1 table!} )
SELECT @badidCount = COUNT(AvgFuelFormulaCriteria.aff_id) 
  FROM AvgFuelFormulaCriteria
 WHERE AvgFuelFormulaCriteria.afp_tableid NOT IN (SELECT DISTINCT(averagefuelprice.afp_tableid) 
                                                    FROM averagefuelprice 
                                                   WHERE ISNULL(averagefuelprice.afp_IsFormula, 0) = 0) 
IF @badidCount > 0 
BEGIN
   SELECT AvgFuelFormulaCriteria.aff_id 'aff_id', 
          CAST(SPACE(40) as varchar(40)) 'descr'
     INTO #tmpbaddata 
     FROM AvgFuelFormulaCriteria
    WHERE AvgFuelFormulaCriteria.afp_tableid NOT IN (SELECT DISTINCT(averagefuelprice.afp_tableid) 
                                                       FROM averagefuelprice 
                                                      WHERE ISNULL(averagefuelprice.afp_IsFormula, 0) = 0) 

   UPDATE #tmpbaddata  
      SET #tmpbaddata.descr = (SELECT AvgFuelFormulaCriteria.afp_description 
                                 FROM AvgFuelFormulaCriteria 
                                WHERE #tmpbaddata.aff_id = AvgFuelFormulaCriteria.aff_id)  
   sELECT @minbad = MIN(aff_id) 
     FROM #tmpbaddata 
   SELECT @maxbad =  MAX(aff_id)
     FROM #tmpbaddata 
   SET @mindescr = (SELECT MIN(descr) 
                      FROM #tmpbaddata  
                     WHERE aff_id = @minbad)
   SET @maxdescr = (SELECT MAX(descr) 
                      FROM #tmpbaddata  
                     WHERE aff_id = @maxbad)
									
   SET @msg1 = 'Error: Data Not Valid!  ' + CAST(@badidCount AS VARCHAR(10)) + ' AvgFuelFormulaCriteria Entries exist With NO Matching AverageFuelPrice ID!' 					select @msg2 = 'First Bad Record: ' + RTRIM(CAST(@minbad as varchar(10))) + ' ' + LTRIM(RTRIM(@mindescr))
   SET @msg3 = 'Last Bad Record: ' + RTRIM(CAST(@maxbad AS VARCHAR(10))) + ' ' + LTRIM(RTRIM(@maxdescr))
   SET @ps_returnmsg = SUBSTRING((@msg1 + ' ' + @msg2 + ', ' + @msg3), 1, 200) 
			
   IF OBJECT_ID(N'tempdb..#tmpbaddata', N'U') IS NOT NULL
      DROP TABLE #tmpbaddata
			
   RETURN	
END


-- using today as startpoint - get the begin/end dates of THIS week (& lastwk)
IF (SELECT DATEPART(dw, @process_date)) > 1 
BEGIN
   SET @BeginWeekTHIS = DATEADD(DD, -(DATEPART(dw, @process_date) - 1), @process_date)
   SET @EndWeekTHIS = DATEADD(DD, +6, @BeginWeekTHIS)
   SET @BeginWeekLAST = DATEADD(dd, -7, @BeginWeekTHIS)
   SET @EndWeekLAST = DATEADD(dd, +6, @BeginWeekLAST)	
END

IF (SELECT DATEPART(dw, @process_date)) = 1
BEGIN
   SET @BeginWeekTHIS = DATEADD(dd, -7, @process_date)									-- last Sunday
   SET @EndWeekTHIS = DATEADD(DD, +6 , @BeginWeekTHIS) 								-- next Saturday
   SET @BeginWeekLAST = DATEADD(dd, -7, @BeginWeekTHIS)
   SET @EndWeekLAST = DATEADD(dd, +6, @BeginWeekLAST)
END 

SET @BeginWeekTHIS = CONVERT(VARCHAR(10), @BeginWeekTHIS, 101) + ' 00:00:00'
SET @EndWeekTHIS = CONVERT(VARCHAR(10), @EndWeekTHIS, 101) + ' 23:59:59'
SET @BeginWeekLAST = CONVERT(VARCHAR(10), @BeginWeekLAST, 101) + ' 00:00:00'
SET @EndWeekLAST = CONVERT(VARCHAR(10), @EndWeekLAST, 101) + ' 23:59:59'

--  Use only the DOE values ==>  afp_IsFormula = 0
-- Get the maximum Parent date matching the criteria.
IF @aff_CycleDay IS NOT NULL 
BEGIN	
   SELECT @daycode = code 
     FROM labelfile 
    WHERE labeldefinition = 'affCycleDay' AND
          abbr = @aff_CycleDay		
		
   SELECT @maxParentDate = MAX(afp_date)
     FROM averagefuelprice 	
    WHERE afp_tableid = @afp_tableid AND
          ISNULL(afp_IsFormula, 0) = 0 AND
          afp_date <= @process_date
				
   SET @maxParentDate_dayofweek = DATEPART(dw, @maxParentDate)
END
ELSE
BEGIN
   SELECT @maxParentDate = MAX(afp_date)
     FROM averagefuelprice 	
    WHERE afp_tableid = @afp_tableid AND	
          ISNULL(afp_IsFormula, 0) = 0 AND
          afp_date <= @process_date

   SET @maxParentDate_dayofweek = DATEPART(dw, @maxParentDate)
END

SELECT @maxParent_dow_name = abbr 
  FROM labelfile 
 WHERE labeldefinition = 'affCycleDay' AND 
       code = @maxParentDate_dayofweek

SET @PREV_WEEK_ParentDate = DATEADD(dd, -7, @maxParentDate)

/*-- Check for duplicates: Don't allow

SELECT @formulacount = COUNT(afp_tableid) 
  FROM averagefuelprice  
 WHERE afp_tableid = @aff_formula_tableid AND
       afp_Description = @new_description

if @formulacount > 0 
BEGIN
   SET @ps_returnmsg = 'Error: Averagefuelprice.afp_tableid =' + CAST(@aff_formula_tableid AS VARCHAR(5)) + ', Formula "' + @new_description + '" already exists in the Average Fuel Price Table.'
   SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))	
   RETURN
END */

-- There are 4 'formulas' currenly: AVG2, AVG4 and PreWk are all deal w/ the PREVIOUS week values
------- 9-30-2011 FIX:  changed calulations and error messages.
IF @aff_Formula = 'AVG2WK'
BEGIN		
   SET @TestDateBOD = DATEADD(ww, -2, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
   SET @TestDateEOD = DATEADD(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 23:59:59') 
   
   SELECT @New_AFP = AVG(afp_price) 
     FROM averagefuelprice 
    WHERE afp_tableid = @afp_tableid AND
          afp_date >= @TestDateBOD AND afp_date <= @TestDateEOD AND
          ISNULL(afp_IsFormula, 0) = 0

   IF @New_AFP IS NULL
   BEGIN
      sET @specificMessage = 'Error: AVG2WK: No Parent AverageFuelPrice found for date range: ' + CONVERT(VARCHAR(14), @TestDateBOD, 101) + ' to ' + CONVERT(VARCHAR(14), @TestDateEOD, 101) 					
   END 
END


IF @aff_Formula = 'AVG4WK'
BEGIN
   SET @TestDateBOD = DATEADD(ww, -4, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00')
   SET @TestDateEOD = DATEADD(ww, -1, CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 23:59:59')
	 
   SELECT @New_AFP = AVG(afp_price) 
     FROM averagefuelprice 
    WHERE afp_tableid = @afp_tableid AND
          afp_date >= @TestDateBOD AND afp_date <= @TestDateEOD AND
          ISNULL(afp_IsFormula, 0) = 0
					
   IF @New_AFP IS NULL
   BEGIN
      SET @specificMessage ='Error: AVG4WK: No Parent AverageFuelPrice found for date range: ' + CONVERT(VARCHAR(14), @TestDateBOD, 101) + ' to ' + CONVERT(VARCHAR(14), @TestDateEOD, 101) 					
   END							
END
	
IF @aff_Formula = 'PREWK'
BEGIN	
   SET @TestDateBOD = CONVERT(VARCHAR(10), @PREV_WEEK_ParentDate, 101) + ' 00:00:00'

   -- dayofweek - if applicable - is already considered.
   SELECT @New_AFP = afp_price
     FROM averagefuelprice 
    WHERE afp_tableid = @afp_tableid AND
          CAST(CONVERT(VARCHAR(10), afp_date, 101) + ' 00:00:00' AS DATETime) = CAST(@TestDateBOD AS DATETIME) AND
          ISNULL(afp_IsFormula, 0) = 0

   IF @New_AFP IS NULL
   BEGIN
      SET @specificMessage = 'Error: PREWK: No Parent AverageFuelPrice found for Previous Week Date = ' + @TestDateBOD + '. '				
   END 	
END

IF @aff_Formula = 'CURWK'
BEGIN					
   SET @TestDateBOD = CONVERT(VARCHAR(10), @maxParentDate, 101) + ' 00:00:00'
				
   SELECT @New_AFP = afp_price
     FROM averagefuelprice 
    WHERE afp_tableid = @afp_tableid AND
          CAST(CONVERT(VARCHAR(10), afp_date, 101) + ' 00:00:00' AS DATETime) = CAST(@TestDateBOD AS DATETIME) AND
          ISNULL(afp_IsFormula, 0) = 0
						
   IF @New_AFP IS NULL
   BEGIN
      SET @specificMessage = 'Error: PREWK: No Parent AverageFuelPrice found for Previous Week Date = ' + @TestDateBOD + '. '
   END	
END	
	
IF @New_AFP IS NULL 
BEGIN	
   IF LEN(ISNULL(@specificMessage,'')) <=0 
   BEGIN
      SET @specificMessage = 'Error: could not calculate formula for ' + @new_description + '. '	
      SET @ps_returnmsg = @specificMessage
   END
   ELSE
   BEGIN
      SET @ps_returnmsg = 'Error: Formula ' + @new_description +  ' not created due to: ' + RTrim(LTrim(@specificMessage))
   END
		
   SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))
   RETURN
END

-- new row timestamp (New Table value Effective Date)

IF @aff_CycleDay IS NOT NULL 
BEGIN
   SELECT @daycode = code 
     FROM labelfile 
    WHERE labeldefinition = 'affCycleDay' AND
          abbr = @aff_CycleDay

   SET @todaydaycode = DATEPART(dw, @BeginWeekTHIS)
   SET @daysaddnbr = (@daycode - @todaydaycode) 	
   SET @NewFormulaEffectiveDate = DATEADD(dd, @daysaddnbr, @BeginWeekTHIS)
   SET @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'
END

IF @aff_CycleDay IS NULL 
BEGIN
   IF @aff_Interval = 'MNTH'
   BEGIN
      -- concerned only with aff_effective_day1.
      SET @todaydaycode = DATEPART(dd, @process_date) 
      SET @NewFormulaEffectiveDate = DATEADD( dd, -(@todaydaycode -1 ), @process_date)		
      SET @NewFormulaEffectiveDate = DATEADD( dd, (@aff_effective_day1 - 1), @NewFormulaEffectiveDate)
      SET @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'			
   END
   ELSE
   BEGIN	
      -- we have both aff_effective_day1 & aff_effective_day2 / choose which one to use.
      SET @chosenDate = @aff_effective_day1
      IF DATEPART(dd, @process_date) >= @aff_effective_day2 
      BEGIN				
         SET @chosenDate = @aff_effective_day2			
      END	
      
      SET @todaydaycode = DATEPART(dd, @process_date) 
      SET @NewFormulaEffectiveDate = DATEADD(dd, -(@todaydaycode -1 ), @process_date)
      SET @NewFormulaEffectiveDate = DATEADD(dd, (@chosenDate - 1), @NewFormulaEffectiveDate)
      SET @NewFormulaEffectiveDate = CONVERT(VARCHAR(10), @NewFormulaEffectiveDate, 101) + ' 00:00:00'				
   END	
END

SELECT @formulacount = COUNT(afp_tableid) 
  FROM averagefuelprice 
 WHERE afp_tableid = @aff_formula_tableid AND										
       ISNULL(afp_IsFormula, 0) = 0 AND
       CAST(@NewFormulaEffectiveDate AS DATETime) = CAST(CONVERT(VARCHAR(10), afp_date, 101) + ' 00:00:00' AS DATETIME)
IF @formulacount > 0 
BEGIN	
   SELECT @maxdatefortableid = MAX(afp_date)
     FROM averagefuelprice 
    WHERE afp_tableid = @aff_formula_tableid AND											
          ISNULL(afp_IsFormula, 0) = 0 AND
          CAST(@NewFormulaEffectiveDate AS DATETime) = cast(CONVERT(VARCHAR(10), afp_date, 101) + ' 00:00:00' AS DATETIME)

   SELECT @maxseconds = DATEPART(ss, @maxdatefortableid)
     FROM averagefuelprice 
    WHERE afp_tableid = @aff_formula_tableid AND
          ISNULL(afp_IsFormula, 0) = 0

   SET @maxseconds = @maxseconds + 10			
   SET @maxdatefortableid = DATEADD(ss, @maxseconds, @maxdatefortableid) 
END
ELSE
BEGIN	
   SET @maxdatefortableid = @NewFormulaEffectiveDate
END

INSERT INTO averagefuelprice (afp_tableid, afp_date, afp_description, afp_price,  afp_IsFormula, rowsec_rsrv_id, afp_revtype1)
                      VALUES (@aff_formula_tableid, @maxdatefortableid, @new_description, @New_AFP, 1, @rowsec_rsrv_id, @afp_revtype1)

SET @ps_returnmsg = 'Formula ' + @new_description + ' successfully created in the Average Fuel Price Table.'
SET @ps_returnmsg = LTRIM(RTRIM(@ps_returnmsg))



RETURN
GO
GRANT EXECUTE ON  [dbo].[createavgfuelformula_withdate_sp] TO [public]
GO
