SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_tar_gettariffrate_stl_sp] 
		@TarNum int , 
		@RowMatchValue varchar(10) , 
		@RowRangeValue money , 
		@ColMatchValue varchar(10) , 
		@ColRangeValue money
--BEGIN PTS 51901 SPN
    , @order_first_stop_arrivaldate datetime
--END PTS 51901 SPN
AS 
/*
-- dpete 10/9/99 add tar_number to where clause of final retrieve
-- avoids retriving orphan record with zero row and zero col numbers
DPETE PTS40257 1/21/08 (Recode Pauls Hauling 23795)
SPN PTS 60123 11/15/2011 if tar_zerorateisnorate is set to Y ignore zero rates
PTS 70747 Change temp tables to table variables to eliminate chronic recompilation (@tariffrow & @tariffcolumn)
*/
DECLARE @RowNum int , @RowSeq int , @RowVal money , 
		@ColNum int , @ColSeq int , @ColVal money ,
		@rowflat char(1), @colflat char(1) 

--BEGIN PTS 60123 SPN
DECLARE @tar_ZeroRateIsNoRate CHAR(1)
--END PTS 60123 SPN

--BEGIN PTS 51901 SPN
DECLARE @temp_rate TABLE
( tar_number         INT      NOT NULL
, tra_rate           MONEY    NULL
, trc_number_row     INT      NULL
, trc_number_col     INT      NULL
, tra_rateasflat     CHAR(1)  NULL
, tra_minqty         CHAR(1)  NULL
, tra_minrate        MONEY    NULL
, tra_standardhours  MONEY    NULL
, tra_apply          CHAR(1)  NULL
, tra_retired        DATETIME
, tra_activedate     DATETIME
)
--END PTS 51901 SPN


SELECT @RowNum = 0, @RowSeq = 0 , @RowVal = 0 
SELECT @ColNum = 0, @ColSeq = 0 , @ColVal = 0 

--BEGIN PTS 60123 SPN
SELECT @tar_ZeroRateIsNoRate = tar_zerorateisnorate
  FROM tariffheaderstl
 WHERE tar_number = @TarNum
SELECT @tar_ZeroRateIsNoRate = IsNull(@tar_ZeroRateIsNoRate,'N')
--END PTS 60123 SPN

declare @tariffrow table	(
							trc_number int, 
							trc_sequence int, 
							trc_matchvalue varchar(10), 
							trc_rangevalue money,
							trc_rateasflat char(1)
							)

declare @tariffcolumn table	(
							trc_number int, 
							trc_sequence int, 
							trc_matchvalue varchar(10), 
							trc_rangevalue money,
							trc_rateasflat char(1)
							)

insert @tariffrow
SELECT trc_number , 
		trc_sequence , 
		trc_matchvalue , 
		trc_rangevalue,
        trc_rateasflat 
	FROM tariffrowcolumnstl 
	WHERE ( tar_number = @TarNum ) AND 
			( trc_rowcolumn = 'R' ) AND  
			( trc_rangevalue >= @RowRangeValue )  AND  
			/*PTS 24113 CGK 9/14/2004*/
			(@RowMatchValue = 
				case when Substring(trc_matchvalue, 1, 1) = char(176) then  
					case when @RowMatchValue not in ('') and charindex(@RowMatchValue + ';', trc_multimatch) > 0 then @RowMatchValue
						else 'nomatch'
					end
				     else trc_matchvalue  
				end)

insert @tariffcolumn
SELECT trc_number , 
		trc_sequence , 
		trc_matchvalue , 
		trc_rangevalue,
        trc_rateasflat   --40752
	FROM tariffrowcolumnstl 
	WHERE ( tar_number = @TarNum ) AND 
			( trc_rowcolumn = 'C' ) AND 
			( trc_rangevalue >= @ColRangeValue )  AND
			/*PTS 24113 CGK 9/14/2004*/
			( @ColMatchValue  = 
				case when Substring(trc_matchvalue, 1, 1) = char(176) then 
					case when @ColMatchValue not in ('') and charindex(@ColMatchValue + ';', trc_multimatch) > 0 then @ColMatchValue
						else 'nomatch'
					end
				     else trc_matchvalue  
				end) 

