SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Invoice_Header_JC]
		@leg char(18),
		@fecha varchar(100)
AS

DECLARE	
	@mensaje varchar(100);
SET NOCOUNT ON

SET @mensaje = 'Timbrada - ' + @fecha
BEGIN 
     
			exec notes_add_sp 'invoiceheader',@leg,@mensaje,null,'N',null
END

GO
