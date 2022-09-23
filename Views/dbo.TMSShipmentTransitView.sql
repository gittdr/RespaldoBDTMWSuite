SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSShipmentTransitView]
AS
SELECT 
 TMSTransit.TransitID,
 TMSTransit.Mode,
 TMSTransit.ServiceLevel,
 TMSTransit.Carrier,
 TMSTransit.TransitCalcId,
 TMSTransitCalculation.Name as TransitCalculationName,
 TMSTransitCalculation.TransitRule as TransitCalculationRule,
 TMSTransit.[Description],
 TMSTransit.CarrierRating
FROM
 TMSTransit 
  inner join TMSTransitCalculation on TMSTransit.TransitCalcId = TMSTransitCalculation.TransitCalcID
GO
GRANT SELECT ON  [dbo].[TMSShipmentTransitView] TO [public]
GO
