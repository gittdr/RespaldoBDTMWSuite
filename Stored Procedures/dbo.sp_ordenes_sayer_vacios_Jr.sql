SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Procedimiento para 'liberar' las ordenes de sus evidencias
-- solo del cliente de liverpool ID = LIVERPOL

--DROP PROCEDURE sp_ordenes_sayer_vacios_Jr 
--GO

--exec sp_LiberaEvidencias_JR  '2012-12-07', '2012-12-13'

CREATE PROCEDURE [dbo].[sp_ordenes_sayer_vacios_Jr]  @fechaini datetime, @fechafin datetime
AS
Declare @Ffin1	varchar(20),
		@Ffin2	datetime

Select @Ffin1 = convert(Varchar(20),@fechafin,102)

Select @Ffin1 = @Ffin1+' 23:59'
--SELECT CONVERT(Datetime, '2011-09-28 18:01:00', 120)
select @Ffin2 = Convert(DateTime,@Ffin1,102)


DECLARE @ordenes_vacios TABLE(
		fecha_documentado		datetime Null,
		trailer					varchar(15) null,
		destino					varchar(10) null,
		Orden					numeric NULL,
		transporte				varchar(15) null,
		tractor					varchar(15) null,
		ordenmaestra		    varchar(15) Null,
		nota					varchar(254) Null)

SET NOCOUNT ON

BEGIN --1 Principal

	INSERT Into @ordenes_vacios

select ord_bookdate, ord_trailer, ord_destpoint, ord_hdrnumber, '' ,ord_tractor , ord_fromorder, not_text 
from orderheader 
left join notes on( nre_tablekey = ord_number and last_updatedby <> 'IMPORT')
where ord_fromorder in('SAYER-VACIO','SAYER-TRONCO')
and ord_bookdate between @fechaini  and @Ffin2


Select * from @ordenes_vacios


END --1 Principal











GO
