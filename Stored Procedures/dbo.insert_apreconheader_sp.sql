SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[insert_apreconheader_sp](
								@vendor_id varchar(12) ,
								@vendor_location tinyint,	
								@ap_invoice_number varchar(50) ,
								@ap_invoice_date datetime ,
								@ap_total_invoice_amount money ,
								@rail_motor_flag char(1) ,
								@header_status char(1) ,
								@ap_source char(1)  , 
								@comments varchar(255) ,
								@err_msg varchar(255) ,	
								@matched_to_extract char(1) )
AS
declare @ll_hdr int,@ll_city int,@li_ret int
declare @ls_nmstct varchar(30)

	select @ll_hdr = Isnull(max(header_number),0) + 1 from apreconheader

/*	select @ll_city = pto_city   from payto where pto_id = @vendor_id
	If @ll_city > 0 
		select @ls_nmstct = cty_nmstct   from city where cty_code = @ll_city
	else
		select @ll_city = 0 , @ls_nmstct = 'UNKNOWN'
*/

	Insert into apreconheader
	(header_number,
	vendor_id,
	vendor_location,
	ap_invoice_number,
	ap_invoice_date,
	ap_total_invoice_amount,
--	vendor_city,
--	vendor_nmstct,
	rail_motor_flag,
	header_status,
	ap_source,
	comments,
	err_msg,
	matched_to_extract
	)
	Select 
	@ll_hdr,
	@vendor_id,
	@vendor_location,
	@ap_invoice_number,
	@ap_invoice_date,
	@ap_total_invoice_amount,
--	@ll_city,
--	@ls_nmstct,
	@rail_motor_flag,
	@header_status,
	@ap_source,
	@comments,
	@err_msg,
	@matched_to_extract

	Return @@error

GO
GRANT EXECUTE ON  [dbo].[insert_apreconheader_sp] TO [public]
GO
