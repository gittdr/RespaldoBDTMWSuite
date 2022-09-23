SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE  PROCEDURE [dbo].[SSRS_RB_CONFIRM_01]
		@lgh_number int
AS
--exec SSRS_RB_CONFIRM_01 650

-- Legs can have multiple orders
-- Primary order is SET off leg header for join statement on Query
-- modIFy Primary Order SELECTion to apply alternate business rules
DECLARE @PrimaryOrder AS INT
DECLARE @MoveNumber AS INT
SET @PrimaryOrder = (SELECT ord_hdrnumber FROM legheader WHERE lgh_number = @lgh_number)
SET @MoveNumber = (SELECT mov_number FROM legheader WHERE lgh_number = @lgh_number)

-- Create order list for all orders on legs
DECLARE @OrderNumbers AS VARCHAR(200)
SET @OrderNumbers = ''
SELECT  
	@OrderNumbers = @OrderNumbers + RTRIM(ISNULL(ord_number,'')) + ',' 
FROM orderheader 
WHERE orderheader.ord_hdrnumber in (SELECT DISTINCT ord_hdrnumber FROM stops 
									WHERE lgh_number = @lgh_number and stops.ord_hdrnumber > 0)
IF @OrderNumbers = '0' or @OrderNumbers = '' or @OrderNumbers = ' '
	SET @OrderNumbers = (SELECT MAX(ord_hdrnumber) FROM legheader WHERE @MoveNumber = mov_number)
IF SUBSTRING(@OrderNumbers, LEN(@OrderNumbers), 1) = ','
	SET @OrderNumbers = SUBSTRING(@OrderNumbers, 1, LEN(@OrderNumbers) -1)

