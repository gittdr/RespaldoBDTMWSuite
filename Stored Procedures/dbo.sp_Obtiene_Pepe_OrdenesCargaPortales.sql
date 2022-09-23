SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_Obtiene_Pepe_OrdenesCargaPortales]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	BEGIN
	 select * from [dbo].[Pepe_OrdenesCargaPortales] order by 1 desc
	END
		

END



GO
