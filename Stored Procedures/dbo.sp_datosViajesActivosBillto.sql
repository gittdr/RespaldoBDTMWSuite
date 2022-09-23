SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 CREATE PROCEDURE [dbo].[sp_datosViajesActivosBillto](@billto varchar(1000))
	
AS
BEGIN
IF(@billto is not null)
BEGIN

	select *
	from orderheader
	where ord_billto = @billto and ord_status not in ('CMP','CAN','MST')

END


END


















GO
