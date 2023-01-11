SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_registarCp] (@NameFile varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    insert into InsertCp (folio) values(@NameFile)
END
GO
