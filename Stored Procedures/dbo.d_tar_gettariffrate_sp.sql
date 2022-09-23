SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Dpete 10/5/99 add tar_number to where clause of final select
-- insurance against the orphan tariffrate with trc_number_row = 0
-- and trc_number_col of zero
-- DPETE PTS13824 one dimensional table rates no longer pulling.  Need outer join to new table #temp_rate to @tariffcolumn and @tariffrow
-- LOR PTS# 13838 outer joint doesn't help, changed it to the conditional select for #temp_rate table
-- DPETE PTS16747 1/6/2 when 2 dimensional table with row or column range value is actually zero this proc thinks it is a one dimensional
--          table and returned all rows of the other dimension even if they do not match
/* PTS 32614 - DJM - Added Activedate to a rate table to allow users to indicate a date on which a 
	table rate should BEGIN to be active
*/
-- 16-MAY-2006 SWJ - PTS 32593 - Modified multimatch CASE statements to look for a string with semi-colons surrounding it, not just ending it
-- Mar 12,2008 PTS40752 DPETE for Lbeck PTS 40752 recode Pauls Hauling
-- 
-- DPETE pTS44260 for billing rates only if tar_zerorateisnorate is set to Y ignore rates if zero
-- PTS33529  12/30/2008 JSwindell RECODE.  1-9-2009:  Add GI setting condition for tariff history.
 -- DPETE PTS 46570 old outer joins replaced
 -- DPETE 53794 New requiremetn to pick the highest rate in the table if any of the matches match a |^ separated string of match values
 --     used for new row or col PREMDA premium day where a date on a trip might meet more than one criteria ( Saturday, Holiday)
 --     Note such bases cannot use the multimatch feature

--PTS71581 MBR 10/14/13 Bumped RowMatchValue and ColMatchValue to VARCHAR(255)
CREATE PROC [dbo].[d_tar_gettariffrate_sp]
		@TarNum int , 
		@RowMatchValue varchar(255) , 
		@RowRangeValue money , 
		@ColMatchValue varchar(255) , 
		@ColRangeValue money,
		@dimensions tinyint,
		@order_first_stop_arrivaldate datetime -- PTS 25122 -- BL
AS 
/* add anything to the arguments and change procs LTLBestMethod01 and d_GetTPDMaxrate */
set nocount on

declare @value table (tempvalue int)
DECLARE @RowNum int , @RowSeq int , @RowVal money , @valid_count int,
		@ColNum int , @ColSeq int , @ColVal money,	
		@rowtbl int,  @coltbl int  --, @dimention int
DECLARE @tarzerorateisnorate char(1)
declare @tariffrow  table (trc_number int, 
		trc_sequence int , 
		trc_matchvalue varchar(255), 
		trc_rangevalue money,
		trc_rateasflat char(1)) 
declare @tariffcolumn  table (trc_number int, 
		trc_sequence int , 
		trc_matchvalue varchar(255), 
		trc_rangevalue money,
		trc_rateasflat char(1))
DECLARE  @temp_rate table(
		tar_number int not null,
		tra_rate money null,
		trc_number_row int null,
		trc_number_col int null,
        tra_rateasflat char(1) null,
        tra_minqty char(1) null, 
        tra_minrate money null,
			-- PTS33529 RECODE <<start>>
--		tra_minqty_kag money null,
		tra_mincharge money null,
		tra_billmiles money null,
		tra_paymiles money null,
		tra_standardhours money null
			-- PTS33529 RECODE <<end>>
		) 

-- BEGIN PTS 55666 SPN
declare @gi_pick_rate_when_multiple_rate_found VARCHAR(7)
-- END PTS 55666 SPN

declare @li_cellhistory int
select @li_cellhistory = 0
if exists (select * from generalinfo where gi_name = 'Tar_Show_Cell_History' and gi_string1 = 'Y') -- new gi setting
select @li_cellhistory = 1

