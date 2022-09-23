SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_OrderCreated_JC] (@order varchar(1000),@idd varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
      INSERT INTO api_ordercreated (norder,idrecord) VALUES(@order,@idd)	
END
GO
