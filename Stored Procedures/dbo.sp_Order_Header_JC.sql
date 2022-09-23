SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Order_Header_JC]
		@leg char(18),
		@fecha varchar(100)
AS

DECLARE	
	@mensaje varchar(100);
SET NOCOUNT ON

SET @mensaje = 'Timbrada - ' + @fecha
BEGIN 
     
			exec notes_add_sp 'orderheader',@leg,@mensaje,null,'N',null
END
GO
