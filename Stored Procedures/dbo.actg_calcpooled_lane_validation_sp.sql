SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[actg_calcpooled_lane_validation_sp]
	@p_ord_hdrnumber int,
	@p_tkr_split_first_segment_origin varchar (8),
	@p_tkr_split_first_segment_dest varchar (8),
	@p_tkr_id as integer,
	@p_ret integer out

as
set nocount on 

declare @count as integer
declare @min_lgh_number as integer
declare @min_stp_mfh_sequence_start as integer
declare @min_stp_mfh_sequence_end as integer
declare @found as integer
declare @legfound as integer
declare @legcount as integer
declare @prevent_chrg_flag_me as integer
declare @prevent_chrg_flag as integer
declare @numberlegsprocessed as integer


IF (IsNull (@p_tkr_split_first_segment_origin, 'UNKNOWN') = 'UNKNOWN' or @p_tkr_split_first_segment_origin = '')
   AND (IsNull (@p_tkr_split_first_segment_dest, 'UNKNOWN') = 'UNKNOWN' or @p_tkr_split_first_segment_dest = '') Begin
	select @count = count (*) from tariffkeyrevall_codes where tkr_id = @p_tkr_id and tkc_type IN ('FirstEvent', 'SecondEvent')
	IF @count = 0 Begin
		select @p_ret = 0
		Return	
	End
End

select @min_lgh_number = min (lgh_number) from actg_temp_orderstops where sp_id = @@spid and lgh_number IS NOT NULL and ord_hdrnumber = @p_ord_hdrnumber /*PTS 37504 CGK*/
select @min_lgh_number = IsNull (@min_lgh_number, 0)
IF @min_lgh_number = 0 Begin
	select @p_ret = -1
	Return
End

select @found = 0
select @numberlegsprocessed = 0
WHILE @min_lgh_number > 0 Begin
	select @legfound = 0
	select @legcount = 0
	select @min_stp_mfh_sequence_start = -1
	select @min_stp_mfh_sequence_end = -1
	select @numberlegsprocessed = @numberlegsprocessed + 1

	select @prevent_chrg_flag = 0

	select @prevent_chrg_flag = count (*) 
	from actg_temp_workrevalloc, tariffheaderrevall
	where actg_temp_workrevalloc.thr_id =  tariffheaderrevall.thr_id
	and actg_temp_workrevalloc.sp_id = @@spid
 	and tariffheaderrevall.thr_prevent_chrg_flag = 'Y'
	and actg_temp_workrevalloc.lgh_number = @min_lgh_number

--	Print '@min_lgh_number = ' + Cast (@min_lgh_number as varchar )
-- 	Print '@p_tkr_id = ' + Cast (@p_tkr_id as varchar )
-- 	Print '@prevent_chrg_flag = ' + Cast (@prevent_chrg_flag as varchar )
	select @count = count (*) from actg_temp_workrevalloc where sp_id = @@spid
-- 	print '#workrevalloc count = ' + Cast (@count as varchar )
	select @count = IsNull (Max (thr_id), 0) from actg_temp_workrevalloc where sp_id = @@spid and thr_id Is Not Null
-- 	print '#Max thr_id from workrevalloc = ' + Cast (@count as varchar )

	IF @prevent_chrg_flag = 0 Begin

		select @prevent_chrg_flag_me = 0
		select @prevent_chrg_flag_me = count (*) 
		from tariffkeyrevall, tariffheaderrevall
		where tariffkeyrevall.thr_id =  tariffheaderrevall.thr_id
		and tariffkeyrevall.tkr_id = @p_tkr_id
	 	and tariffheaderrevall.thr_prevent_chrg_flag = 'Y'
	
		--Print '@min_lgh_number = ' + Cast (@min_lgh_number as varchar )
		IF IsNull (@p_tkr_split_first_segment_origin, 'UNKNOWN') = 'UNKNOWN' or @p_tkr_split_first_segment_origin = '' Begin
			select @count = count (*) from tariffkeyrevall_codes where tkr_id = @p_tkr_id and tkc_type IN ('FirstEvent')
			If @count > 0 Begin
-- 	-- 			Print 'Only Event (First)'
				select @min_stp_mfh_sequence_start = min (stp_mfh_sequence)
				from stops, tariffkeyrevall_codes
				where stops.stp_event = tariffkeyrevall_codes.tkc_code
				and tariffkeyrevall_codes.tkc_type = 'FirstEvent'
				and stops.lgh_number = @min_lgh_number
				and stp_mfh_sequence Is Not NULL
			End --Else do nothing there is no first criteria.
		End 
		Else Begin	
			select @count = count (*) from tariffkeyrevall_codes where tkr_id = @p_tkr_id and tkc_type IN ('FirstEvent')
			If @count > 0 Begin
