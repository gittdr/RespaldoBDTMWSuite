SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[ps_to_e_invoices_by_invoice] (@invnumb VARCHAR(15))
AS

INSERT INTO invoices (OrderNumber, TerminalNumber, LoadNumber, CompanyCode, BillToNumber, BillToName, Address1, Address2, 
                      City, State, Zip, OrderTakenDate, OrderTakerEmpNo, ShipperOrderNumber, PONumber, BillOfLadingNumber,
                      RouteMiles, RateMiles, ActualPickupDate, ActualPickupTime, ActualSpotDate, ActualSpotTime, 
                      ActualDeliveryDate, ActualDeliveryTime, QualityPUMsg, QualityPUCode, QualityDelvMsg, QualityDelvCode,
                      QualitySpotMsg, QualitySpotCode, SchedLoadPickupDate, SchedLoadPickupTime, SchedSpotDate, SchedSpotTime, 
                      SchedLoadDeliveryDate, SchedLoadDeliveryTime, Dispatched, Incomplete, DOTSpecCode, TrailerLinerCode,
                      IntranHeat, Insulated, PrepaidOrCollect, LoadASAP, EarlyLoadingArrivalTime, LatestLoadingArrivalTime,
                      LatestLoadedDepartTime, UnLoadASAP, EarlyDeliverTime, LatestDeliverTime, FirstShipperName, 
                      FirstShipperCity, FirstShipperState, FirstShipperZip, LastConsigneeName, LastConsigneeCity, 
                      LastConsigneeState, LastConsigneeZip, AltConsigneeNumber, BlindConsignee, CAltConsigneename, 
                      CAltAddress1, CAltAddress2, CAltCity, CAltState, CAltZip, BlindShipper, AltShipperNumber, 
                      SAltConsigneename, SAltAddress1, SAltAddress2, SAltCity, SAltState, SAltZip, STCCode1, STCCode2, 
                      STCCode3, STCCode4, STCCode5, STCCode6, Product1, Product2, Product3, Product4, Product5, Product6,
                      Hazard, RateCalcCode, Rate, Tariff, Item, FlatFeeTotalAmount, LoadNOI, EDI, CurrentMinimum1, 
                      CurrentMinimum2, CurrentMinimum3, CurrentRate1, CurrentRate2, CurrentRate3, EffectiveRateDate, 
                      InsuranceSurcharge, BackHaul, UnloadType, SteamRequired, TotalAmountBilled, DateBilled, IsPrinted,
                      DatePrinted, Cancelled, TotalLineHaul, GrossWeight, NetWeight, TareWeight, BillAsWeight, RemitTo1, 
                      RemitTo2, RemitTo3, RemitTo4, Mexico, Hours, CUSTCustName, CUSTCustNumber, Attention, ProcessedDate,
                      AccountingPeriod, AccountingYear, OtherTractor, OtherTrailer, OtherTank, Spot, PULoadingTime, 
                      PUDepartLoadedTime, DELDepartEmptyTime, UnloadDeliveryTime, PUStartLoadingTime, DelStartUnldTime,
                      ProcessBatch)
     SELECT OrderNumber, TerminalNumber, LoadNumber, CompanyCode, BillToNumber, BillToName, Address1, Address2, 
            City, State, Zip, OrderTakenDate, OrderTakerEmpNo, ShipperOrderNumber, PONumber, BillOfLadingNumber,
            RouteMiles, RateMiles, ActualPickupDate, ActualPickupTime, ActualSpotDate, ActualSpotTime, 
            ActualDeliveryDate, ActualDeliveryTime, QualityPUMsg, QualityPUCode, QualityDelvMsg, QualityDelvCode,
            QualitySpotMsg, QualitySpotCode, SchedLoadPickupDate, SchedLoadPickupTime, SchedSpotDate, SchedSpotTime, 
            SchedLoadDeliveryDate, SchedLoadDeliveryTime, Dispatched, Incomplete, DOTSpecCode, TrailerLinerCode,
            IntranHeat, Insulated, PrepaidOrCollect, LoadASAP, EarlyLoadingArrivalTime, LatestLoadingArrivalTime,
            LatestLoadedDepartTime, UnLoadASAP, EarlyDeliverTime, LatestDeliverTime, FirstShipperName, 
            FirstShipperCity, FirstShipperState, FirstShipperZip, LastConsigneeName, LastConsigneeCity, 
            LastConsigneeState, LastConsigneeZip, AltConsigneeNumber, BlindConsignee, CAltConsigneename, 
            CAltAddress1, CAltAddress2, CAltCity, CAltState, CAltZip, BlindShipper, AltShipperNumber, 
            SAltConsigneename, SAltAddress1, SAltAddress2, SAltCity, SAltState, SAltZip, STCCode1, STCCode2, 
            STCCode3, STCCode4, STCCode5, STCCode6, Product1, Product2, Product3, Product4, Product5, Product6,
            Hazard, RateCalcCode, Rate, Tariff, Item, FlatFeeTotalAmount, LoadNOI, EDI, CurrentMinimum1, 
            CurrentMinimum2, CurrentMinimum3, CurrentRate1, CurrentRate2, CurrentRate3, EffectiveRateDate, 
            InsuranceSurcharge, BackHaul, UnloadType, SteamRequired, TotalAmountBilled, DateBilled, IsPrinted,
            DatePrinted, Cancelled, TotalLineHaul, GrossWeight, NetWeight, TareWeight, BillAsWeight, RemitTo1, 
            RemitTo2, RemitTo3, RemitTo4, Mexico, Hours, CUSTCustName, CUSTCustNumber, Attention, ProcessedDate,
            AccountingPeriod, AccountingYear, OtherTractor, OtherTrailer, OtherTank, Spot, PULoadingTime, 
            PUDepartLoadedTime, DELDepartEmptyTime, UnloadDeliveryTime, PUStartLoadingTime, DelStartUnldTime,
            ProcessBatch 
       FROM ps_common.dbo.e_Invoices_vw, batchesdetail 
      WHERE e_Invoices_vw.OrderNumber = @invnumb
GO
GRANT EXECUTE ON  [dbo].[ps_to_e_invoices_by_invoice] TO [public]
GO
