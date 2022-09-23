SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_suggestrate_sp] 
   (@shipper_id 			varchar(8) = '',
	@shipper_name 			varchar(100) = '',
	@consignee_id 			varchar(8) = '',
	@consignee_name 		varchar(100) = '',
	@orderby_id 			varchar(8) = '',
	@orderby_name 			varchar(100) = '',
	@billto_id 				varchar(8) = '',
	@billto_name 			varchar(100) = '',
	@shipper_city 			varchar(25) = '',
	@consignee_city			varchar(25) = '',
	@shipper_city_code		int = 0,
	@consignee_city_code	int = 0,
	@delivery_date			datetime = '19500101',
	@reftype				varchar(6) = '',
	@reference_number		varchar(20) = '',
	@cmd_code				varchar(8) = '',
	@cmd_name				varchar(60) = '',
	@revtype1				varchar(10) = '',
	@revtype2				varchar(10) = '',
	@revtype3				varchar(10) = '',
	@revtype4				varchar(10) = '',
    @ord_number 			varchar(12) = '',
	@ord_remark				varchar(255) = '',
	@ord_cht_itemcode		varchar(8) = '',
	@ord_quantity			varchar(10) = '',
	@ord_rate				money = 0,
	@pickup_date			datetime = '19500101',
	@ord_charge_unit		varchar(8) = '',
	@mov_number				int = 0,
	@ord_terms				varchar(6) = '',
	@ord_mileage			int	= 0,
    @rate_msg 				varchar(255) OUT,
    @err_msg 				varchar(255) OUT
   )
AS

DECLARE 	@proctocall varchar(255),
		  @sql nvarchar(1024)
select @err_msg = '', @rate_msg = ''

SELECT  @proctocall = IsNull(gi_string1, '')
FROM 	generalinfo
WHERE 	gi_name = 'AGGSUGRATEPROC'
If @proctocall > '' 
 BEGIN
  exec @proctocall 	@shipper_id,	
					@shipper_name,
					@consignee_id,
					@consignee_name,
					@orderby_id,
					@orderby_name,
					@billto_id,
					@billto_name,
					@shipper_city,
					@consignee_city,
					@shipper_city_code,
					@consignee_city_code,
					@delivery_date,
					@reftype,
					@reference_number,
					@cmd_code,
					@cmd_name,
					@revtype1,
					@revtype2,
					@revtype3,
					@revtype4,
				    @ord_number,
					@ord_remark,
					@ord_cht_itemcode,
					@ord_quantity,
					@ord_rate,
					@pickup_date,
					@ord_charge_unit,
					@mov_number,
					@ord_terms,
					@ord_mileage,
				    @rate_msg OUTPUT,
				    @err_msg OUTPUT
  END
GO
GRANT EXECUTE ON  [dbo].[tmw_suggestrate_sp] TO [public]
GO
