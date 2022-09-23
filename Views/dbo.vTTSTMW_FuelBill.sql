SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE           View [dbo].[vTTSTMW_FuelBill] 

As

--1. Joined to trl_id instead of trl_number 
     --also added min to avoid subquery error
     --Ver 5.1 LBK

SELECT     cfb_accountid as 'AccountID',
	   cfb_customerid as 'Customer ID', 
           cfb_transdate as 'Transaction Date', 
           cfb_transnumber as 'Transaction Number', 
           cfb_unitnumber as 'Tractor ID', 
           'TrcType1' = IsNull((select trc_type1 from tractorprofile (NOLOCK) where trc_number = cfb_unitnumber),''),
           'TrcType1 Name' = IsNull((select name from labelfile (NOLOCK) ,tractorprofile (NOLOCK) where labelfile.abbr = trc_type1 and labeldefinition = 'TrcType1' and trc_number = cfb_unitnumber),''),
           'TrcType2' = IsNull((select trc_type2 from tractorprofile (NOLOCK) where trc_number = cfb_unitnumber),''),
           'TrcType2 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK)where labelfile.abbr = trc_type2 and labeldefinition = 'TrcType2' and trc_number = cfb_unitnumber),''),
           'TrcType3' = IsNull((select trc_type3 from tractorprofile (NOLOCK) where trc_number = cfb_unitnumber),''),
           'TrcType3 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type3 and labeldefinition = 'TrcType3' and trc_number = cfb_unitnumber),''),
           'TrcType4'= IsNull((select trc_type4 from tractorprofile (NOLOCK) where trc_number = cfb_unitnumber),''),
           'TrcType4 Name' = IsNull((select name from labelfile (NOLOCK),tractorprofile (NOLOCK) where labelfile.abbr = trc_type4 and labeldefinition = 'TrcType4' and trc_number = cfb_unitnumber),''),       
           cfb_truckstopcode as 'Truck Stop Code', 
           cfb_truckstopinvoicenumber as 'Truck Stop Invoice Number', 
           cfb_totaldue as 'Total Due', 
           cfb_feefueloilproducts as 'Fee Fuel Oil Products', 
           convert(decimal(15,1),cfb_trcgallons) as 'Tractor Gallons', 
           cfb_trccostpergallon as 'Tractor Cost Per Gallon', 
           cfb_trccost as 'Tractor Cost', 
           cfb_reefergallons as 'Reefer Gallons', 
           cfb_reefercostpergallon as 'Reefer Cost Per Gallon', 
           cfb_reefercost as 'Reefer Cost', 
           cfb_oilquarts as 'Oil Quarts', 
           cfb_oilcost as 'Oil Cost', 
           cfb_advanceamt as 'Advance Amount', 
           cfb_advancecharge as 'Advance Charge', 
           cfb_tripnumber as 'Trip Number', 
           cfb_cardnumber as 'Card Number', 
           cfb_employeenum as 'Employee Number', 
           cfb_rebateamount as 'Rebate Amount', 
           cfb_focusorselect as 'Focus or Select', 
           cfb_truckstopname as 'Truck Stop Name', 
           cfb_truckstopcityname as 'Truck Stop City Name', 
           cfb_truckstopstate as 'Truck Stop State', 
           cfb_currencytype as 'Currency Type', 
           cfb_nonbillableitem as 'Non Billable Item', 
           cfb_productamt1 as 'Product Amount1', 
           cfb_productamt2 as 'Product Amount2', 
           cfb_productamt3 as 'Product Amount3', 
           cfb_trailernumber as 'Trailer ID', 
	   'TrlType1' = IsNull((select min(trl_type1) from trailerprofile (NOLOCK) where trl_id = cfb_trailernumber),''),
           'TrlType1 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1' and  trl_id = cfb_trailernumber),''),
           'TrlType2' = IsNull((select min(trl_type2) from trailerprofile (NOLOCK) where  trl_id = cfb_trailernumber),''),
           'TrlType2 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type2 and labeldefinition = 'TrlType2' and  trl_id = cfb_trailernumber),''),
           'TrlType3' = IsNull((select min(trl_type3) from trailerprofile (NOLOCK) where  trl_id = cfb_trailernumber),''),
           'TrlType3 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type3 and labeldefinition = 'TrlType3' and  trl_id = cfb_trailernumber),''),
	   'TrlType4'= IsNull((select min(trl_type4) from trailerprofile (NOLOCK) where trl_id = cfb_trailernumber),''),
           'TrlType4 Name' = IsNull((select min(name) from labelfile (NOLOCK),trailerprofile (NOLOCK) where labelfile.abbr = trl_type4 and labeldefinition = 'TrlType4' and  trl_id = cfb_trailernumber),''),       
           --cfb_trchubmiles as 'Tractor Hub Mile Reading', 
           [Tractor Hub Mile Reading] = Case When cfb_trchubmiles  = 0 Then
			 (select top 1 a.cfb_trchubmiles from cdfuelbill a where a.cfb_unitnumber = cdfuelbill.cfb_unitnumber and a.cfb_transdate = (select max(b.cfb_transdate) from cdfuelbill b where b.cfb_unitnumber = cdfuelbill.cfb_unitnumber and  cdfuelbill.cfb_transdate > b.cfb_transdate and b.cfb_trchubmiles > 0)) Else
			cfb_trchubmiles
		  End,
         

           cfb_network_ts as 'Network TS', 
           cfb_ProductCode1 as 'ProductCode1', 
           cfb_ProductCode2 as 'ProductCode2', 
           cfb_ProductCode3 as 'ProductCode3', 
           cfb_ProductCode4 as 'ProductCode4', 
           cfb_ProductAmount4 as 'Product Amount4', 
           cfb_tax1 as 'Tax1', 
           cfb_tax2 as 'Tax2', 
           cfb_tax3 as 'Tax3', 
           cfb_tax4 as 'Tax4',
      	   (cfb_trccost-cfb_rebateamount) as TractorNetAfterRebate,
	   cast((cfb_trccost-cfb_rebateamount)/Case When cfb_trcgallons = 0 Then 1 Else cfb_trcgallons End as decimal(20,3)) as TractorNetAfterRebateCostPerGallon,
	   [Tractor Hub Miles] = 
		Case When cfb_trchubmiles  = 0 Then
			 (select top 1 a.cfb_trchubmiles from cdfuelbill a where a.cfb_unitnumber = cdfuelbill.cfb_unitnumber and a.cfb_transdate = (select max(b.cfb_transdate) from cdfuelbill b where b.cfb_unitnumber = cdfuelbill.cfb_unitnumber and  cdfuelbill.cfb_transdate > b.cfb_transdate and b.cfb_trchubmiles > 0)) Else
			cfb_trchubmiles
		  End - (select top 1 a.cfb_trchubmiles from cdfuelbill a where a.cfb_unitnumber = cdfuelbill.cfb_unitnumber and a.cfb_transdate = (select max(b.cfb_transdate) from cdfuelbill b where b.cfb_unitnumber = cdfuelbill.cfb_unitnumber and  cdfuelbill.cfb_transdate > b.cfb_transdate and b.cfb_trchubmiles > 0))
         


FROM         dbo.cdfuelbill (NOLOCK)












GO
GRANT SELECT ON  [dbo].[vTTSTMW_FuelBill] TO [public]
GO
