SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[vista_rh_examen_medico_oper_oo]
as

SELECT top 1000 mpp_id as ID,
mpp_lastfirst as Nombre,
Format(mpp_hiredate,'yyyy/MM/dd') as Fecha_contratacion,
mpp_misc4 as CURP
from manpowerprofile 
where mpp_avl_status in ('OMTTO','USE','TRAM','VACT','UMTTO','AVL','DES','EXMED','FALTA','PLN')
and mpp_misc4 IS NOT NULL
ORDER BY mpp_lastfirst

GO
