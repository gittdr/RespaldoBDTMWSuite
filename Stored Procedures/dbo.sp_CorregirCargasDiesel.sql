SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_CorregirCargasDiesel](@fp_id varchar(5000),@odometro varchar(5000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	BEGIN
	 update [dbo].[fuelpurchased]
	 set fp_odometer = @odometro
	 where fp_id = @fp_id
		end

END



GO