SELECT @gi_pick_rate_when_multiple_rate_found = UPPER(LTRIM(RTRIM(gi_string1))) from generalinfo where gi_name = 'BillingTableRateHighestLowest'
SELECT @gi_pick_rate_when_multiple_rate_found = IsNull(@gi_pick_rate_when_multiple_rate_found,'HIGHEST')

/* only tariffheader has this column at this time */
select	@tarzerorateisnorate  = tar_zerorateisnorate
from	tariffheader
where	tar_number = @TarNum 
select  @tarzerorateisnorate = isnull(@tarzerorateisnorate,'N')

SELECT @RowNum = 0, @RowSeq = 0 , @RowVal = 0 
SELECT @ColNum = 0, @ColSeq = 0 , @ColVal = 0 

-- PTS 23617 - DJM - Verify that the Column and Row match values are not null.
select @ColMatchValue = IsNull(@ColMatchValue, 'UNK')
select @RowMatchValue = IsNull(@RowMatchValue, 'UNK')

-- PTS 24131 - RJE - Verify that the Column and Row range values are not null
select @ColRangeValue = IsNull(@ColRangeValue, 0.0000)
select @RowRangeValue = IsNull(@RowRangeValue, 0.0000)



/*
-- LOR PTS# 14109
If ((@RowMatchValue = 'UNKNOWN' or @RowMatchValue = 'UNK') and @RowRangeValue = 0) or 
	((@ColMatchValue = 'UNKNOWN' or @ColMatchValue = 'UNK') and @ColRangeValue = 0)
	select @dimention = 1
Else
	select @dimention = 2
*/

If CHARINDEX('|^',@RowMatchValue) > 0 -- doing unit basis like PREMDA where you are passed multiple values (sep by |^) and must pick the highest rate
 INSERT into @tariffrow
 SELECT trc_number , 
		trc_sequence , 
		trc_matchvalue , 
		trc_rangevalue,
		trc_rateasflat 
 FROM 	tariffrowcolumn 
 WHERE 	( tar_number = @TarNum ) AND 
		(trc_rowcolumn = 'R' ) AND 
		(trc_rangevalue >= 0 ) AND
		charindex ('|^' + trc_matchvalue + '|^',@RowMatchValue) > 0  
ELSE
 INSERT into @tariffrow
 SELECT 	trc_number , 
		trc_sequence , 
		trc_matchvalue , 
		trc_rangevalue,
		trc_rateasflat  
 FROM 	tariffrowcolumn 
 WHERE 	( tar_number = @TarNum ) AND 
		(trc_rowcolumn = 'R' ) AND 
		(trc_rangevalue >= @RowRangeValue ) AND
		(@RowMatchValue = 
			case when Substring(trc_matchvalue, 1, 1) = char(176) then  
				--		case when @RowMatchValue not in ('') and charindex(@RowMatchValue + ';', trc_multimatch) > 0 then @RowMatchValue
				-- 16-MAY-2006 SWJ - PTS 32593 - Single character matches were returning the last character of a string.
				--		EX. @RowMatchValue = 'H', would find ROH. Adding the semicolon before the character searches for the single character only.
			case when @RowMatchValue not in ('') and charindex(';' + @RowMatchValue + ';', ';' + trc_multimatch) > 0 then @RowMatchValue
			else 'nomatch' end
			else trc_matchvalue end)

If CHARINDEX('|^',@ColMatchValue) > 0 -- doing unit basis like PREMDA where you are passed multiple values and must pick the hihhest rate
 INSERT into @tariffcolumn
 SELECT 	trc_number , 
		trc_sequence , 
		trc_matchvalue , 
		trc_rangevalue,
		trc_rateasflat 
 FROM 	tariffrowcolumn 
 WHERE 	( tar_number = @TarNum ) AND 
		(trc_rowcolumn = 'C' ) AND 
		(trc_rangevalue >= 0 ) AND
		charindex ('|^' + trc_matchvalue + '|^',@ColMatchValue) > 0  
