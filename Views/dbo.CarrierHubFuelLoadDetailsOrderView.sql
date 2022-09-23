SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[CarrierHubFuelLoadDetailsOrderView]
AS

/*******************************************************************************************************************  
  Object Description:
  This view provides the order details needed for the Fuel Load Details page

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  10/11/2016   Chip Ciminero    WE-202583   Created
  11/21/2016   Chase Plante	  WE-202583   Correcting Settlement, NetVolumeUnit, and TotalCharge fields
*******************************************************************************************************************/

     SELECT [OrderNumber] = RTRIM(LTRIM(O.ord_number)),
            [OrderHeaderNumber] = O.ord_hdrnumber,
            [AvailableDate] = O.ord_availabledate,
            [TrailerType1] = O.ord_trailer,
            [TrailerType2] = O.ord_trailer2,
            [CommodityName] = C.cmd_name,
            [CommodityValue] = O.ord_cmdvalue,
            [TotalCount] = 0,
            [CountUnit] = '',
            [Weight] = O.ord_totalweight,
            [WeightUnit] = O.ord_totalweightunits,
            [Length] = O.ord_length,
            [LengthUnit] = O.ord_lengthunit,
            [Width] = O.ord_width,
            [WidthUnit] = O.ord_widthunit,
            [Height] = O.ord_height,
            [HeightUnit] = O.ord_heightunit,
			[LineHaulCharge] = 0,
            [InvoiceStatus] = O.ord_invoicestatus,
            [Status] = O.ord_status,
            [PickupCity] = SCI.cty_name,
            [PickUpState] = SCI.cty_state,
            [PickUpCityState] = SCI.cty_nmstct,
            [PickupZipCode] = SCI.cty_zip,
            [PickupEarliestDate] = O.ord_origin_earliestdate,
            [PickupLatestDate] = O.ord_origin_latestdate,
            [DeliveryCity] = CCI.cty_name,
            [DeliveryState] = CCI.cty_state,
            [DeliveryCityState] = CCI.cty_nmstct,
            [DeliveryZipCode] = CCI.cty_zip,
            [DeliveryEarliestDate] = O.ord_dest_earliestdate,
            [DeliveryLatestDate] = O.ord_dest_latestdate,
            [OrderRefNumber] = COALESCE(O.ord_refnum, ''),
            [BillToId] = O.ord_billto,
            [BillTo] = B.cmp_name,
            [Remark] = COALESCE(O.ord_remark, ''),
            [Remark2] = COALESCE(O.ord_remark2, ''),
            A.[GrossVolume],
            A.[GrossVolumeUnit],
            A.[NetVolume],
            A.[NetVolumeUnit],
            Miles = O.ord_totalmiles,
            [Move Number] = A.mov_number,
            [SettlementMax] = I.inv_revenue_pay,
            [TotalCharge] = O.ord_totalcharge
     FROM orderheader O
          INNER JOIN commodity C ON O.cmd_code = C.cmd_code
          LEFT OUTER JOIN company S ON O.ord_shipper = S.cmp_id
          LEFT OUTER JOIN city SCI ON S.cmp_city = SCI.cty_code
          LEFT OUTER JOIN company C1 ON O.ord_consignee = C1.cmp_id
          LEFT OUTER JOIN city CCI ON C1.cmp_city = CCI.cty_code
          LEFT OUTER JOIN company B ON O.ord_billto = B.cmp_id
          LEFT OUTER JOIN invoiceheader I ON I.ord_hdrnumber = O.ord_hdrnumber
          LEFT OUTER JOIN
     (
         SELECT S.ord_hdrnumber,
                S.mov_number,
                GrossVolume = SUM(COALESCE(F.fgt_volume, 0)),
                [GrossVolumeUnit] = COALESCE(F.[fgt_volumeunit], ''),
                [NetVolume] = SUM(COALESCE(F.[fgt_volume2], 0)),
                [NetVolumeUnit] = COALESCE(F.[fgt_volume2unit], '')
         FROM stops S
              INNER JOIN freightdetail F ON S.stp_number = F.stp_number
         GROUP BY S.ord_hdrnumber,
                  S.mov_number,
                  COALESCE(F.[fgt_volumeunit], ''),
                  COALESCE(F.[fgt_volume2unit], '')
     ) A ON O.ord_hdrnumber = A.ord_hdrnumber;
GO
GRANT DELETE ON  [dbo].[CarrierHubFuelLoadDetailsOrderView] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubFuelLoadDetailsOrderView] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierHubFuelLoadDetailsOrderView] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubFuelLoadDetailsOrderView] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubFuelLoadDetailsOrderView] TO [public]
GO
