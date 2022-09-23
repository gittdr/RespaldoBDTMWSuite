SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_Rechazar] (@ord_header varchar(50), @Evidencia varchar(50),@Status varchar(50), @Razon varchar(50), @ConjuntoDatos varchar(50))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--select * from notes where ntb_table = 'orderheader' and nre_tablekey ='587850' and not_type is null 

	SET NOCOUNT ON;
declare @texto varchar(100) 
IF(@ConjuntoDatos = 'eliminaDatos')
BEGIN
	--borrar datos pasados
	delete notes where not_number in (Select not_number from notes where ntb_table = 'orderheader' and not_text like '%||%' and nre_tablekey = @ord_header );
	update orderheader 
	set ord_invoicestatus = 'AVL'
	where  LTRIM(RTRIM(ord_number))  = @ord_header;


END
IF(@ConjuntoDatos = 'rechazoEvidencias')
BEGIN

--prepara la concatenacion de la nota
	
	set @texto = @Evidencia + '||' + @Status +  '||' + @Razon;
--ejecutar el procedimiento para insertar la nota	
	
	exec dx_add_note 'ORDEN', @ord_header,1,1,@texto,'N',null,'SA';
	--exec dx_add_note 'ORDEN', '587850',1,1,'test','N',null,'SA'
	update orderheader 
	set ord_invoicestatus = 'XIN'
	where  LTRIM(RTRIM(ord_number)) = @ord_header
END
IF(@ConjuntoDatos = 'rechazoKMSCasetas')
BEGIN
	
--prepara la concatenacion de la nota
	set @texto = @Evidencia + '||' + @Status +  '||' + @Razon
--ejecutar el procedimiento para insertar la nota	
	
	exec dx_add_note 'ORDEN', @ord_header,1,1,@texto,'N',null,'SA'
	--exec dx_add_note 'ORDEN', '587850',1,1,'test','N',null,'SA'
END
IF(@ConjuntoDatos = 'rechazoOtra')
BEGIN

--prepara la concatenacion de la nota
	set @texto = @Evidencia + '||' + @Status +  '||' + @Razon
--ejecutar el procedimiento para insertar la nota	
	
	exec dx_add_note 'ORDEN', @ord_header,1,1,@texto,'N',null,'SA';
	--exec dx_add_note 'ORDEN', '587850',1,1,'test','N',null,'SA'
	update orderheader 
	set ord_invoicestatus = 'XIN'
	where  LTRIM(RTRIM(ord_number))= @ord_header
END


END


--select * from notes where ntb_table = 'orderheader' and nre_tablekey ='587850' and not_type is null

--select * from orderheader where ord_number = '587850'
GO
