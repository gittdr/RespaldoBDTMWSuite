SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[Split_Pay_processing_rtn_offset_asset]  @mov_number int, @lgh_number int, 
@lgh_driver1 Varchar(8) output,
@lgh_tractor Varchar(8) output, 
@lgh_primary_trailer varchar(13) output, 
@lgh_carrier varchar(8) output
as
----

-------li_warning = SQLCA.of_create_offset_pay(ps_drv, ps_trc, ps_trl, ps_car, pl_ord, ps_payid)
Set Nocount ON 

/*	PTS 43875 JSwindell 10-13-2008 Created.
/**********************************************************************************************************************/
/*		If PU or DEL, return the associated LH segements driver id. 												  */	 
/**********************************************************************************************************************/
-- PTS 49420 11-17-2009 RE-WROTE this PROC.  Client now needs to have multiple, comma-delimited, values in Gi_string 1-4
--
*/


-- *************  Set Up  ***********************
Declare @SplitPay_Lgh_Type_to_use varchar(60)
Declare @segment_lgh_type varchar(6)

declare @SplitPay_codes varchar(200)	-- PTS 49420

declare @gi_string1_PU varchar(60)  -- is always the PU code						-- PTS 49420 
declare @gi_string2_LHP varchar(60) -- is the Line Haul that goes w/PU code			-- PTS 49420 
declare @gi_string3_LHD varchar(60) -- is the Line Haul that goes w/DEL code		-- PTS 49420 
declare @gi_string4_DEL varchar(60) -- is always the DEL code						-- PTS 49420 

------declare @gi_string1_PU varchar(6)  -- is always the PU code
------declare @gi_string2_LHP varchar(6) -- is the Line Haul that goes w/PU code
------declare @gi_string3_LHD varchar(6) -- is the Line Haul that goes w/DEL code
------declare @gi_string4_DEL varchar(6) -- is always the DEL code

declare @current_stp_mfh_sequence int
declare @next_prev_lgh_number int
declare @Legheader_records_rowcount int

SET @SplitPay_Lgh_Type_to_use = ( Select gi_string1   from generalinfo  where gi_name = 'SplitPay_Lgh_Type_to_use' ) 

IF ( @SplitPay_Lgh_Type_to_use is null)   OR LTrim(RTrim(@SplitPay_Lgh_Type_to_use)) = ''
BEGIN
	SET @lgh_driver1 = '-1'
	SET @lgh_tractor = '-1'
	SET @lgh_primary_trailer  = '-1'
	SET @lgh_carrier = '-1'
	RETURN
	-- we should NEVER get to this proc if these values are missing. But - just in case...
	-- If there's a problem - just return the empty string.
END 

------Create table #SplitPay_Lgh_Type_codes (gi_string varchar(60) )		-- PTS 49420 
Create table #Legheader_records (stp_number_start int, lgh_number int, lgh_type varchar(6), stp_mfh_sequence int, 
									lgh_driver1 varchar(8), lgh_tractor varchar(8), lgh_primary_trailer varchar(13), lgh_carrier varchar(8))

SET @gi_string1_PU = (SELECT gi_string1	from generalinfo where gi_name like 'SplitPay_Lgh_Type_codes' ) 
SET @gi_string2_LHP = ( select gi_string2 from generalinfo where gi_name like 'SplitPay_Lgh_Type_codes' ) 
SET @gi_string3_LHD = ( select Gi_string3 from generalinfo where gi_name like 'SplitPay_Lgh_Type_codes' ) 
SET @gi_string4_DEL = ( select gi_string4 from generalinfo where gi_name like 'SplitPay_Lgh_Type_codes' ) 

if ( @gi_string1_PU IS null or ltrim(RTRIM(@gi_string1_PU)) = '' ) 
	or ( @gi_string2_LHP IS null or ltrim(RTRIM(@gi_string2_LHP)) = '' )
	or ( @gi_string4_DEL IS null or ltrim(RTRIM(@gi_string4_DEL)) = '' )
BEGIN
		-- THESE SHOULD NOT BE EMPTY - SO, ERROR - SO, GET OUT.
		SET @lgh_driver1 = '-1'
		SET @lgh_tractor = '-1'
		SET @lgh_primary_trailer  = '-1'
		SET @lgh_carrier = '-1'
		RETURN 
END

-- GI-STRING3 IS OPTIONAL - IT CAN BE NULL, SO HANDLE IT. 
if @gi_string3_LHD IS null or ltrim(RTRIM(@gi_string3_LHD)) = ''
BEGIN
SET @gi_string3_LHD = @gi_string2_LHP
END

