SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[CARTLO_V001_SP] (
	@pl_ord_hdrnumber int , -- the current order being settled 
	@pl_lgh_number int, -- the current trip segment being settled
	@pl_isprimary int, -- 0 or 1, 1 indicates that the revenue is being requested for linehaul settlement rate
	@ps_asgn_type varchar(6), -- indicates the type of asset, you can put conditional logic to determine rates based on this type
	@ps_asgn_id varchar(13), -- indicates the id of the asset
	@ps_paytype varchar(6), -- the paytype that the application found on the calculated revenue rate
	@pl_tarnum int, -- the tariff number on the rate being used
	@pl_disallowzeropaydetail int out, -- If you set this to 1 and the calc revenue is zero the app will not create a zero paydetail.
	@ps_returnmsg varchar(255) out, -- You should return a message to the application to indicate why the custom calculation failed.
	@pdec_calcrevenue money out, -- return the calculated revenue here. Populate this with -1 if the calculation fails
	@ps_loadstate varchar(3) OUT, -- Return the Load Status
	@pdc_rate decimal OUT -- Return the Rate	
					)
as 
/**
 *
 * COMMENTS:
	'CARTLO'	coded by Dan Meek (checked in by vjh)
**/
select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'


-- BEGIN CARTLO

Begin

Declare	@stp_lgh_mileage dec, -- leg miles 
		@ord_lgh_mileage dec, -- qualifying total of leg miles on the order
		@cl_mov_number int,
		@ord_fromord varchar(12),
		@extra_id int,  
		@tab_id int,
		@max_row int,
		@col_id int,
		@routehours real,
		@cl_ord_hdrnumber varchar (12) --Carter's Master Order Ord_hdrnumber
        
	select @cl_mov_number = mov_number from legheader where lgh_number = @pl_lgh_number     
	Select @stp_lgh_mileage = isNull(sum(isNull(stp_lgh_mileage,0)),0) from stops s, legheader lh where lh.lgh_number = s.lgh_number and lh.lgh_type1 = 'HOU' and s.lgh_number = @pl_lgh_number  
	Select @ord_lgh_mileage = isNull(sum(isNull(stp_lgh_mileage,0)),0) from stops s, legheader lh where lh.lgh_number = s.lgh_number and lh.lgh_type1 = 'HOU' and s.mov_number = @cl_mov_number 
	Select @ord_fromord = ord_fromorder from orderheader where ord_hdrnumber = @pl_ord_hdrnumber
	select @Extra_id = Extra_id from extra_info_tab where tab_name = 'Master Order Pay Hours'
	select @tab_id = tab_id from extra_info_cols where col_name = 'Quantity Of Pay Hours'
	select @cl_ord_hdrnumber = cast(ord_hdrnumber as varchar) from orderheader where ord_number = @ord_fromord
	select @max_row = MAX( col_row ) FROM EXTRA_INFO_DATA WHERE @extra_id = EXTRA_ID AND @tab_id = TAB_ID AND TABLE_KEY = @cl_ord_hdrnumber
	select @col_id = col_id FROM EXTRA_INFO_DATA WHERE @extra_id = EXTRA_ID AND @tab_id = TAB_ID AND TABLE_KEY = @cl_ord_hdrnumber and col_row = @max_row 
	select @routehours = cast(col_data as real) from EXTRA_INFO_DATA WHERE @extra_id = EXTRA_ID AND @tab_id = TAB_ID AND TABLE_KEY = @cl_ord_hdrnumber and col_row = @max_row and col_id = @col_id

	select @pdec_calcrevenue = (@stp_lgh_mileage/@ord_lgh_mileage)* @routehours--)--/@ord_lgh_mileage) --* cast(ord_remark as real)
	from orderheader
	where ord_number  = (
		select ord_fromorder
		from orderheader 
		where ord_hdrnumber = @pl_ord_hdrnumber)

End

-- END CARTLO




GO
GRANT EXECUTE ON  [dbo].[CARTLO_V001_SP] TO [public]
GO
