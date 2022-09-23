SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[insert_aprecondetail_sp](@header_number int,
								@vendor_id varchar(12) ,
								@ap_invoice_number varchar(50) ,
								@lgh_number int ,
								@equipment_number varchar(20) ,
								@original_detail_amount money ,
								@actual_detail_amount money ,
								@force_pay_flag char(1) ,
								@short_pay_flag char(1) ,									 	
								@detail_status char(1) ,
								@comments varchar(255) ,
								@err_msg varchar(255) )
AS


	Insert into aprecondetail
		(header_number,
		vendor_id,
		ap_invoice_number,
		lgh_number,
		equipment_number,
		original_detail_amount,
		actual_detail_amount,
		force_pay_flag,
		short_pay_flag,									 	
		detail_status, 
		comments,
		err_msg
		)
	Select
		@header_number,
		@vendor_id,
		@ap_invoice_number,
		@lgh_number,
		@equipment_number,
		@original_detail_amount,
		@actual_detail_amount,
		@force_pay_flag,
		@short_pay_flag,									 	
		@detail_status, 
		@comments,
		@err_msg 

	Return @@error

GO
GRANT EXECUTE ON  [dbo].[insert_aprecondetail_sp] TO [public]
GO
