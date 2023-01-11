SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_NoregistarRegCp] (@NameFile varchar(100),@col1 varchar(200),@mensaje varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    insert into NoRegCp (folio,uuid,mensaje) 
	values(@NameFile,@col1,@mensaje)
END
GO
