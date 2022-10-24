SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_PullReportUpdateCPDHL] (@rrseg varchar(100),@rfecha varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
        UPDATE RtDhl SET fechaTimbrado = @rfecha WHERE segmento = @rrseg	
END
GO
