SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[SP_TRACTORESOPER]  (@token varchar(254))
--exec [dbo].[SP_TRACTORESOPER] 'PI15765-QA76000-APY15765'

as

declare @FleetTrc xml

set @FleetTrc =

(
select  mpp_tractornumber as tractor,
mpp_id as idoperador,
mpp_firstname as nombreoper,
mpp_lastname as apellidooper
from manpowerprofile
where mpp_status <> 'OUT' and mpp_id <> 'UNKNOWN'  
and mpp_type3 = 'PIL'
and @token = (select cmp_misc8 from company where cmp_id = 'PILGRIMS')
FOR XML PATH ('OPERADOR'), ROOT ('OPERADORES')

)


select @FleetTrc as FleetTrc


GO
