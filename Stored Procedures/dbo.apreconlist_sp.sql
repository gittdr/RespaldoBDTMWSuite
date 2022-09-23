SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[apreconlist_sp] (	@ps_invoice_number varchar(50),@ps_vendor_id varchar(12),
									@ps_equipment_number varchar(20) , @pl_lgh_number int,@ps_header_status char(1))
as
create table #temp (	vendor_id varchar(12) not null,
						ap_invoice_number varchar(50) not null,
						ap_invoice_date datetime not null,
						ap_total_invoice_amount money not null,
						vendor_location tinyint not null ,
						header_status char(1) null)



If @ps_header_status = 'A' 
BEGIN
	insert into #temp (	vendor_id ,
						ap_invoice_number,
						ap_invoice_date,
						ap_total_invoice_amount,
						vendor_location,
						header_status)
	(Select				vendor_id ,
						ap_invoice_number,
						ap_invoice_date,
						ap_total_invoice_amount,
						vendor_location,
						header_status
	From				apreconheader
	Where				(vendor_id = @ps_vendor_id	or @ps_vendor_id = 'UNKNOWN') and
						(ap_invoice_number = @ps_invoice_number or @ps_invoice_number is null) and exists 
						(select * from aprecondetail d where 
						  d.header_number = apreconheader.header_number and 		
						--d.vendor_id = apreconheader.vendor_id and 
						 --d.ap_invoice_number = apreconheader.ap_invoice_number and 
						 (d.equipment_number = @ps_equipment_number or @ps_equipment_number ='UNKNOWN') and
						 (d.lgh_number = @pl_lgh_number or @pl_lgh_number is null))) 			
END
ELSE
BEGIN
	insert into #temp (	vendor_id ,
						ap_invoice_number,
						ap_invoice_date,
						ap_total_invoice_amount,
						vendor_location,
						header_status)
	(Select				vendor_id ,
						ap_invoice_number,
						ap_invoice_date,
						ap_total_invoice_amount,
						vendor_location,
						header_status
	From				apreconheader
	Where				(vendor_id = @ps_vendor_id	or @ps_vendor_id = 'UNKNOWN') and
						(ap_invoice_number = @ps_invoice_number or @ps_invoice_number is null) and 
						(header_status = @ps_header_status) and 	exists 
						(select * from aprecondetail d where 
						  d.header_number = apreconheader.header_number and 		
							--d.vendor_id = apreconheader.vendor_id and 
						 --d.ap_invoice_number = apreconheader.ap_invoice_number and 
						 (d.equipment_number = @ps_equipment_number or @ps_equipment_number ='UNKNOWN') and
						 (d.lgh_number = @pl_lgh_number or @pl_lgh_number is null))) 			

END

--update #temp set cty_nmstct = city.cty_nmstct from city where #temp.cty_code = city.cty_code

select 	vendor_id ,
		ap_invoice_number,
		ap_invoice_date,
		ap_total_invoice_amount,
		vendor_location,
		header_status
from #temp




GO
GRANT EXECUTE ON  [dbo].[apreconlist_sp] TO [public]
GO
