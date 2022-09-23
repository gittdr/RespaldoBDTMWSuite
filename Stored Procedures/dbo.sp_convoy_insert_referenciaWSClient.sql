SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_convoy_insert_referenciaWSClient] (@ord_hdrnumber varchar(500), @wsRefnum varchar(500) )
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

    update [dbo].[convoy360_ViajesClienteAPI] set [wsRefnum] = @wsRefnum
	where [ord_hdrnumber] = @ord_hdrnumber

end
GO
