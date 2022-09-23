SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[ps_to_e_RoutingHistory_by_invoice] (@invnumb VARCHAR(15))
AS

INSERT INTO routinghistory (TerminalNumber, OrderNumber, OrderLegNumber, PointToPointNumber, ShipperOrOrigin, Sname,
                            SAddress1, SAddress2, Scity, Scounty, Sstate, Szip, Method, ConsigneeOrDestination, Cname, 
                            CAddress1, CSAddress2, CCity, CSCounty, CSState, CSZip, DriverEmpNumber1, DriverEmpNumber2, 
                            TractorNumber, TrailerNumber, TankNumber, MilesThisLeg, StartLegDate, StopLegDate, StopCode, 
                            StopTime, RoutingHistFileNumber, Status)
     SELECT TerminalNumber, OrderNumber, OrderLegNumber, PointToPointNumber, ShipperOrOrigin, Sname,
            SAddress1, SAddress2, Scity, Scounty, Sstate, Szip, Method, ConsigneeOrDestination, Cname, 
            CAddress1, CSAddress2, CCity, CSCounty, CSState, CSZip, DriverEmpNumber1, DriverEmpNumber2, 
            TractorNumber, TrailerNumber, TankNumber, MilesThisLeg, StartLegDate, StopLegDate, StopCode, 
            StopTime, RoutingHistFileNumber, Status
       FROM ps_common.dbo.e_RoutingHistory_vw, batchesdetail 
      WHERE e_RoutingHistory_vw.OrderNumber = @invnumb
GO
GRANT EXECUTE ON  [dbo].[ps_to_e_RoutingHistory_by_invoice] TO [public]
GO
