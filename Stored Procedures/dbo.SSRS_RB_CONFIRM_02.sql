SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[SSRS_RB_CONFIRM_02]
		@lgh_number int
AS

--[SSRS_Vital_Confirm]2375
-- Legs can have multiple orders
-- Primary order is set off leg header for join statement on Query
-- modify Primary Order selection to apply alternate business rules
declare @PrimaryOrder as int
declare @MoveNumber as int
set @PrimaryOrder = (select ord_hdrnumber from legheader where lgh_number = @lgh_number)
set @MoveNumber = (select mov_number from legheader where lgh_number = @lgh_number)

-- Create order list for all orders on legs
declare @OrderNumbers as varchar(200)
set @OrderNumbers = ''
select  
	@OrderNumbers = @OrderNumbers + rtrim(isnull(ord_number,'')) + ',' 
from orderheader 
where orderheader.ord_hdrnumber in (select distinct ord_hdrnumber from stops 
									where lgh_number = @lgh_number and stops.ord_hdrnumber > 0)
If @OrderNumbers = '0' or @OrderNumbers = '' or @OrderNumbers = ' '
	set @OrderNumbers = (select MAX(ord_hdrnumber) from legheader where @MoveNumber = mov_number)
if substring(@OrderNumbers, len(@OrderNumbers), 1) = ','
	set @OrderNumbers = substring(@OrderNumbers, 1, len(@OrderNumbers) -1)

--declare @IDtempLiST table (lgh_number int,Special_Instructions1 varchar(7665),Special_Instructions2 varchar(7665),Special_Instructions3 varchar(7665) )
--insert into @IDtempLiST (lgh_number,Special_Instructions1,Special_Instructions2,Special_Instructions3)
select lgh_number as lgh_number,
(select top 1 col_data from EXTRA_INFO_DATA where EXTRA_ID = 5 and TABLE_KEY = ord_shipper) as Special_Instructions1,
Case When ord_consignee <> ord_shipper 
	then (select top 1 col_data from EXTRA_INFO_DATA where EXTRA_ID = 5 and TABLE_KEY = ord_consignee)
	Else NULL 
	end as Special_Instructions2,
Case When (orderheader.ord_billto <> ord_consignee) and (orderheader.ord_billto <> ord_shipper) then
	(select top 1 col_data from EXTRA_INFO_DATA where EXTRA_ID = 5 and TABLE_KEY = orderheader.ord_billto)
	else NULL
	end as Special_Instructions3
into #idtemplist
 from orderheader
 join legheader on legheader.ord_hdrnumber = orderheader.ord_hdrnumber
  where legheader.lgh_number  =  @lgh_number

-- Main Select

