SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_car_load_carrier_sp](
	@car_id varchar(8),
	@lgh_number int)
AS

/*

exec d_car_load_carrier_sp 'car1', 5423

*/

declare	@car_name		varchar(64),	
	@car_contact		varchar(25),	
	@car_phone1		char(10),	
	@car_phone3		char(10),	
	@car_email		varchar(128),	
	@currency		varchar(6),	
	@lgh_carrier_truck	varchar(50),
	@lgh_driver_name	varchar(255),
	@lgh_trailernumber	varchar(50),
	@lgh_driver_phone	varchar(25),
	@lgh_contact 		varchar(25),
	@lgh_phone		varchar(25),
	@lgh_fax		varchar(25),
	@lgh_email		varchar(128)


select  @lgh_carrier_truck = isnull(lgh_carrier_truck, ''),	
	@lgh_driver_name = isnull(lgh_driver_name, ''), 	
	@lgh_trailernumber = isnull(lgh_trailernumber, ''), 	
	@lgh_driver_phone = isnull(lgh_driver_phone, ''),	
	@lgh_contact = case when ord_booked_carrier = 'UNKNOWN' then NULL else isnull(lgh_contact, '') end,
	@lgh_phone = case when ord_booked_carrier = 'UNKNOWN' then NULL else isnull(lgh_phone, '') end,
 	@lgh_fax = case when ord_booked_carrier = 'UNKNOWN' then NULL else isnull(lgh_fax, '') end,
	@lgh_email = case when ord_booked_carrier = 'UNKNOWN' then NULL else isnull(lgh_email, '') end	
from legheader_brokered 
where lgh_number = @lgh_number 

select	@car_name = car_name,		
	@car_contact =  case when @lgh_contact is NULL then car_contact else @lgh_contact end,		
	@car_phone1 = case when @lgh_phone is NULL then car_phone1 else @lgh_phone end,		
	@car_phone3 = case when @lgh_fax is NULL then car_phone3 else @lgh_fax end,		
	@car_email = case when @lgh_email is NULL then car_email else @lgh_email end,
	@currency = (SELECT case pto_id
			when 'UNKNOWN' then car_currency
			else (select pto_currency from payto where payto.pto_id = carrier.pto_id)
		      	end
  			FROM   carrier
  			WHERE  car_id = @car_id) 		
from carrier
where car_id = @car_id

select  @car_id car_id,			
	@car_name car_name,		
	@car_contact lgh_contact,		
	@car_phone1 lgh_phone,		
	@car_phone3 lgh_fax,		
	@car_email lgh_email,		
	@currency currency,		
	@lgh_carrier_truck lgh_carrier_truck,	
	@lgh_driver_name lgh_driver_name,		
	@lgh_trailernumber lgh_trailernumber,	
	@lgh_driver_phone lgh_driver_phone, 
	@lgh_number	

GO
GRANT EXECUTE ON  [dbo].[d_car_load_carrier_sp] TO [public]
GO
