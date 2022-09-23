SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[RefNumLookup](@colnumber int, @dv_id char(6), @lgh_number int, @ord_hdrnumber int)
RETURNS varchar(30)
-- WITH EXECUTE AS CALLER  JLB PTS 49323 this is default behavior and causes errors in SQL 2000 so just commenting it out
--PTS 79441 Removed hard coded index hints and made 3 deep subselects into joins.
AS
BEGIN
	declare @dv_reference_table varchar(18), @dv_reference_type varchar(6), @dv_reference_number as varchar(30)
	
	-- get the view definition for the reference table and type
	-- JET - 7/6/09 - PTS 47757, add the DW restriction to the select statement.  It was failing if there is an OB and/or IB view with the same ID as a DW view
	if @colnumber = 1 
		-- if the col argument is 1, then get the view definition for reference1 table and type
		select @dv_reference_table = dv_reference1_table, 
			   @dv_reference_type = dv_reference1_type 
		  from dispatchview
		 where dv_id = @dv_id 
           and dv_type = 'DW' 
	else
	if @colnumber = 2 
		-- if the col argument is 2, then get the view definition for reference1 table and type
		select @dv_reference_table = dv_reference2_table, 
			   @dv_reference_type = dv_reference2_type 
		  from dispatchview
		 where dv_id = @dv_id 
           and dv_type = 'DW' 
	else
		-- if the col argument is any thing else, then return an empty string
		return ''
	
	-- if no tab;e is assigned, then exit without trying to search for a match
	if @dv_reference_table is null or len(rtrim(@dv_reference_table)) < 1
		return ''
	-- if no type is assigned, then exit without trying to search for a match
	if @dv_reference_type is null or len(rtrim(@dv_reference_type)) < 1
		return ''
	
	-- select the appropriate reference number based on the table
	if @dv_reference_table = 'orderheader'
		set @dv_reference_number = isnull((select top 1 ref_number 
		                                 from dbo.referencenumber with (nolock) 
		                                where ref_table = @dv_reference_table 
		                                  and ref_type = @dv_reference_type 
		                                  and ref_tablekey = @ord_hdrnumber order by ref_id desc), '')


	else
	if @dv_reference_table = 'legheader'
		set @dv_reference_number = isnull((select top 1 ref_number 
		                                 from dbo.referencenumber with (nolock) 
		                                where ref_table = @dv_reference_table 
		                                  and ref_type = @dv_reference_type 
		                                  and ref_tablekey = @lgh_number order by ref_id desc), '')
	else
	if @dv_reference_table = 'stops'
		set @dv_reference_number = isnull((
									select top 1 r.ref_number 
									from dbo.referencenumber r with (nolock) 
									inner join stops s with (nolock) on r.ref_tablekey = s.stp_number
									where r.ref_table = @dv_reference_table 
									and r.ref_type = @dv_reference_type 
									and s.lgh_number = @lgh_number order by r.ref_id desc
										),'') 
	else
	if @dv_reference_table = 'freightdetail'
		set @dv_reference_number = isnull((
							select top 1 ref_number 
							from dbo.referencenumber r with (nolock) 
							inner join dbo.freightdteail f with (nolock) on r.ref_tablekey = f.fgt_number
							inner join dbo.stops with (nolock) on f.stp_number = s.stp_number
							where ref_table = @dv_reference_table 
							and ref_type = @dv_reference_type 
							and s.lgh_number = @lgh_number
							order by r.ref_id desc 
							),'')
		                                    
	else
		-- if the table value is any thing else, then return an empty string
		return ''

	if @dv_reference_number is null
		set @dv_reference_number = ''

	return @dv_reference_number
END
GO
GRANT EXECUTE ON  [dbo].[RefNumLookup] TO [public]
GO