select 
	car_name,
	car_id,
	car_iccnum,
	isnull(lgh_contact,car_contact) as car_contact,
	ord_refnum,
	ord_reftype,
	Case when lb.lgh_phone is null or lb.lgh_phone = '' then
	substring(car_phone1,1,3) + '-' + substring(car_phone1,4,3) + '-' + substring(car_phone1,7,4)
	else
	substring(lb.lgh_phone,1,3) + '-' + substring(lb.lgh_phone,4,3) + '-' + substring(lb.lgh_phone,7,4)	
	end as 'Carrier Phone' ,
	isnull(lgh_email,car_email) as 'Carrier Email',
	case when (lb.lgh_fax is null or lb.lgh_fax = '') then 
	substring(car_phone3,1,3) + '-' + substring(car_phone3,4,3) + '-' + substring(car_phone3,7,4)
	when substring(lb.lgh_fax,1,5) = 'fax=9' then 
	substring(lb.lgh_fax,6,3) + '-' + substring(lb.lgh_fax,9,3) + '-' + substring(lb.lgh_fax,12,4)
	else
	substring(lb.lgh_fax,1,3) + '-' + substring(lb.lgh_fax,4,3) + '-' + substring(lb.lgh_fax,7,4)
	 end as 'Carrier Fax' ,
	@OrderNumbers as ord_number,
	
	ShipCmp.Cmp_id 'Shipper ID',
	ShipCmp.cmp_name 'Shipper Name', 
	isnull(ShipCmp.cmp_address1,'') 'Shipper Add1',
	isnull(ShipCmp.cmp_address2,'') 'Shipper Add2',
	ShipCty.cty_name + ', ' + ShipCty.cty_state + '  ' + isnull(ShipCmp.cmp_zip,'') 'Shipper City',
	substring(ShipCmp.cmp_primaryphone,1,3) + '-' + substring(ShipCmp.cmp_primaryphone,4,3) + '-' + substring(ShipCmp.cmp_primaryphone,7,4) as 'Shipper Phone', 
	ShipCmp.cmp_misc1 'Ship Misc1',
	ShipCmp.cmp_misc2 'Ship Misc2',
	ShipCmp.cmp_directions 'Shipper Directions',
	ord.ord_origin_earliestdate,
	ord.ord_origin_latestdate,
	isnull(ShipCmp.cmp_service_location,'N') 'Shipper Service Location',
	Special_Instructions1 'Shipper Special Instructions',
	
	ConCmp.Cmp_id 'Consignee ID',
	ConCmp.cmp_name 'Consignee Name', 
	isnull(ConCmp.cmp_address1,'') 'Consignee Add1',
	isnull(ConCmp.cmp_address2,'') 'Consignee Add2',
	ConCty.cty_name + ', ' + ConCty.cty_state + '  ' + isnull(ConCmp.cmp_zip,'') 'Consignee City',	
	substring(ConCmp.cmp_primaryphone,1,3) + '-' + substring(ConCmp.cmp_primaryphone,4,3) + '-' + substring(ConCmp.cmp_primaryphone,7,4) as 'Consignee Phone',
	ConCmp.cmp_misc1 'Consignee Misc1',
	ConCmp.cmp_misc2 'Consignee Misc2',
	ConCmp.cmp_directions 'Consignee Directions',
	isnull(ConCmp.cmp_service_location,'N') 'Consignee Service Location',
	Special_Instructions2 'Consignee Special Instructions',
	
	BillCmp.cmp_name 'Bill To Name', 
	isnull(BillCmp.cmp_address1,'') 'Bill To Add1',
	isnull(BillCmp.cmp_address2,'') 'Bill To Add2',
	BillCty.cty_name + ', ' + BillCty.cty_state + '  ' + isnull(BillCmp.cmp_zip,'') 'Bill To City',	
	substring(BillCmp.cmp_primaryphone,1,3) + '-' + substring(BillCmp.cmp_primaryphone,4,3) + '-' + substring(BillCmp.cmp_primaryphone,7,4) as 'Bill To Phone',
	BillCmp.cmp_misc1 'Bill To Misc1',
	BillCmp.cmp_misc2 'Bill To Misc2',
	isnull(BillCmp.cmp_service_location,'N') 'BT Service Location',
	special_instructions3 'BT Special Instructions',
	
	ord.ord_dest_earliestdate,
	ord.ord_dest_latestdate,
	Case When ord.ord_tempunits like 'Fr%' then 'F'
		When ord.ord_tempunits like 'C%' then 'C'
		else ord.ord_tempunits
		end as 'ord.ord_tempunits',
	ord.ord_mintemp,
	ord.ord_maxtemp,
	cmd.cmd_name,
	ord.ord_remark,
	lb.lgh_carrier_truck,
	lb.lgh_driver_name,
	lb.lgh_driver_phone,
	lb.lgh_trailernumber,
	lb.lgh_contact 'legheader brokered contact',
	dbo.TMWSSRS_fcn_referencenumbers_CRLF(ord.ord_hdrnumber, 'orderheader') as 'Order Refs',
	BB.brn_name as 'Confirm Broker',
	('(' + substring(BB.brn_fax,1,3) + ')' + substring(BB.brn_fax,4,3) + '-' + substring(BB.brn_fax,7,4)) as 'BRNFax',
	--BB.brn_fax as 'BRNFax',
	('(' + substring(BB.brn_phone,1,3) + ')' + substring(BB.brn_phone,4,3) + '-' + substring(BB.brn_phone,7,4)) as 'BRNPhone',
	BB.brn_email as 'BRNEmail',
	PB.brn_fax as 'PBBRNFax',
	PB.brn_phone as 'PBBRNPhone',
	BB.brn_billinginfo as 'BRNBillingInfo',
	UT.usr_fname + ' ' + UT.usr_lname as LoadPlanner,
	UT.usr_contact_number as ContactNumber,
	UT.usr_mail_address as ContactEmail,
	l.lgh_class1 'RevType1',
	l.lgh_class2 'RevType2',
	--(select name from labelfile where abbr = l.lgh_class2 and labeldefinition = 'revtype2') as 'RevType2_name',
	L.mov_number 'MoveNumber',
	
	(select sum(ord_totalmiles) from orderheader 
	 where orderheader.ord_hdrnumber in (select distinct ord_hdrnumber from stops 
									where lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) ord_totalmiles,
	
	(select count(stp_number) from stops where lgh_number = @lgh_number and (stp_type in ('PUP','DRP') or stp_event in ('XDL','XDU'))) as 'Stop_Count_Unique',
	(select sum(ord_totalpieces) from orderheader 
	 where orderheader.ord_hdrnumber in (select distinct ord_hdrnumber from stops 
									where lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) as ord_totalpieces,
	(select sum(ord_totalweight) from orderheader 
	 where orderheader.ord_hdrnumber in (select distinct ord_hdrnumber from stops 
									where lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) as ord_totalweight,
	(select max(ord_totalcountunits) from orderheader 
	 where orderheader.ord_hdrnumber in (select distinct ord_hdrnumber from stops 
									where lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) ord_totalcountunits,
	(select max(ord_totalweightunits) from orderheader 
	 where orderheader.ord_hdrnumber in (select distinct ord_hdrnumber from stops 
									where lgh_number = @lgh_number and stops.ord_hdrnumber > 0)) ord_totalweightunits,
	--(SELECT [name] FROM labelfile WHERE labeldefinition = 'TrlType1' AND abbr = ord.trl_type1) as trl_type1_desc
		(select name from labelfile where abbr = l.lgh_class2 and labeldefinition = 'revtype2') as trl_type1_desc
	
from legheader l
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
	left join branch BB on brn_id = ord.ord_booked_revtype1
	left join branch PB on BB.brn_parent = PB.brn_id
	left join #IDtempLiST on L.lgh_number = #IDtempLiST.lgh_number 
	left join ttsusers UT on usr_userid = ord.ord_bookedby
where l.lgh_number = @lgh_number 

drop table #idtemplist

GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_CONFIRM_02] TO [public]
GO