--BEGIN PTS 56290 SPN
BEGIN
   If EXISTS (SELECT * FROM @tariffrow) AND EXISTS (SELECT * FROM @tariffcolumn)
      --BEGIN PTS 51901 SPN
      INSERT INTO @temp_rate
      ( tar_number
      , tra_rate
      , trc_number_row
      , trc_number_col
      , tra_rateasflat
      , tra_minqty
      , tra_minrate
      , tra_standardhours
      , tra_apply
      , tra_retired
      , tra_activedate
      )
      SELECT trs.tar_number
           , trs.tra_rate
           , trs.trc_number_row
           , trs.trc_number_col
           , CASE trs.tra_rateasflat
           WHEN 'N' THEN 'N'
           WHEN 'Y' THEN 'Y'
           ELSE (CASE r.trc_rateasflat
               WHEN 'Y' THEN 'Y'
               ELSE (CASE c.trc_rateasflat WHEN 'Y' THEN 'Y' ELSE 'N' END)
            END
                )
             END              AS tra_rateasflat
           , trs.tra_minqty
           , trs.tra_minrate
           , trs.tra_standardhours
           , trs.tra_apply
           , trs.tra_retired
           , trs.tra_activedate
        FROM tariffratestl trs
        JOIN @tariffrow r ON trs.trc_number_row = r.trc_number
        JOIN @tariffcolumn c ON trs.trc_number_col = c.trc_number
       WHERE trs.tar_number = @TarNum
         AND (trs.tra_apply = 'Y' OR trs.tra_apply IS NULL)
         AND (trs.tra_retired >= @order_first_stop_arrivaldate OR trs.tra_retired IS NULL)
         AND (trs.tra_activedate <= @order_first_stop_arrivaldate OR trs.tra_activedate IS NULL)
      --END PTS 51901 SPN
   ELSE If EXISTS (SELECT * FROM @tariffrow) AND NOT EXISTS (SELECT * FROM @tariffcolumn)
      INSERT INTO @temp_rate
      ( tar_number
      , tra_rate
      , trc_number_row
      , trc_number_col
      , tra_rateasflat
      , tra_minqty
      , tra_minrate
      , tra_standardhours
      , tra_apply
      , tra_retired
      , tra_activedate
      )
      SELECT trs.tar_number
           , trs.tra_rate
           , trs.trc_number_row
           , trs.trc_number_col
           , CASE trs.tra_rateasflat
               WHEN 'N' THEN 'N'
               WHEN 'Y' THEN 'Y'
               ELSE (CASE r.trc_rateasflat WHEN 'Y' THEN 'Y' ELSE 'N' END)
             END              AS tra_rateasflat
           , trs.tra_minqty
           , trs.tra_minrate
           , trs.tra_standardhours
           , trs.tra_apply
           , trs.tra_retired
           , trs.tra_activedate
        FROM tariffratestl trs
        JOIN @tariffrow r ON trs.trc_number_row = r.trc_number
       WHERE trs.tar_number = @TarNum
         AND (trs.tra_apply = 'Y' OR trs.tra_apply IS NULL)
         AND (trs.tra_retired >= @order_first_stop_arrivaldate OR trs.tra_retired IS NULL)
         AND (trs.tra_activedate <= @order_first_stop_arrivaldate OR trs.tra_activedate IS NULL)
   ELSE If NOT EXISTS (SELECT * FROM @tariffrow) AND EXISTS (SELECT * FROM @tariffcolumn)
      INSERT INTO @temp_rate
      ( tar_number
      , tra_rate
      , trc_number_row
      , trc_number_col
      , tra_rateasflat
      , tra_minqty
      , tra_minrate
      , tra_standardhours
      , tra_apply
      , tra_retired
      , tra_activedate
      )
      SELECT trs.tar_number
           , trs.tra_rate
           , trs.trc_number_row
           , trs.trc_number_col
           , CASE trs.tra_rateasflat
               WHEN 'N' THEN 'N'
               WHEN 'Y' THEN 'Y'
               ELSE (CASE c.trc_rateasflat WHEN 'Y' THEN 'Y' ELSE 'N' END)
             END              AS tra_rateasflat
           , trs.tra_minqty
           , trs.tra_minrate
           , trs.tra_standardhours
           , trs.tra_apply
           , trs.tra_retired
           , trs.tra_activedate
        FROM tariffratestl trs
        JOIN @tariffcolumn c ON trs.trc_number_col = c.trc_number
       WHERE trs.tar_number = @TarNum
         AND (trs.tra_apply = 'Y' OR trs.tra_apply IS NULL)
         AND (trs.tra_retired >= @order_first_stop_arrivaldate OR trs.tra_retired IS NULL)
         AND (trs.tra_activedate <= @order_first_stop_arrivaldate OR trs.tra_activedate IS NULL)
END
--END PTS 56290 SPN

--BEGIN PTS 51901 SPN
--SELECT @RowVal = min ( trc_rangevalue ) 
--	FROM @tariffrow 
SELECT @RowVal = min ( trc_rangevalue )
   FROM @tariffrow r
      , @temp_rate t
 WHERE r.trc_number = t.trc_number_row
