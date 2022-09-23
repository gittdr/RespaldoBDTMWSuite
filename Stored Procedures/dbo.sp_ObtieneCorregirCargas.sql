SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ObtieneCorregirCargas]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	BEGIN
	 select *, cast(fp_date as date) as fechaCarga from [dbo].[fuelpurchased]
	 where fp_odometer is not null and cast(fp_odometer as int) > 1100000
	 order by fp_odometer desc
	END
		

END



GO
