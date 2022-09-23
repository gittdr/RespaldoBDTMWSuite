SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[segment_lineitem_casecount_custom1_sp](@pl_lgh int) AS	
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

declare @ls_revtype3_exclude varchar(255),@li_stp_count int,@li_stp_mfh_sequence int ,@li_next_stp_mfh_sequence int
declare @li_group_num int,@li_hold int,@ls_tcd_cmp varchar(8) 
declare @ls_cmp_id varchar(25),@ls_next_cmp_id varchar(8),@ls_ord_revtype3 varchar(6)
	create table #temp (stp_number int,
						stp_mfh_sequence int,
						cmp_id varchar(8),
						stp_event varchar(6),
						ord_revtype3 varchar(6)NULL,
						group_number int NULL,
						cmp_altid varchar(25) NULL )	
	create table #temp2 (group_number int ,
						 line_items money,
						 case_counts money,
						 li_amount money , 
						 cc_amount money,
						 min_amount money,
						 cmp_id   varchar(8),
-- PTS 32271 -- BL (start)
--						 cmp_name varchar(100)	)
						 cmp_name varchar(100) NULL )
-- PTS 32271 -- BL (end)

						 

	
	select @ls_revtype3_exclude = gi_string1 from generalinfo where gi_name = 'Revtype3liccExcludeList'
	If datalength(@ls_revtype3_exclude) > 0 
	begin
		select @ls_revtype3_exclude =','+ @ls_revtype3_exclude +','
	end
	else
	begin
		select @ls_revtype3_exclude = null
	end
	
	insert into #temp
	select stp_number ,stp_mfh_sequence,cmp_id , stp_event, ord_revtype3,0,NULL 
	from stops  LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber  --pts40189 outer join conversion
	where lgh_number = @pl_lgh

	update #temp set cmp_altid = company.cmp_altid from company where #temp.cmp_id = company.cmp_id
	update #temp set cmp_altid = null where ltrim(rtrim(cmp_altid)) = ''


--	select @ls_revtype3_exclude

	select @li_stp_count = 0,@li_stp_mfh_sequence = 0,@li_group_num = 0
	While 1 = 1
	BEGIN
		select @li_stp_mfh_sequence =  min(stp_mfh_sequence) from #temp where stp_mfh_sequence > @li_stp_mfh_sequence and group_number = 0
		If @li_stp_mfh_sequence is null
			break
		select @li_group_num = @li_group_num + 1
		select @ls_cmp_id = IsNull(cmp_altid,cmp_id),@ls_tcd_cmp = cmp_id ,@ls_ord_revtype3 = ord_revtype3 from #temp where stp_mfh_sequence = @li_stp_mfh_sequence

--		select @li_stp_mfh_sequence , @ls_cmp_id
		IF @ls_ord_revtype3 is not null
		BEGIN
			If not exists (SELECT * from tariffcompaniesheader a, tariffcompaniesdetail b
			where a.tch_id = b.tch_id and a.tch_type = 'E' and a.tch_stopexcludeflag = 'Y' and b.tcd_cmp_id = @ls_tcd_cmp) --@ls_cmp_id)
			Begin
				IF @ls_revtype3_exclude is null
				BEGIN	
	
					--select @ls_cmp_id 
					update #temp set group_number = @li_group_num where stp_mfh_sequence = @li_stp_mfh_sequence
					select @li_next_stp_mfh_sequence = @li_stp_mfh_sequence + 1
					While 2 =2 
					Begin
						select @li_hold = null 		
						select @li_hold = stp_mfh_sequence from #temp where 
								stp_mfh_sequence = @li_next_stp_mfh_sequence and IsNull(cmp_altid,cmp_id) = @ls_cmp_id 
						
						
					--	select 'next sequence ' ,@li_hold, @li_next_stp_mfh_sequence
						If @li_hold is null
						Begin
							select @li_stp_mfh_sequence = @li_next_stp_mfh_sequence	- 1
							break
						End
						else
						Begin
						
							update #temp set group_number = @li_group_num where stp_mfh_sequence = @li_next_stp_mfh_sequence
							select @li_next_stp_mfh_sequence = @li_next_stp_mfh_sequence + 1
						End
					End
				 END -- If no revtype3 exclude list
				 ELSE -- there is a revtype3 exclude list
				 BEGIN
					If not exists (Select * from #temp where stp_mfh_sequence = @li_stp_mfh_sequence 
									and charindex (','+ ord_revtype3 +',' , @ls_revtype3_exclude) > 0)
					BEGIN
						update #temp set group_number = @li_group_num where stp_mfh_sequence = @li_stp_mfh_sequence
						select @li_next_stp_mfh_sequence = @li_stp_mfh_sequence + 1
						While 2 =2 
						Begin
							select @li_hold = null 		
							select @li_hold = stp_mfh_sequence from #temp where 
									stp_mfh_sequence = @li_next_stp_mfh_sequence and IsNull(cmp_altid,cmp_id) = @ls_cmp_id 
							
							
						--	select 'next sequence ' ,@li_hold, @li_next_stp_mfh_sequence
							If @li_hold is null
							Begin
								select @li_stp_mfh_sequence = @li_next_stp_mfh_sequence	- 1
								break
							End
							else
							Begin
							
								update #temp set group_number = @li_group_num where stp_mfh_sequence = @li_next_stp_mfh_sequence
								select @li_next_stp_mfh_sequence = @li_next_stp_mfh_sequence + 1
							End
						End-- 2=2 
	
	
					END	--charindex
	
				END --revtype3 exclude list

			 END-- tariffcompanies exclude list		
		  End -- ord_revtype3 is not null
	
		END -- 1 = 1

	insert into #temp2
	select group_number,0,0,0,0,0,min(cmp_id),'' from #temp where group_number > 0 group by group_number

	update #temp2 set line_items = (select IsNull(sum(cast(ref_number as money)),0) from referencenumber where ref_table ='freightdetail'
									and ref_type = 'LNITEM' and ref_tablekey in (select fgt_number from freightdetail where stp_number in (select
									stp_number from #temp where #temp.group_number = #temp2.group_number))) 


	update #temp2 set case_counts = (select IsNull(sum(fgt_count),0) from freightdetail where stp_number in (select
									stp_number from #temp where #temp.group_number = #temp2.group_number)) 


	update #temp2 set cmp_name = company.cmp_name from company where #temp2.cmp_id = company.cmp_id
	delete #temp2 where line_items =0 and case_counts =0
	--select * from #temp	
	select group_number,line_items, case_counts,li_amount, cc_amount,min_amount,cmp_id,cmp_name from #temp2

GO
GRANT EXECUTE ON  [dbo].[segment_lineitem_casecount_custom1_sp] TO [public]
GO
