SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[segment_stop_count_custom1_sp](@pl_lgh int,@pl_numStops int OUT,@pl_stcStops int OUT) AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/26/2007.01 ? PTS40189 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
	
declare @ls_revtype3_exclude varchar(255),@li_stp_count int,@li_stp_mfh_sequence int ,@li_stc_count int,@ls_tcd_cmp varchar(8)
declare @ls_cmp_id varchar(25),@ls_prior_cmp_id varchar(8),@ls_ord_revtype3 varchar(6),@ls_revtype3_stc_include varchar(255)
	create table #temp (stp_number int,
						stp_mfh_sequence int,
						cmp_id varchar(8),
						stp_event varchar(6),
						cmp_altid varchar(25) NULL,
						ord_revtype3 varchar(6)NULL)	

	
	select @ls_revtype3_exclude = gi_string1 from generalinfo where gi_name = 'Revtype3StopExcludeList'
	If datalength(@ls_revtype3_exclude) > 0 
	begin
		select @ls_revtype3_exclude =','+ @ls_revtype3_exclude +','
	end
	else
	begin
		select @ls_revtype3_exclude = null
	end
	

	select @ls_revtype3_stc_include = gi_string1 from generalinfo where gi_name = 'Revtype3STCIncludeList'
	If datalength(@ls_revtype3_stc_include) > 0 
	begin
		select @ls_revtype3_stc_include =','+ @ls_revtype3_stc_include +','
	end
	else
	begin
		select @ls_revtype3_stc_include = null
	end


	insert into #temp
	select stp_number ,stp_mfh_sequence,cmp_id , stp_event, null, ord_revtype3 
	from stops  LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber  --pts40189 outer join conversion
	where lgh_number = @pl_lgh

	update #temp set cmp_altid = company.cmp_altid from company where #temp.cmp_id = company.cmp_id
	update #temp set cmp_altid = null where ltrim(rtrim(cmp_altid)) = ''

--	select @ls_revtype3_exclude

	select @li_stp_count = 0,@li_stp_mfh_sequence = 0,@li_stc_count = 0
	While 1 = 1
	Begin
		select @li_stp_mfh_sequence =  min(stp_mfh_sequence) from #temp where stp_mfh_sequence > @li_stp_mfh_sequence
		If @li_stp_mfh_sequence is null
			break

		select @ls_cmp_id = IsNull(cmp_altid,cmp_id) ,@ls_tcd_cmp = cmp_id ,@ls_ord_revtype3 = ord_revtype3 from #temp where stp_mfh_sequence = @li_stp_mfh_sequence
--		select @li_stp_mfh_sequence , @ls_cmp_id
		IF @ls_ord_revtype3 is not null
		BEGIN
			If not exists (SELECT * from tariffcompaniesheader a, tariffcompaniesdetail b
			where a.tch_id = b.tch_id and a.tch_type = 'E' and a.tch_stopexcludeflag = 'Y' and b.tcd_cmp_id = @ls_tcd_cmp) -- @ls_cmp_id)
			Begin
				-- subject to count stops
				If (@ls_revtype3_stc_include is null or ltrim(rtrim(@ls_revtype3_stc_include)) = '' )
				Begin
					If @li_stp_mfh_sequence > 1 
					begin
						select @ls_prior_cmp_id = IsNull(cmp_altid,cmp_id) from #temp where stp_mfh_sequence = @li_stp_mfh_sequence - 1
						If @ls_cmp_id <> @ls_prior_cmp_id 			
						Begin			
							select @li_stc_count = @li_stc_count + 1
						End
					end
					else
					Begin
						select @li_stc_count = @li_stc_count + 1
					End
						
				End
				else
				Begin

					--Subject to count pay
					If exists (Select * from #temp where stp_mfh_sequence = @li_stp_mfh_sequence 
									and charindex (','+ ord_revtype3 +',' , @ls_revtype3_stc_include) > 0)
					Begin
						If @li_stp_mfh_sequence > 1 
						begin
							select @ls_prior_cmp_id = IsNull(cmp_altid,cmp_id) from #temp where stp_mfh_sequence = @li_stp_mfh_sequence - 1
							If @ls_cmp_id <> @ls_prior_cmp_id 			
							Begin			
								select @li_stc_count = @li_stc_count + 1
							End
						end
						else
						Begin
							select @li_stc_count = @li_stc_count + 1
						End
	
					End
				End


				If (@ls_revtype3_exclude is null or ltrim(rtrim(@ls_revtype3_exclude)) = '' )
				Begin
					If @li_stp_mfh_sequence > 1 
					begin
						select @ls_prior_cmp_id = IsNull(cmp_altid,cmp_id) from #temp where stp_mfh_sequence = @li_stp_mfh_sequence - 1
						If @ls_cmp_id <> @ls_prior_cmp_id 			
						Begin			
							select @li_stp_count = @li_stp_count + 1
						End
					end
					else
					Begin
						select @li_stp_count = @li_stp_count + 1
					End
						
				End
				Else
				Begin

					--Extra stop pay
					If not exists (Select * from #temp where stp_mfh_sequence = @li_stp_mfh_sequence 
									and charindex (','+ ord_revtype3 +',' , @ls_revtype3_exclude) > 0)
					Begin
						If @li_stp_mfh_sequence > 1 
						begin
							select @ls_prior_cmp_id = IsNull(cmp_altid,cmp_id) from #temp where stp_mfh_sequence = @li_stp_mfh_sequence - 1
							If @ls_cmp_id <> @ls_prior_cmp_id 			
							Begin			
								select @li_stp_count = @li_stp_count + 1
							End
						end
						else
						Begin
							select @li_stp_count = @li_stp_count + 1
						End
	
					End
					
					
				End
	
			End	
		END 
		/*
		insert into #temp
		select cmp_id , stp_event, ord_revtype3 from stops,orderheader where lgh_number = @pl_lgh
		and stops.ord_hdrnumber = orderheader.ord_hdrnumber and orderheader.ord_hdrnumber > 0 and 
		not exists ( SELECT * from tariffcompaniesheader a, tariffcompaniesdetail b
		where a.tch_id = b.tch_id and a.tch_type = 'E' and stops.cmp_id = b.tcd_cmp_id)
		group by stp_event ,cmp_id, ord_revtype3 */
	end
	
	Select @pl_numStops = @li_stp_count,@pl_stcStops = @li_stc_count

GO
GRANT EXECUTE ON  [dbo].[segment_stop_count_custom1_sp] TO [public]
GO
