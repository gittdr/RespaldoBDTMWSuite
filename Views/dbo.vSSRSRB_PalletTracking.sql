SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE          View [dbo].[vSSRSRB_PalletTracking] 
As
/**
 *
 * NAME:
 * dbo.vSSRSRB_PalletTracking
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
Select
	pt_tractor_number as Tractor,
	pt_trailer_number as Trailer,
	pt_carrier_id as [Carrier ID],
	'Carrier Name' = (select car_name from carrier WITH (NOLOCK) where car_id = pt_carrier_id),
	pt_company_id as [Company ID],
	'Company Name' = (select cmp_name from company WITH (NOLOCK) where cmp_id = pt_company_id),
	pt_pallets_in as [Pallets In],
	pt_pallets_out as [Pallets Out],
	pt_hand_count as [Hand Count], 
	pt_pallet_type as [Pallet Type],
	'Pallet Type Description' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = pt_pallet_type and labeldefinition = 'PalletType'),''),
	--**Activity Date**
	pt_activity_date as 'Activity Date', 
	--Day
	(Cast(Floor(Cast([pt_activity_date] as float))as smalldatetime)) as [Activity Date Only], 
	Cast(DatePart(yyyy,[pt_activity_date]) as varchar(4)) +  '-' + Cast(DatePart(mm,[pt_activity_date]) as varchar(2)) + '-' + Cast(DatePart(dd,[pt_activity_date]) as varchar(2)) as [Activity Day],
	--Month
        Cast(DatePart(mm,[pt_activity_date]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[pt_activity_date]) as varchar(4)) as [Activity Month],
        DatePart(mm,[pt_activity_date]) as [Activity Month Only],
        --Year
        DatePart(yyyy,[pt_activity_date]) as [Activity Year], 
	pt_fgt_number as [Freight Detail Number],
	pt_identity as PalletIdentity,
	pt_ord_number as [Order Number],
	pt_comments as Comments,
	pt_entry_type as [Entry Type],
	[Branch] = (Select ord_booked_revtype1 from orderheader WITH (NOLOCK) where orderheader.ord_number = pt_ord_number)
     

From    Pallet_Tracking



GO
GRANT DELETE ON  [dbo].[vSSRSRB_PalletTracking] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_PalletTracking] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_PalletTracking] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_PalletTracking] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_PalletTracking] TO [public]
GO