-- Main SELECT
SELECT 
	car_name,
	car_id,
	ISNULL(lgh_contact,car_contact) as car_contact,
	ord_refnum,
	ord_reftype,
	CASE WHEN lb.lgh_phone is null or lb.lgh_phone = '' THEN
	SUBSTRING(car_phone1,1,3) + '-' + SUBSTRING(car_phone1,4,3) + '-' + SUBSTRING(car_phone1,7,4)
	ELSE
	SUBSTRING(lb.lgh_phone,1,3) + '-' + SUBSTRING(lb.lgh_phone,4,3) + '-' + SUBSTRING(lb.lgh_phone,7,4)	
	END AS 'Carrier Phone' ,
	ISNULL(lgh_email,car_email) as 'Carrier Email',
	CASE WHEN (lb.lgh_fax is null or lb.lgh_fax = '') THEN 
	SUBSTRING(car_phone3,1,3) + '-' + SUBSTRING(car_phone3,4,3) + '-' + SUBSTRING(car_phone3,7,4)
	WHEN SUBSTRING(lb.lgh_fax,1,5) = 'fax=9' THEN 
	SUBSTRING(lb.lgh_fax,6,3) + '-' + SUBSTRING(lb.lgh_fax,9,3) + '-' + SUBSTRING(lb.lgh_fax,12,4)
	ELSE
	SUBSTRING(lb.lgh_fax,1,3) + '-' + SUBSTRING(lb.lgh_fax,4,3) + '-' + SUBSTRING(lb.lgh_fax,7,4)
	 END AS 'Carrier Fax' ,
	@OrderNumbers as ord_number,
	@MoveNumber as movenumber,
	ShipCmp.cmp_name 'Shipper Name', 
	ISNULL(ShipCmp.cmp_address1,'') 'Shipper Add1',
	ISNULL(ShipCmp.cmp_address2,'') 'Shipper Add2',
	ShipCty.cty_name + ', ' + ShipCty.cty_state + '  ' + ISNULL(ShipCmp.cmp_zip,'') 'Shipper City',
	SUBSTRING(ShipCmp.cmp_primaryphone,1,3) + '-' + SUBSTRING(ShipCmp.cmp_primaryphone,4,3) + '-' + SUBSTRING(ShipCmp.cmp_primaryphone,7,4) as 'Shipper Phone', 
	ShipCmp.cmp_misc1 'Ship Misc1',
	ShipCmp.cmp_misc2 'Ship Misc2',
	ShipCmp.cmp_directions 'Shipper Directions',
	ISNULL(ShipCmp.cmp_service_location,'N') 'Shipper Service Location',
	ord.ord_origin_earliestdate,
	ord.ord_origin_latestdate,
	ConCmp.cmp_name 'Consignee Name', 
	ISNULL(ConCmp.cmp_address1,'') 'Consignee Add1',
	ISNULL(ConCmp.cmp_address2,'') 'Consignee Add2',
	ConCty.cty_name + ', ' + ConCty.cty_state + '  ' + ISNULL(ConCmp.cmp_zip,'') 'Consignee City',	
	SUBSTRING(ConCmp.cmp_primaryphone,1,3) + '-' + SUBSTRING(ConCmp.cmp_primaryphone,4,3) + '-' + SUBSTRING(ConCmp.cmp_primaryphone,7,4) as 'Consignee Phone',
	ConCmp.cmp_misc1 'Consignee Misc1',
	ConCmp.cmp_misc2 'Consignee Misc2',
	ConCmp.cmp_directions 'Consignee Directions',
	BillCmp.cmp_name 'Bill To Name', 
	ISNULL(BillCmp.cmp_address1,'') 'Bill To Add1',
	ISNULL(BillCmp.cmp_address2,'') 'Bill To Add2',
	BillCty.cty_name + ', ' + BillCty.cty_state + '  ' + ISNULL(BillCmp.cmp_zip,'') 'Bill To City',	
	SUBSTRING(BillCmp.cmp_primaryphone,1,3) + '-' + SUBSTRING(BillCmp.cmp_primaryphone,4,3) + '-' + SUBSTRING(BillCmp.cmp_primaryphone,7,4) as 'Bill To Phone',
	BillCmp.cmp_misc1 'Bill To Misc1',
	BillCmp.cmp_misc2 'Bill To Misc2',
	CASE WHEN ord.ord_tempunits like 'Fr%' THEN 'F'
	WHEN ord.ord_tempunits like 'C%' THEN 'C'
	ELSE ord.ord_tempunits
	END AS 'ord.ord_tempunits',
	ord.ord_mintemp,
	ord.ord_maxtemp,
	ord.ord_dest_earliestdate,
	ord.ord_dest_latestdate,
	cmd.cmd_name,
	ord.ord_remark,
	lb.lgh_carrier_truck,
	lb.lgh_driver_name,
	lb.lgh_driver_phone,
	lb.lgh_trailernumber,
	lb.lgh_contact 'legheader brokered contact',
	--dbo.TMWSSRS_fcn_referencenumbers_CRLF(ord.ord_hdrnumber, 'orderheader') as 'Order Refs',
	lb.lgh_booked_revtype1 'Confirm Broker',
	(SELECT sum(ord_totalmiles) FROM orderheader 
	 WHERE orderheader.ord_hdrnumber in (SELECT DISTINCT ord_hdrnumber FROM stops 
									WHERE lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) ord_totalmiles,
	
	(SELECT count(stp_number) FROM stops WHERE lgh_number = @lgh_number and (stp_type in ('PUP','DRP') or stp_event in ('XDL','XDU'))) as 'Stop_Count_Unique',
	(SELECT sum(ord_totalpieces) FROM orderheader 
	 WHERE orderheader.ord_hdrnumber in (SELECT DISTINCT ord_hdrnumber FROM stops 
									WHERE lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) as ord_totalpieces,
	(SELECT sum(ord_totalweight) FROM orderheader 
	 WHERE orderheader.ord_hdrnumber in (SELECT DISTINCT ord_hdrnumber FROM stops 
									WHERE lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) as ord_totalweight,
	(SELECT max(ord_totalcountunits) FROM orderheader 
	 WHERE orderheader.ord_hdrnumber in (SELECT DISTINCT ord_hdrnumber FROM stops 
									WHERE lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) ord_totalcountunits,
	(SELECT max(ord_totalweightunits) FROM orderheader 
	 WHERE orderheader.ord_hdrnumber in (SELECT DISTINCT ord_hdrnumber FROM stops 
									WHERE lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) ord_totalweightunits
FROM legheader l
	left join legheader_brokered lb on lb.lgh_number = l.lgh_number
	left join carrier car on car.car_id = l.lgh_carrier
	left join orderheader ord on ord.ord_hdrnumber = @PrimaryOrder
	left join company ShipCmp on ShipCmp.cmp_id = ord.ord_shipper
	left join city ShipCty on ShipCty.cty_code = ShipCmp.cmp_city
	left join company ConCmp on ConCmp.cmp_id = ord.ord_consignee
	left join city ConCty on ConCty.cty_code = ConCmp.cmp_city
	left join company BillCmp on BillCmp.cmp_id = ord.ord_billto
	left join city BillCty on BillCty.cty_code = ConCmp.cmp_city
	left join commodity cmd on cmd.cmd_code = ord.cmd_code
WHERE l.lgh_number = @lgh_number 



GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_CONFIRM_01] TO [public]
GO