ELSE
 INSERT into @tariffcolumn
 SELECT 	trc_number , 
		trc_sequence , 
		trc_matchvalue , 
		trc_rangevalue ,
		trc_rateasflat

 FROM 	tariffrowcolumn 
 WHERE 	( tar_number = @TarNum ) AND 
		( trc_rowcolumn = 'C' ) AND 
		( trc_rangevalue >= @ColRangeValue ) AND
		( @ColMatchValue  = 
			case when Substring(trc_matchvalue, 1, 1) = char(176) then 
				--		case when @ColMatchValue not in ('') and charindex(@ColMatchValue + ';', trc_multimatch) > 0 then @ColMatchValue
				-- 16-MAY-2006 SWJ - PTS 32593 - Single character matches were returning the last character of a string.
				--				EX. @RowMatchValue = 'H', would find ROH. Adding the semicolon before the character searches for the single character only.
			case when @ColMatchValue not in ('') and charindex(';' + @ColMatchValue + ';', ';' + trc_multimatch) > 0 then @ColMatchValue
			else 'nomatch' end
			else trc_matchvalue end) 


--============================ looks ok so far ============
--=========  structure of this proc ==========
--  a bunch of nested if statements
--	if dimension = 2
--		if hx
--		if not hx
--  if dimension = 1
--		if coltbl > 0
--			if hx
--			if not hx
--		if coltbl = 0
--			if hx
--			if not hx
--	final select
--============================

select @rowtbl = count(*) from @tariffrow
select @coltbl = count(*) from @tariffcolumn

