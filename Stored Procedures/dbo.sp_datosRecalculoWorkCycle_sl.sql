SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 CREATE PROCEDURE [dbo].[sp_datosRecalculoWorkCycle_sl]
	
AS
BEGIN


select top 5 ord_hdrnumber as ord_number
from orderheader 
where ord_billto in('SAYER','SAYFUL','SAYTORT') AND ord_bookedby = 'ESTAT' AND tar_number IS NULL and cast(ord_bookdate as Date) =cast(getdate() as date)


END


















GO
