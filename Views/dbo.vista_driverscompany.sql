SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [dbo].[vista_driverscompany]
AS
SELECT     rtrim(mpp_id) as ID, rtrim(mpp_id) +':' +rtrim(mpp_firstname) +' '+ rtrim(mpp_lastname) as Driver, 
cast(datepart(hh,mpp_avl_date) as int) as fecha,
DATEDIFF(dd, mpp_avl_date, GETDATE()) AS DIFDIAS,
CASE WHEN mpp_status IN ('AVL','PLN') THEN 0 ELSE  
DATEDIFF(dd, mpp_avl_date, GETDATE()) END AS DIAS,
mpp_licenseclass as Licencia,
(select name from labelfile with (nolock)  where labeldefinition = 'TeamLeader' and abbr = mpp_teamLeader) as Lider,
(select cast(trc_gps_date as varchar(20)) + ' - ' + trc_gps_desc  from tractorprofile  where trc_number = mpp_tractornumber )as UbiGPS,

mpp_avl_cmp_id AS Patio, 
(select rgh_name from regionheader with (nolock) where rgh_id  = (select cmp_region1  from company where company.cmp_id = mpp_avl_cmp_id)) as Region,

mpp_status as DriverStatus,
mpp_type2 as Rango,
mpp_type1 as CalifRemolque,
mpp_type3 as ProyectoDriver,
(select name from labelfile with (nolock)  where labeldefinition = 'DrvType3' and abbr = mpp_type3) as NombreProyecto,
mpp_mile_day7 as Prodsietedias,
mpp_tractornumber as Tractor,

(select name from labelfile with (nolock)  where labeldefinition = 'RevType3' and abbr =(select cmp_revtype3 from company with (nolock)  where  CMP_ID = mpp_avl_cmp_id)) AS Proyecto,
mpp_division as EC

FROM         dbo.manpowerprofile with (nolock) 
WHERE     (mpp_status not in ('OUT')) --,'SIN','VAC'))
--and trl_number not in (select exp_id from expiration where exp_idtype = 'TRL')


GO
