SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--DROP PROCEDURE sp_integraMB
--GO

--exec sp_integraMB

CREATE  PROCEDURE [dbo].[sp_integraMB]  @billto VARCHAR(8), @Usuario VARCHAR(8)
AS
BEGIN --1 Principal

DECLARE @ls_cmp_id 	varchar(8),
		@ld_fechamb	DateTime,
		@ls_esbillto	char(1),	
		@ls_activa	char(1),
		@ls_tipofact	varchar(3),
		@li_mbmaxima	Integer,
		@li_monto	Integer,
		@li_mbmax_NC	Integer


	/* Se hace el select para obtener los datos que se estan actualizando */
	/* y hacer la actualizacion de las ordenes que no pasaron a PRN */

SELECT 	@ls_cmp_id 	= a.cmp_id,
	@ld_fechamb	= a.cmp_lastmb,
	@ls_esbillto	= a.cmp_billto, 
	@ls_activa	= a.cmp_active,
	@ls_tipofact	= a.cmp_transfertype
FROM company a
WHERE   a.cmp_id = @billto




IF  @ls_activa = 'Y' and @ls_esbillto = 'Y' and @ls_tipofact = 'MAS'
-- Busca el numero de la MB mas actual del cliente en cuestion
	Begin
	select @li_mbmaxima = max(ivh_mbnumber) from invoiceheader where ivh_billto =  @ls_cmp_id and  ivh_creditmemo = 'N'
	select @li_mbmax_NC = max(ivh_mbnumber) from invoiceheader where ivh_billto =  @ls_cmp_id and  ivh_creditmemo = 'Y'

-- revisa el monto de las invoices que estan en ready to print para saber si es una MB de invoices o de NC

select @li_monto = sum(ivh_totalcharge) from invoiceheader where ivh_billto = @ls_cmp_id
and ivh_invoicestatus = 'NTP' and ivh_mbstatus = 'RTP'

	--select @li_monto   = sum(ivh_totalcharge) from invoiceheader where ivh_mbnumber =  @li_mbmaxima
	--	reviso que la MB sea positivo si no es asi es una MB pero de NC y tomo el otro consecutivo
	IF @li_monto < 0 
		Begin
		update invoiceheader set ivh_mbnumber = @li_mbmax_NC ,ivh_invoicestatus = 'PRN', ivh_mbstatus = 'PRN', 
			ivh_printdate = @ld_fechamb,  ivh_lastprintdate = @ld_fechamb
		where ivh_billto = @ls_cmp_id   and last_updateby = @Usuario and
		ivh_invoicestatus = 'NTP' and ivh_mbstatus = 'RTP'
		end 
	End

	IF @li_monto > 0
	BEGIN
		update invoiceheader set ivh_mbnumber = @li_mbmaxima ,ivh_invoicestatus = 'PRN', ivh_mbstatus = 'PRN', 
			ivh_printdate = @ld_fechamb,  ivh_lastprintdate = @ld_fechamb
		where ivh_billto = @ls_cmp_id   and last_updateby = @Usuario and
		ivh_invoicestatus = 'NTP' and ivh_mbstatus = 'RTP'
	END

	--update tmwSuite..company set cmp_lastmb = getdate() where cmp_id = @billto

select cmp_lastmb from tmwSuite..company  where cmp_id = @billto

END --1 Principal




GO
