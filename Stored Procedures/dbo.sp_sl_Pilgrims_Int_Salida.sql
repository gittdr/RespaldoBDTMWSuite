SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_Int_Salida] (@dato varchar(5000),@IdCampo varchar(500) , @ConjuntoDatos varchar(500))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--select * from notes where ntb_table = 'orderheader' and nre_tablekey ='587850' and not_type is null 

	SET NOCOUNT ON;
declare @texto varchar(100) 
IF(@ConjuntoDatos = 'ArchivoProcesado')
BEGIN

update [dbo].[RCSAYER]
set [Estatus] = 'Procesado'
 where [narchivo] =@IdCampo;

END


END
GO
