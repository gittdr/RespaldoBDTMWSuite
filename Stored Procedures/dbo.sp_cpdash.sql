SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec sp_cpdash 'EUCOMEX'

CREATE proc [dbo].[sp_cpdash] (@proyecto varchar(20))
as
begin 

select 
count(*) as OrdenesTotales,

OrdenesTarde = (select count(*) 
FROM TMWScrollOrderView_TDR
where Etadif > 0  and ord_revtype3_name  = @proyecto ) ,

OrdenesTemprano =
(select
count(*) as OrdenesTemprano
FROM TMWScrollOrderView_TDR
where EtaDif <= 0  and ord_revtype3_name  = @proyecto ),

Eficiencia =  round((select
cast(count(*) as float) as OrdenesTemprano
FROM TMWScrollOrderView_TDR
where EtaDif < 0  and ord_revtype3_name  = @proyecto ) / (select cast(count(*) as float) from TMWScrollOrderView_TDR where   ord_revtype3_name  = @proyecto) * 100,2)


from TMWScrollOrderView_TDR
where ord_revtype3_name =  @proyecto 


end
GO
