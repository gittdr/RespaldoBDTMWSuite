SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Eric Juarez
-- Create date: 16 nov 2018 2.17 pm 
-- Version: 4.0
-- Description:	

   /* Sentencia de prueba

       exec [sp_RecalculoOrdenesWorkCycle]
	*/

-- =============================================
CREATE PROCEDURE [dbo].[sp_RecalculoOrdenesWorkCycle]
	
AS
BEGIN

 exec [sp_RecalculoOrdenesWorkCycle_Billto] 'ALL'


END

GO
