SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_ActualizaMBJR]  @NumeroFactura varchar(6), @MontoAjuste float

AS
	SET nocount off
	begin

	--print @NumeroFactura
	--print convert(varchar(8),@MontoAjuste)
		Begin tran T1;
			update invoicedetail set ivd_charge = ivd_charge + @MontoAjuste  where cht_itemcode = 'GST' and ivh_hdrnumber = @NumeroFactura;
			
	
		commit tran T1;
	end
RETURN 
GO
