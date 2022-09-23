SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Disp_matrix] as
(
select
(select replace(name,'BAJIO','ABIERTO') from labelfile where labeldefinition = 'Revtype3' and abbr = O.ord_revtype3) as Proyecto ,
(select rgh_name from regionheader where  rgh_id = (select cmp_region1 from company where cmp_id = ord_originpoint )) as Region,
O.ord_originpoint as Patio ,
----al dia de hoy-------------------
disph=(select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) <= 0 ) and A.ord_status = 'AVL' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
planeh = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) <= 0 ) and A.ord_status = 'PLN' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
emph = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) <= 0 ) and A.ord_status = 'STD' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)),
terh= (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_completiondate,getdate()) = 0 ) and A.ord_status = 'CMP' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_destpoint)),
----al dia de hoy + 1 ---------------
disp1=(select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -1 ) and A.ord_status = 'AVL' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
plane1 = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -1 ) and A.ord_status = 'PLN' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
emp1 = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -1 ) and A.ord_status = 'STD' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
ter1= (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_completiondate,getdate()) = -1 )  and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_destpoint)),
----al dia de hoy + 2 ---------------
disp2=(select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -2 ) and A.ord_status = 'AVL' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
plane2 = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -2 ) and A.ord_status = 'PLN' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
emp2 = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -2 ) and A.ord_status = 'STD' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
ter2= (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_completiondate,getdate()) = -2 ) and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_destpoint)),
----al dia de hoy + 3 ---------------
disp3=(select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -3 ) and A.ord_status = 'AVL' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
plane3 = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -3 ) and A.ord_status = 'PLN' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
emp3 = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -3 ) and A.ord_status = 'STD' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
ter3= (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_completiondate,getdate()) = -3 ) and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_destpoint)),
----al dia de hoy + 4 ---------------
disp4=(select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -4 ) and A.ord_status = 'AVL' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)) ,
plane4 = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -4 ) and A.ord_status = 'PLN' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)),
emp4 = (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_startdate,getdate()) = -4 ) and A.ord_status = 'STD' and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_originpoint)),
ter4= (select count(A.ord_number) from orderheader A where (datediff(dd,A.ord_completiondate,getdate()) = -4 )  and (O.ord_revtype3 = A.ord_revtype3) and (O.ord_originpoint = A.ord_destpoint))

from orderheader O
group by ord_revtype3, ord_originpoint
)

GO