-- PTS33529 RECODE <<start>> (BEGIN/END) add 2nd whole select + IF condition for tariffhistory
If (@rowtbl > 0 and @coltbl > 0) or @dimensions = 2 --or @dimention = 2	
BEGIN
		IF Exists (select * from tariffratehistory where tar_number = @TarNum) AND @li_cellhistory = 1
				Begin
					-- JD 33529 Where History records do exist
					insert into @temp_rate
					select	r.tar_number,
							h.tra_rate,
							r.trc_number_row,
							r.trc_number_col,
							-- 40752 (recode KMM PTS 20653
							CASE tra_rateasflat when 'N' then 'N' when 'Y' then 'Y' else 
								(CASE o.trc_rateasflat when 'Y' then 'Y' else
								(CASE c.trc_rateasflat when 'Y' then 'Y' else 'N' end ) end ) end as 'tra_rateasflat', 
							-- END PTS 20653									
							 tra_minqty, 
							 tra_minrate, 
							-- END PTS 40752
							--r.tra_minqty_kag,
							r.tra_mincharge,
							r.tra_billmiles,
							r.tra_paymiles,
							r.tra_standardhours
/*
					from	tariffrate r, @tariffrow  o, @tariffcolumn c, tariffratehistory h
					where	r.tar_number = @TarNum and
							r.trc_number_row = o.trc_number and 
							r.trc_number_col = c.trc_number and
							(tra_apply = 'Y' or  tra_apply is null) and -- JD 33529 Added the following where clause
							r.tar_number *= h.tar_number and 
							r.trc_number_row *= h.trc_number_row and r.trc_number_col *= h.trc_number_col and
							@order_first_stop_arrivaldate between h.trh_fromdate and h.trh_todate
											-- END JD 33529 Added the following where clause
*/
					from	tariffrate r
                            join  @tariffrow  o on r.trc_number_row = o.trc_number
                            join  @tariffcolumn c on r.trc_number_col = c.trc_number
                            left outer join tariffratehistory h on r.tar_number = h.tar_number
                               and r.trc_number_row = h.trc_number_row 
                               and r.trc_number_col = h.trc_number_col
					where	r.tar_number = @TarNum and
							(tra_apply = 'Y' or  tra_apply is null) and -- JD 33529 Added the following where clause
							@order_first_stop_arrivaldate between h.trh_fromdate and h.trh_todate
											-- END JD 33529 Added the following where clause
					
				end -- end if hx
			ELSE
				Begin
					-- JD 33529 original where no history records exist
					insert into @temp_rate
					select	r.tar_number,
							tra_rate,
							trc_number_row,
							trc_number_col,
							 -- 40752 (recode KMM PTS 20653
							 CASE tra_rateasflat when 'N' then 'N' when 'Y' then 'Y' else 
								(CASE o.trc_rateasflat when 'Y' then 'Y' else
								(CASE c.trc_rateasflat when 'Y' then 'Y' else 'N' end ) end ) end as 'tra_rateasflat', 
							-- END PTS 20653									
							 tra_minqty, 
							 tra_minrate, 
							-- END PTS 40752
							-- PTS33529 RECODE <<start>>
							--r.tra_minqty_kag,
							r.tra_mincharge,
							r.tra_billmiles,
							r.tra_paymiles,
							r.tra_standardhours
							-- PTS33529 RECODE <<end>>

					from tariffrate r, @tariffrow o, @tariffcolumn c				 
					where r.tar_number = @TarNum and
						r.trc_number_row = o.trc_number and 
						r.trc_number_col = c.trc_number and
						(tra_apply = 'Y' or  tra_apply is null) and
							-- PTS 25122 -- BL (start)
							--		(tra_retired >= getdate() or tra_retired is null) and 
						(tra_retired >= @order_first_stop_arrivaldate or tra_retired is null) and
							-- PTS 25122 -- BL (end)				
						(tra_activedate <= @order_first_stop_arrivaldate or tra_activedate is null)	
									
				End  -- end if NO hx
END
-- PTS33529 RECODE <<END>> (BEGIN/END) add 2nd whole select + IF condition for tariffhistory
 
--============================ looks ok so far ============
Else
BEGIN
	--------------------- IF col tbl GREATER than zero
	If @rowtbl = 0 and @coltbl > 0 and @dimensions = 1 --and @dimention = 1
		BEGIN
			If exists (select * from tariffratehistory where tar_number = @TarNum) AND @li_cellhistory = 1
			-- PTS33529 RECODE <<start>> (BEGIN/END) add 2nd whole select + IF condition for tariffhistory
					Begin
						insert into @temp_rate
						select	r.tar_number,
								h.tra_rate,
								r.trc_number_row,
								r.trc_number_col,
								 -- 40752 (recode KMM PTS 20653
								 CASE tra_rateasflat 
									when 'N' then 'N' 
									when 'Y' then 'Y' 
									else (CASE c.trc_rateasflat when 'Y' then 'Y' else 'N' end ) 
									end as 'tra_rateasflat', 
								-- END PTS 20653
								tra_minqty, 
								tra_minrate,
								--r.tra_minqty_kag,
								r.tra_mincharge,
								r.tra_billmiles,
								r.tra_paymiles,
								r.tra_standardhours
/*
                        from	tariffrate r, @tariffcolumn c, tariffratehistory h
						where	r.tar_number = @TarNum and
								(tra_apply = 'Y' or  tra_apply is null) and
								r.trc_number_col = c.trc_number and -- JD 33529 Added the following where clause
								r.tar_number *= h.tar_number and 
								r.trc_number_row *= h.trc_number_row and r.trc_number_col *= h.trc_number_col and
								@order_first_stop_arrivaldate between h.trh_fromdate and h.trh_todate
												--END  JD 33529 Added the following where clause	
*/
						from	tariffrate r
                                join @tariffcolumn c on r.trc_number_col = c.trc_number
                                left outer join  tariffratehistory h on r.tar_number = h.tar_number
                                    and r.trc_number_row = h.trc_number_row 
                                    and r.trc_number_col = h.trc_number_col 
						where	r.tar_number = @TarNum and
								(tra_apply = 'Y' or  tra_apply is null) and
								@order_first_stop_arrivaldate between h.trh_fromdate and h.trh_todate
												--END  JD 33529 Added the following where clause
									
					End
					Else
					Begin
						-- JD 33529 original where no history records exist
						insert into @temp_rate
						select	r.tar_number,
								tra_rate,
								0 trc_number_row,
								trc_number_col,
						 -- 40752 (recode KMM PTS 20653
						 CASE tra_rateasflat 
							when 'N' then 'N' 
							when 'Y' then 'Y' 
							else (CASE c.trc_rateasflat when 'Y' then 'Y' else 'N' end ) 
							end as 'tra_rateasflat', 
							-- END PTS 20653										
							tra_minqty, 
							tra_minrate, 
							  -- END PTS 40752
							-- PTS33529 RECODE <<start>>
							--r.tra_minqty_kag,
							r.tra_mincharge,
							r.tra_billmiles,
							r.tra_paymiles,
							r.tra_standardhours
							-- PTS33529 RECODE <<end>>
						from tariffrate r, @tariffcolumn c
						where r.tar_number = @TarNum and
							(tra_apply = 'Y' or  tra_apply is null) and
									-- PTS 25122 -- BL (start)
									--			(tra_retired >= getdate() or tra_retired is null) and 
												(tra_retired >= @order_first_stop_arrivaldate or tra_retired is null) and 
									-- PTS 25122 -- BL (end)
							r.trc_number_col = c.trc_number
							and (tra_activedate <= @order_first_stop_arrivaldate or tra_activedate is null)
						
					End -- end history or no history
		END-- need this other end...

		--------------------- col tbl GREATER than zero			
			
Else	
	BEGIN	
				If @rowtbl > 0 and @coltbl = 0 and @dimensions = 1 --@dimention = 1
					BEGIN
						If exists (select * from tariffratehistory where tar_number = @TarNum) AND @li_cellhistory = 1
								Begin
										insert into @temp_rate
										select	r.tar_number,
												h.tra_rate,
												r.trc_number_row,
												r.trc_number_col,
												CASE tra_rateasflat 
													when 'N' then 'N' 
													when 'Y' then 'Y' 
													else (CASE o.trc_rateasflat when 'Y' then 'Y' else 'N' end ) 
													end as 'tra_rateasflat', 
													 -- END PTS 20653														
												tra_minqty, 
												tra_minrate, 
													 -- END PTS 40752
												--r.tra_minqty_kag,
												r.tra_mincharge,
												r.tra_billmiles,
												r.tra_paymiles,
												r.tra_standardhours
/*
										from	tariffrate r, @tariffrow  o,tariffratehistory h
										where	r.tar_number = @TarNum and
												r.trc_number_row = o.trc_number and 
												(tra_apply = 'Y' or  tra_apply is null) and -- JD 33529 Added the following where clause
												r.tar_number *= h.tar_number and 
												r.trc_number_row *= h.trc_number_row and r.trc_number_col *= h.trc_number_col and
												@order_first_stop_arrivaldate between h.trh_fromdate and h.trh_todate
															--END  JD 33529 Added the following where clause
*/
										from	tariffrate r
                                        join    @tariffrow  o on r.trc_number_row = o.trc_number
                                        left outer join tariffratehistory h on r.tar_number = h.tar_number  
												           and r.trc_number_row  = h.trc_number_row 
                                                           and r.trc_number_col = h.trc_number_col 
										where	r.tar_number = @TarNum and
												(tra_apply = 'Y' or  tra_apply is null) and -- JD 33529 Added the following where clause
												@order_first_stop_arrivaldate between h.trh_fromdate and h.trh_todate
										
								End
								Else
								Begin 
										insert into @temp_rate
										select	r.tar_number,
												tra_rate,
												trc_number_row,
												0 trc_number_col,
													-- 40752 (recode KMM PTS 20653
												CASE tra_rateasflat 
													when 'N' then 'N' 
													when 'Y' then 'Y' 
													else (CASE o.trc_rateasflat when 'Y' then 'Y' else 'N' end ) 
													end as 'tra_rateasflat', 
													-- END PTS 20653														
												tra_minqty, 
												tra_minrate, 
											  -- END PTS 40752
											-- PTS33529 RECODE <<start>>
											--r.tra_minqty_kag,
											r.tra_mincharge,
											r.tra_billmiles,
											r.tra_paymiles,
											r.tra_standardhours
											-- PTS33529 RECODE <<end>>
										from tariffrate r, @tariffrow o
										where	r.tar_number = @TarNum and
												r.trc_number_row = o.trc_number  and 
												(tra_apply = 'Y' or  tra_apply is null) and
													-- PTS 25122 -- BL (start)
													--			(tra_retired >= getdate() or tra_retired is null)
												(tra_retired >= @order_first_stop_arrivaldate or tra_retired is null)
													-- PTS 25122 -- BL (end)
											and (tra_activedate <= @order_first_stop_arrivaldate or tra_activedate is null)
																			
									
								End
						END  -- PTS33529 RECODE <<end>> (BEGIN/END) IF condition for tariffhistory
		END  	-- end of col tbl condition
END -- end of @dimensions = 1


select @valid_count = count(*) from @temp_rate

If @RowRangeValue <> 0 and @rowtbl > 0 select @valid_count = 1
If @ColRangeValue <> 0 and @coltbl > 0 select @valid_count = 1

IF CHARINDEX('|^',@RowMatchValue) = 0 and CHARINDEX('|^',@ColMatchValue) = 0
 BEGIN
	SELECT	@RowVal = min ( trc_rangevalue ) 
	FROM	@tariffrow r, @temp_rate t
	where	r.trc_number = t.trc_number_row 

	SELECT	@RowNum = min ( trc_number ) , 
			@RowSeq = min ( trc_sequence ) 
	FROM	@tariffrow r, @temp_rate t 
	WHERE	( trc_rangevalue = @RowVal ) and 
			r.trc_number = t.trc_number_row

	SELECT	@ColVal = min ( trc_rangevalue ) 
	FROM	@tariffcolumn c, @temp_rate t 
	where	c.trc_number = t.trc_number_col

	SELECT	@ColNum = min ( trc_number ) , 
			@ColSeq = min ( trc_sequence ) 
	FROM	@tariffcolumn  c, @temp_rate t
	WHERE	( trc_rangevalue = @ColVal ) and 
			c.trc_number = t.trc_number_col
 END
IF CHARINDEX('|^',@RowMatchValue) > 0 
 BEGIN
    
	-- BEGIN PTS 55666 SPN
	--Insert into @value
	--select top 1 trc_number
	--from @tariffrow r join @temp_rate t on r.trc_number = t.trc_number_row
	--order by t.tra_rate desc
	IF @gi_pick_rate_when_multiple_rate_found = 'LOWEST'
		Insert into @value
		select top 1 trc_number
		from @tariffrow r join @temp_rate t on r.trc_number = t.trc_number_row
		order by t.tra_rate asc
	ELSE
		Insert into @value
		select top 1 trc_number
		from @tariffrow r join @temp_rate t on r.trc_number = t.trc_number_row
		order by t.tra_rate desc
	-- END PTS 55666 SPN
	
	select @RowNum  = tempvalue
	from @value	

	SELECT	@ColVal = min ( trc_rangevalue ) 
	FROM	@tariffcolumn c, @temp_rate t 
	where	c.trc_number = t.trc_number_col

	SELECT	@ColNum = min ( trc_number ) , 
			@ColSeq = min ( trc_sequence ) 
	FROM	@tariffcolumn  c, @temp_rate t
	WHERE	( trc_rangevalue = @ColVal ) and 
			c.trc_number = t.trc_number_col				
	
 END
 IF CHARINDEX('|^',@ColMatchValue) > 0 
 BEGIN

   -- BEGIN PTS 55666 SPN
   IF IsNull(@RowNum,0) = 0
   BEGIN
      SELECT   @RowVal = min ( trc_rangevalue ) 
      FROM  @tariffrow r, @temp_rate t
      where r.trc_number = t.trc_number_row 

      SELECT   @RowNum = min ( trc_number ) , 
            @RowSeq = min ( trc_sequence ) 
      FROM  @tariffrow r, @temp_rate t 
      WHERE ( trc_rangevalue = @RowVal ) and 
            r.trc_number = t.trc_number_row
   END
   ELSE
   BEGIN
      SELECT @RowNum = @RowNum
           , @RowSeq = min(trc_sequence) 
           , @RowVal = min(trc_rangevalue) 
        FROM @tariffrow
       WHERE trc_number = @RowNum
   END
   -- END PTS 55666 SPN

	-- BEGIN PTS 55666 SPN
	--Insert into @value
	--select top 1 trc_number
	--from @tariffcolumn c join @temp_rate t on c.trc_number = t.trc_number_row
	--order by t.tra_rate desc
	IF @gi_pick_rate_when_multiple_rate_found = 'LOWEST'
		Insert into @value
		select top 1 trc_number
		from @tariffcolumn c join @temp_rate t on c.trc_number = t.trc_number_col
		order by t.tra_rate asc
	ELSE
		Insert into @value
		select top 1 trc_number
		from @tariffcolumn c join @temp_rate t on c.trc_number = t.trc_number_col
		order by t.tra_rate desc
	-- END PTS 55666 SPN
	
	select @ColNum  = tempvalue
	from @value	
 END

SELECT	@RowNum = IsNull(@RowNum,0), @RowSeq = IsNull(@RowSeq,0), @RowVal = IsNull(@RowVal,0) 
SELECT	@ColNum = IsNull(@ColNum,0), @ColSeq = IsNull(@ColSeq,0), @ColVal = IsNull(@ColVal,0) 
/* Comment added for PTS 44518, change the output of this proc and you need to adjust 
   d_GetTPDMAXrate_sp  which calls this proc */

if @tarzerorateisnorate = 'Y'
  SELECT	tra_rate , 
			@RowNum , 
			@ColNum , 
			@RowSeq , 
			@ColSeq , 
			@RowVal , 
			@ColVal, 
			@valid_count,
			tra_rateasflat, 
			tra_minqty, 
			tra_minrate, 
			-- PTS33529 RECODE <<start>>
			--tra_minqty_kag,
			tra_mincharge,
			tra_billmiles,
			tra_paymiles,
			tra_standardhours
			-- PTS33529 RECODE <<end>>
  FROM		@temp_rate
  WHERE		( trc_number_row = @RowNum ) AND 
			( trc_number_col = @ColNum )
			and isnull(tra_rate,0)  <> 0
Else 
  SELECT	tra_rate , 
			@RowNum , 
			@ColNum , 
			@RowSeq , 
			@ColSeq , 
			@RowVal , 
			@ColVal, 
			@valid_count,
			tra_rateasflat, 
			tra_minqty, 
			tra_minrate,
			-- PTS33529 RECODE <<start>>
			--tra_minqty_kag,
			tra_mincharge,
			tra_billmiles,
			tra_paymiles,
			tra_standardhours
			-- PTS33529 RECODE <<end>> 
  FROM		@temp_rate
  WHERE		( trc_number_row = @RowNum ) AND 
			( trc_number_col = @ColNum )
 
/* add anything to the return set and change procs LTLBestMethod01 and d_GetTPDMaxrate */
GO
GRANT EXECUTE ON  [dbo].[d_tar_gettariffrate_sp] TO [public]
GO
