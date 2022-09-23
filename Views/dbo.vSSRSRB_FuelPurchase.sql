SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 *
 * NAME:
 * dbo.vSSRSRB_FuelPurchase
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/

CREATE  View [dbo].[vSSRSRB_FuelPurchase]

AS

Select fp_id as [Fuel Purchase ID],
       fp_sequence as [Fuel Purchase Sequence],
       fp_purchcode as [Purchase Code],
       ord_number as [Order Number],
       mov_number as [Move Number],
       lgh_number as [Leg Number],
       stp_number as [Stop Number],
       fp_state as [State],
       fp_trc_trl as [Trc_Trl],
       trc_number as [Tractor ID],
       trl_number as [Trailer ID],
       mpp_id as [Driver ID],
       fp_owner as [Owner],
       fp_date as [Fuel Purchase Date],
       cast(fp_quantity as decimal(10,4)) as [Fuel Quantity],
       fp_uom as [Fuel UOM],
       fp_fueltype as [Fuel Type],
       fp_cost_per as [Cost Per],
       fp_amount as [Amount],
       fp_odometer as [Odometer], 
       ts_code as [Code],
       (Cast(Floor(Cast(fp_date as float))as smalldatetime)) as [Fuel Purchase Date Only],
       fp_cityname as [City],
       fp_vendorname as [Vendor Name],
       Case When fp_uom <> 'GAL' Then
		cast(fp_quantity as decimal(10,4)) * (select top 1 unc_factor from unitconversion WITH (NOLOCK) where unc_from = fp_uom and unc_to = 'GAL' and unc_convflag = 'Q')
       Else
		cast(fp_quantity as decimal(10,4))
       End as GallonsQuantity,
       [Tractor Hub Mile Reading] = Case When fp_odometer  = 0 Then
			 		(select top 1 a.fp_odometer from fuelpurchased a WITH (NOLOCK)where a.trc_number = fuelpurchased.trc_number 
			 				and a.fp_date = (select max(b.fp_date) from fuelpurchased b WITH (NOLOCK)
			 									where b.trc_number = fuelpurchased.trc_number and  fuelpurchased.fp_date > b.fp_date 
			 									and b.fp_odometer > 0)) 
				    Else
					fp_odometer
				    End,
				    (fp_amount-fp_rebateamount) as TractorNetAfterRebate,
	   cast((fp_amount-fp_rebateamount)/Case When fp_quantity = 0 Then 1 Else fp_quantity End as decimal(20,3)) as TractorNetAfterRebateCostPerGallon,
	   [Tractor Hub Miles] = 
		Case When fp_odometer  = 0 Then
			 0 Else
			fp_odometer
		  End - (select top 1 a.fp_odometer from fuelpurchased a WITH (NOLOCK) where a.trc_number = fuelpurchased.trc_number 
						and a.fp_date = (select max(b.fp_date) from fuelpurchased b WITH (NOLOCK) 
											where b.trc_number = fuelpurchased.trc_number 
											and fuelpurchased.fp_date > b.fp_date and b.fp_odometer > 0))

From   FuelPurchased WITH (NOLOCK)
       

GO
GRANT SELECT ON  [dbo].[vSSRSRB_FuelPurchase] TO [public]
GO
