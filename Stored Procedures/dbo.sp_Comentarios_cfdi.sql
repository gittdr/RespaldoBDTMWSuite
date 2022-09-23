SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Comentarios_cfdi]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	BEGIN
	 select * from [dbo].[comentarios_cfdi_jr] order by 1 desc
	END
		

END



GO