-- 	-- 			Print 'Event and Company  (First)'
				select @min_stp_mfh_sequence_start = Min (stp_mfh_sequence)
				from stops, tariffkeyrevall_codes
				where stops.stp_event = tariffkeyrevall_codes.tkc_code
				and tariffkeyrevall_codes.tkc_type = 'FirstEvent'
				and stops.lgh_number = @min_lgh_number
				and stops.cmp_id = @p_tkr_split_first_segment_origin
				and stp_mfh_sequence IS NOT NULL
			End
			Else Begin
	-- 			Print 'Only Company  (First)'
				select @min_stp_mfh_sequence_start = Min (stp_mfh_sequence)
				from stops
				where stops.lgh_number = @min_lgh_number
				and stops.cmp_id = @p_tkr_split_first_segment_origin
				and stp_mfh_sequence IS NOT NULL
			End
		End
	
	--	Print '@min_stp_mfh_sequence_start = ' + Cast (@min_stp_mfh_sequence_start as varchar )
		select @min_stp_mfh_sequence_start = IsNull (@min_stp_mfh_sequence_start, 0)
		IF @min_stp_mfh_sequence_start <> 0 Begin
			IF IsNull (@p_tkr_split_first_segment_dest, 'UNKNOWN') = 'UNKNOWN' or @p_tkr_split_first_segment_dest = '' Begin
				select @count = count (*) from tariffkeyrevall_codes where tkr_id = @p_tkr_id and tkc_type IN ('SecondEvent')
				If @count > 0 Begin
	-- 				Print 'Only Event (Second)'
					select @min_stp_mfh_sequence_end = Min (stp_mfh_sequence)
					from stops, tariffkeyrevall_codes
					where stops.stp_event = tariffkeyrevall_codes.tkc_code
					and tariffkeyrevall_codes.tkc_type = 'SecondEvent'
					and stops.lgh_number = @min_lgh_number
					and stops.stp_mfh_sequence > @min_stp_mfh_sequence_start
					and stp_mfh_sequence IS NOT NULL
				End 
				Else Begin
					IF @min_stp_mfh_sequence_start <= 0 
						select @min_stp_mfh_sequence_end  = 0
					Else
						select @min_stp_mfh_sequence_end = @min_stp_mfh_sequence_start + 1
				End 
			End 
			Else Begin	
				select @count = count (*) from tariffkeyrevall_codes where tkr_id = @p_tkr_id and tkc_type IN ('SecondEvent')
				If @count > 0 Begin
	-- 				Print 'Event and Company  (Second)'
					select @min_stp_mfh_sequence_end = Min (stp_mfh_sequence)
					from stops, tariffkeyrevall_codes
					where stops.stp_event = tariffkeyrevall_codes.tkc_code
					and tariffkeyrevall_codes.tkc_type = 'SecondEvent'
					and stops.lgh_number = @min_lgh_number
					and stops.cmp_id = @p_tkr_split_first_segment_dest
					and stops.stp_mfh_sequence > @min_stp_mfh_sequence_start
					and stp_mfh_sequence IS NOT NULL
				End
				Else Begin
	-- 				Print 'Only Company  (Second)'
					select @min_stp_mfh_sequence_end = Min (stp_mfh_sequence)
					from stops
					where stops.lgh_number = @min_lgh_number
					and stops.cmp_id = @p_tkr_split_first_segment_dest
					and stops.stp_mfh_sequence > @min_stp_mfh_sequence_start
					and stp_mfh_sequence IS NOT NULL
				End
			End
		End 
		select @min_stp_mfh_sequence_end = IsNull (@min_stp_mfh_sequence_end, -1)
	-- 	Print '@min_stp_mfh_sequence_end = ' + Cast (@min_stp_mfh_sequence_end as varchar )
	
		IF (@min_stp_mfh_sequence_start > 0 OR @min_stp_mfh_sequence_end > 0) AND  @min_stp_mfh_sequence_end > @min_stp_mfh_sequence_start Begin
			select @legfound = 1
			select @legcount = 1
		End 
	
		
		While @min_stp_mfh_sequence_end > 0 AND @prevent_chrg_flag_me = 0 Begin
			select @min_stp_mfh_sequence_start = @min_stp_mfh_sequence_end
			IF IsNull (@p_tkr_split_first_segment_origin, 'UNKNOWN') = 'UNKNOWN' or @p_tkr_split_first_segment_origin = '' Begin
				select @count = count (*) from tariffkeyrevall_codes where tkr_id = @p_tkr_id and tkc_type IN ('FirstEvent')
				If @count > 0 Begin
					select @min_stp_mfh_sequence_start = Min (stp_mfh_sequence)
					from stops, tariffkeyrevall_codes
					where stops.stp_event = tariffkeyrevall_codes.tkc_code
					and tariffkeyrevall_codes.tkc_type = 'FirstEvent'
					and stops.lgh_number = @min_lgh_number
					and stops.stp_mfh_sequence >= @min_stp_mfh_sequence_end
					and stp_mfh_sequence IS NOT NULL
				End --Else do nothing there is no first criteria.
			End 
			Else Begin	
				select @count = count (*) from tariffkeyrevall_codes where tkr_id = @p_tkr_id and tkc_type IN ('FirstEvent')
				If @count > 0 Begin
					select @min_stp_mfh_sequence_start = Min (stp_mfh_sequence)
					from stops, tariffkeyrevall_codes
					where stops.stp_event = tariffkeyrevall_codes.tkc_code
					and tariffkeyrevall_codes.tkc_type = 'FirstEvent'
					and stops.lgh_number = @min_lgh_number
					and stops.cmp_id = @p_tkr_split_first_segment_origin
					and stops.stp_mfh_sequence >= @min_stp_mfh_sequence_end
					and stp_mfh_sequence IS NOT NULL
				End
				Else Begin
					select @min_stp_mfh_sequence_start = Min (stp_mfh_sequence)
					from stops
					where stops.lgh_number = @min_lgh_number
					and stops.cmp_id = @p_tkr_split_first_segment_origin
					and stops.stp_mfh_sequence >= @min_stp_mfh_sequence_end
					and stp_mfh_sequence IS NOT NULL
				End
			End
			
			select @min_stp_mfh_sequence_start = IsNull (@min_stp_mfh_sequence_start, 0)
			select @min_stp_mfh_sequence_end = 0
	-- 		Print 'Loop @min_stp_mfh_sequence_start = ' + Cast (@min_stp_mfh_sequence_start as varchar )	
	
			IF @min_stp_mfh_sequence_start <> 0 Begin
				IF IsNull (@p_tkr_split_first_segment_dest, 'UNKNOWN') = 'UNKNOWN' or @p_tkr_split_first_segment_dest = '' Begin
					select @count = count (*) from tariffkeyrevall_codes where tkr_id = @p_tkr_id and tkc_type IN ('SecondEvent')
					If @count > 0 Begin
						select @min_stp_mfh_sequence_end = Min (stp_mfh_sequence)
						from stops, tariffkeyrevall_codes
						where stops.stp_event = tariffkeyrevall_codes.tkc_code
						and tariffkeyrevall_codes.tkc_type = 'SecondEvent'
						and stops.lgh_number = @min_lgh_number
						and stops.stp_mfh_sequence > @min_stp_mfh_sequence_start
						and stp_mfh_sequence IS NOT NULL
					End --Else do nothing there is no first criteria.
					Else Begin
	-- 					Print 'Nothing (Second)'
						IF @min_stp_mfh_sequence_start = 0 
							select @min_stp_mfh_sequence_end  = 0
						Else
							select @min_stp_mfh_sequence_end = @min_stp_mfh_sequence_start + 1
					End 
				End 
				Else Begin	
					select @count = count (*) from tariffkeyrevall_codes where tkr_id = @p_tkr_id and tkc_type IN ('SecondEvent')
					If @count > 0 Begin
						select @min_stp_mfh_sequence_end = Min (stp_mfh_sequence)
						from stops, tariffkeyrevall_codes
						where stops.stp_event = tariffkeyrevall_codes.tkc_code
						and tariffkeyrevall_codes.tkc_type = 'SecondEvent'
						and stops.lgh_number = @min_lgh_number
						and stops.cmp_id = @p_tkr_split_first_segment_dest
						and stops.stp_mfh_sequence > @min_stp_mfh_sequence_start
						and stp_mfh_sequence IS NOT NULL
	-- 					print 'Loop Event and Company (Second)'
					End
					Else Begin
						select @min_stp_mfh_sequence_end = Min (stp_mfh_sequence)
						from stops
						where stops.lgh_number = @min_lgh_number
						and stops.cmp_id = @p_tkr_split_first_segment_dest
						and stops.stp_mfh_sequence > @min_stp_mfh_sequence_start
						and stp_mfh_sequence IS NOT NULL
					End
				End
			End
	
	-- 		Print 'Loop @min_stp_mfh_sequence_end = ' + Cast (@min_stp_mfh_sequence_end as varchar )	
			select @min_stp_mfh_sequence_end = IsNull (@min_stp_mfh_sequence_end, -1)
			IF (@min_stp_mfh_sequence_start > 0 OR @min_stp_mfh_sequence_end > 0) AND @min_stp_mfh_sequence_end > @min_stp_mfh_sequence_start Begin
				select @legcount = @legcount + 1
			End 
	
			--select @min_stp_mfh_sequence_end = 0
		End
	End	
	IF @legfound > 0 Begin
-- 		Print '@min_lgh_number, @legcount ' + Cast (@min_lgh_number as varchar) + ', ' + Cast (@legcount as varchar)
		select @found = 1
		insert into actg_temp_legcount values (@@spid, @min_lgh_number, @legcount)
	End 
	select @min_lgh_number = min (lgh_number) from actg_temp_orderstops where sp_id = @@spid and lgh_number > @min_lgh_number and ord_hdrnumber = @p_ord_hdrnumber /*PTS 37504 CGK*/
	select @min_lgh_number = IsNull (@min_lgh_number, 0)

END


IF @found > 0 Begin
-- 	print '@p_ret = 1'
 	select @p_ret = 1
End
Else Begin
-- 	print '@p_ret -1'
	select @p_ret = -1
End
-- print '---------------------'

GO
GRANT EXECUTE ON  [dbo].[actg_calcpooled_lane_validation_sp] TO [public]
GO
