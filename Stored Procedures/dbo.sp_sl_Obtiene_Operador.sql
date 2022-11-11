SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Obtiene_Operador] (@dato varchar(5000),@IdCampo varchar(500) , @ConjuntoDatos varchar(500))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--select * from notes where ntb_table = 'orderheader' and nre_tablekey ='587850' and not_type is null 

	SET NOCOUNT ON;
declare @texto varchar(100) 
IF(@ConjuntoDatos = 'GetOpe')
BEGIN

select top 1 mp.mpp_id,mp.mpp_tractornumber,oh.ord_hdrnumber,ev.evt_tractor,
ev.evt_trailer1,ev.evt_dolly,ev.evt_trailer2, 
(Case when ev.evt_eventcode = 'LUL' then 'CARGADO' else 'VACIO' end) as stp_status, 
ev.evt_eventcode as stp_type,
mp.mpp_firstname + ' ' + mp.mpp_lastname as mpp_name, oh.ord_billto
from manpowerprofile mp 
left outer join orderheader oh on oh.ord_driver1 = mp.mpp_id and oh.ord_status in ('AVL','PLN','STD') 
left outer join Event ev on ev.ord_hdrnumber = oh.ord_hdrnumber
left outer join stops stp on stp.ord_hdrnumber = oh.ord_hdrnumber and stp.stp_status = 'OPN'
where mp.mpp_id = @dato
order by ord_hdrnumber desc

END



END
GO
