SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_convoy_ordenes_AbiertInt_dia]
as
begin

select  (select lb.name from labelfile lb
where abbr = ord_revtype2 and labeldefinition = 'RevType2')  as sucursal,
	ord_billto ,
	ord_hdrnumber as Orden,
	ord_startdate,
	ord_status,
	ord_refnum
	from orderheader
	where cast(ord_startdate as date) = cast(GETDATE() as date)
		and ord_revtype3 in ('BAJ','INT')
		and ord_status <> 'CAN'
end
GO
