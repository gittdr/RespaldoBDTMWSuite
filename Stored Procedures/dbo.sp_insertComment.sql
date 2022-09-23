SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_insertComment] (@id int, @idHandleResponse varchar(5000), @idResponse varchar(5000), @mensaje varchar(5000), @fecha varchar(5000), @accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
IF(@accion = 1)
BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		-- Insert statements for procedure here
		insert into tblMessages_ResponseDirect([Id], [IdHandleResponse], [IdResponse], [Mensaje], [Fecha])
		values(@id, @idHandleResponse, @idResponse, @mensaje, @fecha)
END
END
GO