--END PTS 51901 SPN

SELECT @RowNum = min ( trc_number ) , 
		@RowSeq = min ( trc_sequence ) 
	FROM @tariffrow 
	WHERE ( trc_rangevalue = @RowVal ) 
--BEGIN PTS 51901 SPN -- commented out as it is already added to the @temp_rate table
----40752
--select @rowflat = trc_rateasflat
--	FROM @tariffrow
--	WHERE	trc_number = @RowNum
--END PTS 51901 SPN

--BEGIN PTS 51901 SPN
--SELECT @ColVal = min ( trc_rangevalue ) 
--	FROM @tariffcolumn 
SELECT @ColVal = min ( trc_rangevalue )
  FROM @tariffcolumn c
     , @temp_rate t
 WHERE c.trc_number = t.trc_number_col
--END PTS 51901 SPN

SELECT @ColNum = min ( trc_number ) , 
		@ColSeq = min ( trc_sequence ) 
	FROM @tariffcolumn 
	WHERE ( trc_rangevalue = @ColVal ) 

--BEGIN PTS 51901 SPN -- commented out as it is already added to the @temp_rate table
----40752
--select @colflat = trc_rateasflat
--	FROM @tariffcolumn
--	WHERE	trc_number = @ColNum
--END PTS 51901 SPN

SELECT @RowNum = IsNull(@RowNum,0), @RowSeq = IsNull(@RowSeq,0), @RowVal = IsNull(@RowVal,0) 
SELECT @ColNum = IsNull(@ColNum,0), @ColSeq = IsNull(@ColSeq,0), @ColVal = IsNull(@ColVal,0) 

--BEGIN PTS 51901 SPN
--SELECT tra_rate , 
--		@RowNum , 
--		@ColNum , 
--		@RowSeq , 
--		@ColSeq , 
--		@RowVal , 
--		@ColVal ,
--		1, -- 40752 (recode valid count functionality does not exist for settlements hardcode to 1 24501 JD)
--		tra_standardhours, --40752 (recode 24501 JD)
--		(case tra_rateasflat when 'N' then 'N' when 'Y' then 'Y' else 
--
--			(case @rowflat when 'Y' then 'Y' else 
--			(case @colflat when 'Y' then 'Y' else 'N' end) end) end), -- 40752 (recode KMM 20653)
--        tra_minqty, -- 40752 (recode JET PTS 23795)
--        tra_minrate -- 40752 (recode JET PTS 23795 )
--	FROM tariffratestl 
--	WHERE ( tariffratestl.trc_number_row = @RowNum ) AND 
--			( tariffratestl.trc_number_col = @ColNum ) 
--		AND tariffratestl.tar_number = @TarNum
If @tar_ZeroRateIsNoRate = 'Y'
 Begin
   SELECT tra_rate	         AS tra_rate
     , @RowNum	            AS RowNum
     , @ColNum	            AS ColNum
     , @RowSeq	            AS RowSeq
     , @ColSeq	            AS ColSeq
     , @RowVal	            AS RowVal
     , @ColVal	            AS ColVal
     , 1                   AS valid_count
     , tra_standardhours   AS tra_standardhours
     , tra_rateasflat      AS tra_rateasflat
     , tra_minqty          AS tra_minqty
     , tra_minrate         AS tra_minrate
--     , tra_apply           AS tra_apply
--     , tra_retired         AS tra_retired
--     , tra_activedate      AS tra_activedate
  FROM @temp_rate
  WHERE trc_number_row = @RowNum
   AND trc_number_col = @ColNum
   ANd isnull(tra_rate,0)  <> 0
 End

ELSE
 Begin
   SELECT tra_rate	         AS tra_rate
     , @RowNum	            AS RowNum
     , @ColNum	            AS ColNum
     , @RowSeq	            AS RowSeq
     , @ColSeq	            AS ColSeq
     , @RowVal	            AS RowVal
     , @ColVal	            AS ColVal
     , 1                   AS valid_count
     , tra_standardhours   AS tra_standardhours
     , tra_rateasflat      AS tra_rateasflat
     , tra_minqty          AS tra_minqty
     , tra_minrate         AS tra_minrate
--     , tra_apply           AS tra_apply
--     , tra_retired         AS tra_retired
--     , tra_activedate      AS tra_activedate
  FROM @temp_rate
  WHERE trc_number_row = @RowNum
   AND trc_number_col = @ColNum
--END PTS 51901 SPN
 End

--select * from @tariffrow
--select * from @tariffcolumn

GO
GRANT EXECUTE ON  [dbo].[d_tar_gettariffrate_stl_sp] TO [public]
GO
