SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CaculaCasetascitycomp] (@orden varchar(20)) 
AS

declare @mtabla int

set @mtabla = (select cmp_mileagetable  from company with (nolock) where cmp_id  in (select ord_billto from orderheader where ord_hdrnumber = @orden))

--calculamos el monto de casetas para cada uno de los stops excepto el primero por que es el inicio
update stops
 set stp_ord_toll_cost = 

 (case when stp_mfh_sequence <> (select min(b.stp_mfh_sequence) from stops b with (nolock) where b.ord_hdrnumber = stops.ord_hdrnumber) 
 then  
     isnull(
     isnull(
     isnull (
     (select mt_tolls_cost from mileagetable 
     where mt_origin = (select cmp_id from stops a with (nolock) where a.stp_mfh_sequence = (stops.stp_mfh_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))
     and  mt_destination = stops.cmp_id and mt_type = @mtabla ), (select mt_tolls_cost from mileagetable 
     where mt_destination = (select cmp_id   from stops a with (nolock) where a.stp_mfh_sequence = (stops.stp_mfh_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))
     and  mt_origin = stops.cmp_id and mt_type = @mtabla )  
     ),(select mt_tolls_cost from mileagetable 
     where mt_destination = (select cast(m.cmp_city as varchar)  from  company m  where m.cmp_id = (select cmp_id   from stops a with (nolock) where a.stp_mfh_sequence = (stops.stp_mfh_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))
     and  mt_origin = (select cast(m.cmp_city as varchar)  from  company m  where m.cmp_id = stops.cmp_id) and mt_type = @mtabla )  
     )
     ),(select mt_tolls_cost from mileagetable 
     where mt_origin = (select cast(m.cmp_city as varchar)  from  company m  where m.cmp_id = (select cmp_id   from stops a with (nolock) where a.stp_mfh_sequence = (stops.stp_mfh_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))
     and  mt_destination = (select cast(m.cmp_city as varchar)  from  company m  where m.cmp_id = stops.cmp_id) and mt_type = @mtabla  ))
     )
 else null end
 )
 where stops.ord_hdrnumber = @orden

--Insertamos el monto total calculado de las casetas por stops al orderheader
update orderheader
     set ord_toll_cost_update_date=getdate(),
     ord_toll_cost =  (select sum(stp_ord_toll_cost)  from stops  with (nolock) where stops.ord_hdrnumber = orderheader.ord_hdrnumber)
     where ord_hdrnumber = @orden


	SET NOCOUNT OFF


GO
