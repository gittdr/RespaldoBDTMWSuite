SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  View [dbo].[vSSRSRB_FreightDetail]

As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_FreightDetail]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Freightdetail view
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_FreightDetail]


**************************************************************************
 * RETURNS:
 * Resultset
 *
 * RESULT SETS:
 * Freightdetail table items
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created view
 **/

Select
	[fgt_number] as [Freight Detail Number],
	[cmd_code] as [Freight Detail Commodity Code],
	[fgt_weight] as [Freight Detail Weight],
	[fgt_weightunit] as [Freight Detail Weight Unit],
	[fgt_description] as [Freight Detail Description],
	[stp_number] as [Freight Detail Stop Number],
	[fgt_count] as [Freight Detail Count],
	[fgt_countunit] as [Freight Detail Count Unit],
	[fgt_volume] as [Freight Detail Volume],
	[fgt_volumeunit] as [Freight Detail Volume Unit],
	[fgt_lowtemp] as [Freight Detail Low Temp],
	[fgt_hitemp] as [Freight Detail High Temp],
	[fgt_sequence] as [Freight Detail Sequence],
	[fgt_length] as [Freight Detail Length],
	[fgt_lengthunit] as [Freight Detail Length Unit],
	[fgt_height] as [Freight Detail Height],
	[fgt_heightunit] as [Freight Detail Height Unit],
	[fgt_width] as [Freight Detail Width],
	[fgt_widthunit] as [Freight Detail Width Unit],
	[fgt_reftype] as [Freight Detail RefType],
	[fgt_refnum] as [Freight Detail RefNum],
	[fgt_quantity] as [Freight Detail Quantity],
	[fgt_rate] as [Freight Detail Rate],
	[fgt_charge] as [Freight Detail Charge],
	[fgt_rateunit] as [Freight Detail Rate Unit],
	[cht_itemcode]  as [Freight Detail ChargeType],
	[cht_basisunit] as [Freight Detail ChargeType Basis],
	[fgt_unit] as [Freight Detail ChargeType Unit],
	[skip_trigger] as [Freight Detail Skip Trigger],
	[tare_weight] as [Freight Detail Tare Weight],
	[tare_weightunit] as [Freight Detail Tare Weight Unit],
	[fgt_pallets_in] as [Freight Detail Pallets In],
	[fgt_pallets_out] as [Freight Detail Pallets Out],
	[fgt_pallets_on_trailer] as [Freight Detail Pallets OnTrailer],
	[fgt_carryins1] as [Freight Detail CarryIns1],
	[fgt_carryins2] as [Freight Detail CarryIns2],
	[fgt_stackable] as [Freight Detail Stackable],
	[fgt_ratingquantity] as [Freight Detail Rating Quantity],
	[fgt_ratingunit] as [Freight Detail Rating Unit],
	[fgt_quantity_type] as [Freight Detail Quantity Type],
	[fgt_ordered_count]  as [Freight Detail Ordered Count],
	[fgt_ordered_weight] as [Freight Detail Ordered Weight],
	[tar_number]  as [Freight Detail Tar Number],
	[tar_tariffnumber] as [Freight Detail Tariff Number],
	[tar_tariffitem] as [Freight Detail Tariff Item],
	[fgt_charge_type] as [Freight Detail Charge Type],
	[fgt_rate_type] as [Freight Detail Rate Type],
	
		-- Added 2-10-2011
	  fgt_osdamtpaid as [OSD Amount Paid],
      fgt_osdamtreceived as [OSD Amount Received],
      fgt_osdclosedate as [OSD Closed Date],
      (Cast(Floor(Cast(fgt_osdclosedate as float))as smalldatetime)) AS [OSD Closed Date Only],
      fgt_osdcomment as [OSD Comment],
      fgt_osdopendate as [OSD Open Date],
      (Cast(Floor(Cast(fgt_osdopendate as float))as smalldatetime)) AS [OSD Open Date Only],
      fgt_osdorigclaimamount as [OSD Original Claim Amount],
      fgt_osdquantity as [OSD Quantity],
      fgt_osdreason as [OSD Reason],
      fgt_osdstatus as [OSD Status],
      fgt_osdunit as [OSD Unit],
		-- End Added 2-10-2011
		
	[Freight Detail Commodity Class Code]= (select cmd_class from commodity WITH (NOLOCK) where commodity.cmd_code = freightdetail.cmd_code),
	[Freight Detail Commodity Class Name]= (select ccl_description from commodity WITH (NOLOCK),commodityclass (NOLOCK) where commodityclass.ccl_code = commodity.cmd_code and commodity.cmd_code = freightdetail.cmd_code)
from    freightdetail (NOLOCK)

GO
GRANT SELECT ON  [dbo].[vSSRSRB_FreightDetail] TO [public]
GO
