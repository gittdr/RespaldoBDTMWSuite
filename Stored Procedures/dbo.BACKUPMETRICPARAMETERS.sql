SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BACKUPMETRICPARAMETERS]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
DELETE  FROM  METRICPARAMBACKUP
INSERT INTO METRICPARAMBACKUP   SELECT  HEADING, SUBHEADING,PARMNAME,PARMSORT,PARMVALUE,PARMDESCRIPTION,FORMAT  FROM METRICPARAMETER




END
GO