-- PTS 49420 
------Insert into #SplitPay_Lgh_Type_codes
------select @gi_string1_PU
------Insert into #SplitPay_Lgh_Type_codes
------select @gi_string2_LHP
------Insert into #SplitPay_Lgh_Type_codes
------select @gi_string3_LHD
------Insert into #SplitPay_Lgh_Type_codes
------select @gi_string4_DEL 

SET @SplitPay_codes = @gi_string1_PU + ', ' + @gi_string2_LHP + ', ' + @gi_string3_LHD + ', ' + @gi_string4_DEL 


IF @SplitPay_Lgh_Type_to_use = 'lghtype1'
BEGIN	
 	insert into #Legheader_records
	select stp_number_start, lgh_number, lgh_type1, null , lgh_driver1, lgh_tractor , lgh_primary_trailer, lgh_carrier
	from  legheader 
	where  mov_number = @mov_number
	and ( CHARINDEX(lgh_type1, @SplitPay_codes) > 0  ) 
	---------------and lgh_type1 in (select * from #SplitPay_Lgh_Type_codes)	-- PTS 49420 
END

IF @SplitPay_Lgh_Type_to_use = 'lghtype2'
BEGIN	
 	insert into #Legheader_records
	select stp_number_start, lgh_number, lgh_type2, null , lgh_driver1, lgh_tractor , lgh_primary_trailer, lgh_carrier 
	from  legheader 
	where  mov_number = @mov_number
	and ( CHARINDEX(lgh_type2, @SplitPay_codes) > 0  ) 
	----------------and lgh_type2 in (select * from #SplitPay_Lgh_Type_codes)  -- PTS 49420 
END


IF @SplitPay_Lgh_Type_to_use = 'lghtype3'
BEGIN	
 	insert into #Legheader_records
	select stp_number_start, lgh_number, lgh_type3, null , lgh_driver1, lgh_tractor , lgh_primary_trailer, lgh_carrier  
	from  legheader 
	where  mov_number = @mov_number
	and ( CHARINDEX(lgh_type3, @SplitPay_codes) > 0  ) 
	---------------and lgh_type3 in (select * from #SplitPay_Lgh_Type_codes)  -- PTS 49420 
END


IF @SplitPay_Lgh_Type_to_use = 'lghtype4'
BEGIN	
 	insert into #Legheader_records
	select stp_number_start, lgh_number, lgh_type4, null , lgh_driver1, lgh_tractor , lgh_primary_trailer, lgh_carrier 
	from  legheader 
	where  mov_number = @mov_number
	and ( CHARINDEX(lgh_type4, @SplitPay_codes) > 0  ) 
	--------------and lgh_type4 in (select * from #SplitPay_Lgh_Type_codes)  -- PTS 49420 
END


select stp_number, stp_mfh_sequence, lgh_number, mov_number 
into   #temp_stops
from stops
where mov_number = @mov_number 
and stp_number in (select stp_number_start from #Legheader_records) 

update #Legheader_records
set stp_mfh_sequence = (select #temp_stops.stp_mfh_sequence from #temp_stops
						where #temp_stops.stp_number = #Legheader_records.stp_number_start) 

set @segment_lgh_type = (select lgh_type from #Legheader_records where lgh_number = @lgh_number) 


set @Legheader_records_rowcount  = (select count(*) from #Legheader_records) 


-- if there is no data - get out.
if @Legheader_records_rowcount <= 0 
	begin
			SET @lgh_driver1 = '-1'
			SET @lgh_tractor = '-1'
			SET @lgh_primary_trailer  = '-1'
			SET @lgh_carrier = '-1'
		RETURN 
	end


-- *************  The Real Work  ***********************
-- at this point we have the lgh_type code to look at and the set of legheader records to consider.

	---IF ( @segment_lgh_type <> @gi_string1_PU ) AND ( @segment_lgh_type <> @gi_string4_DEL )		-- PTS 49420 
	
	IF ( CHARINDEX(@segment_lgh_type, @gi_string1_PU) = 0  )  AND  ( CHARINDEX(@segment_lgh_type, @gi_string4_DEL) = 0  )
	BEGIN
		-- get out we don't deal with that
		SET @lgh_driver1 = ''
		RETURN	
	END 

--  if there are less than 4 segments... need to handle it.  gi_string 2 and 3 may NOT both be set.

-- handle "special case"  PU/LH/DEL  <<start>>
declare @li_segment_count int
declare @li_count_pu int
declare @li_count_del int
declare @li_count_lh int

set @li_segment_count = ( select count(*) from #Legheader_records ) 
-- PTS 49420 
set @li_count_pu	= (select count(*) from #Legheader_records where ( CHARINDEX(lgh_type, @gi_string1_PU) > 0  )  ) 
set @li_count_del	= (select count(*) from #Legheader_records where ( CHARINDEX(lgh_type, @gi_string4_DEL) > 0  )  ) 
set @li_count_lh	= (select count(*) from #Legheader_records 
						where (  ( CHARINDEX(lgh_type, @gi_string2_LHP) > 0  )  OR ( CHARINDEX(lgh_type, @gi_string3_LHD) > 0  )  )  ) 

-- PTS 49420 
--------set @li_count_pu	= (select count(*) from #Legheader_records where lgh_type = @gi_string1_PU ) 
--------set @li_count_del	= (select count(*) from #Legheader_records where lgh_type = @gi_string4_DEL  ) 
--------set @li_count_lh	= (select count(*) from #Legheader_records where lgh_type = @gi_string2_LHP  OR  lgh_type = @gi_string3_LHD ) 



-----*********  check for error conditions <<start>>
-- if we have 2 segments and user enters one as PU and one as Delivery - kick that out/ error condition.
-- or some other combination where we have no line haul seqments... error/ get out.
if @li_segment_count > 1 and @li_count_lh = 0 
	begin
			SET @lgh_driver1 = '-1'
			SET @lgh_tractor = '-1'
			SET @lgh_primary_trailer  = '-1'
			SET @lgh_carrier = '-1'
		RETURN 
	end
-----********* end of check for error conditions <<end>>



if @li_segment_count = 2 OR @li_segment_count = 3
begin
-- handle "special case"  PU/LH/DEL
	--IF ( @li_count_pu = 1 AND @li_count_del = 1 AND @li_count_lh = 1 ) 
		--BEGIN 	
			update #Legheader_records
			set lgh_type = 'LH'
			where ( CHARINDEX(lgh_type, @gi_string2_LHP) > 0  ) 
			OR    ( CHARINDEX(lgh_type, @gi_string3_LHD) > 0   ) 	
			--where lgh_type = @gi_string2_LHP  OR  lgh_type = @gi_string3_LHD		-- 49420		
		--END 
end
-- handle "special case"  PU/LH/DEL  <<end>>



set @lgh_driver1 = ''

------IF @segment_lgh_type = @gi_string1_PU			-- 49420	
IF CHARINDEX(@segment_lgh_type, @gi_string1_PU) > 0 
BEGIN 
	SET @current_stp_mfh_sequence = (select stp_mfh_sequence from #Legheader_records where lgh_number = @lgh_number )
		SET @next_prev_lgh_number = ( select min(lgh_number)
									from #Legheader_records 
									where stp_mfh_sequence > @current_stp_mfh_sequence									
									and ( ( CHARINDEX(lgh_type, @gi_string2_LHP) > 0  )   OR ( lgh_type = 'LH') ) )
									--and (  (lgh_type = @gi_string2_LHP)  OR ( lgh_type = 'LH') ) )			-- 49420	
									
		IF @next_prev_lgh_number > 0
		BEGIN
			SET @lgh_driver1 = (select lgh_driver1 from #Legheader_records where lgh_number = @next_prev_lgh_number )
			SET @lgh_tractor = (select lgh_tractor from #Legheader_records where lgh_number = @next_prev_lgh_number )
			SET @lgh_primary_trailer  = (select lgh_primary_trailer from #Legheader_records where lgh_number = @next_prev_lgh_number )
			SET @lgh_carrier = (select lgh_carrier from #Legheader_records where lgh_number = @next_prev_lgh_number )
		END

END


----IF @segment_lgh_type = @gi_string4_DEL		-- 49420	
IF CHARINDEX(@segment_lgh_type, @gi_string4_DEL) > 0 
BEGIN 
	SET @current_stp_mfh_sequence = (select stp_mfh_sequence from #Legheader_records where lgh_number = @lgh_number )




		SET @next_prev_lgh_number = ( select max(lgh_number)
									from #Legheader_records 
									where stp_mfh_sequence < @current_stp_mfh_sequence
									and ( ( CHARINDEX(lgh_type, @gi_string3_LHD) > 0  )   OR ( lgh_type = 'LH') ) )
									---and ( (lgh_type = @gi_string3_LHD)   OR ( lgh_type = 'LH') ) )		-- 49420	

		IF @next_prev_lgh_number > 0
		BEGIN
			SET @lgh_driver1 = (select lgh_driver1 from #Legheader_records where lgh_number = @next_prev_lgh_number )
			SET @lgh_tractor = (select lgh_tractor from #Legheader_records where lgh_number = @next_prev_lgh_number )
			SET @lgh_primary_trailer  = (select lgh_primary_trailer from #Legheader_records where lgh_number = @next_prev_lgh_number )
			SET @lgh_carrier = (select lgh_carrier from #Legheader_records where lgh_number = @next_prev_lgh_number )
		END

END



---- *************  Final Result - just return ***********************

RETURN 

GO
GRANT EXECUTE ON  [dbo].[Split_Pay_processing_rtn_offset_asset] TO [public]
GO
