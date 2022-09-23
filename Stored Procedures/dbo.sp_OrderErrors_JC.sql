SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_OrderErrors_JC] (@order varchar(1000),@msg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
      INSERT INTO api_ordererrors (norder,msg) VALUES(@order,@msg)	
END
GO
