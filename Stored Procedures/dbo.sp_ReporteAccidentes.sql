SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ReporteAccidentes](@ORDEN AS VARCHAR(100))
as
begin



INSERT INTO AccidentesregistroCems ([ID], [FECHA Y HORA], [ID_OPERADOR], [NOMBRE DEL OPERADOR], [NUMERO CELULAR DEL OPERADOR], [UNIDAD TRACTO CAMION], [PLACAS TRACTO CAMION], [SERIE TRACTO CAMION], [REMOLQUE 1], [PLACAS REMOLQUE 1], [SERIE REMOLQUE 1], [DOLLY], [SERIE DOLLY], [REMOLQUE 2], [PLACAS REMOLQUE 2], [SERIE REMOLQUE 2], [ORDEN DE TRABAJO], [CLIENTE], [DIRECCION DONDE FUE EL SINIESTRO], [COORDENADAS], [URLGoogleMaps])
select '1' 'ID',
getdate() as 'FECHA Y HORA',
oh.ord_driver1 as 'ID_OPERADOR',
B.mpp_lastfirst as 'NOMBRE DEL OPERADOR',
B.mpp_homephone as 'NUMERO CELULAR DEL OPERADOR',
oh.ord_tractor as 'UNIDAD TRACTO CAMION',
(select trc_licnum from tractorprofile where tractorprofile.trc_number = oh.ord_tractor)  as 'PLACAS TRACTO CAMION',
(select trc_serial from tractorprofile where tractorprofile.trc_number = oh.ord_tractor) as 'SERIE TRACTO CAMION',
oh.ord_trailer as 'REMOLQUE 1',
(select trl_licnum from trailerprofile where trailerprofile.trl_number=oh.ord_trailer)  as 'PLACAS REMOLQUE 1',
(select trl_serial from trailerprofile where trailerprofile.trl_number=oh.ord_trailer) as 'SERIE REMOLQUE 1',
lg.lgh_dolly as 'DOLLY',
(select SERIALNO  from [172.24.16.113].TMWAMS.DBO.units U WHERE  U.unitnumber = lg.lgh_dolly ) as 'SERIE DOLLY',
(select UNITNUMBER  from [172.24.16.113].TMWAMS.DBO.units U WHERE  U.unitnumber = oh.ord_trailer2) as 'REMOLQUE 2',
(select trl_licnum from trailerprofile where trailerprofile.trl_number=oh.ord_trailer2)  as 'PLACAS REMOLQUE 2',
(select trl_serial from trailerprofile where trailerprofile.trl_number=oh.ord_trailer2) as 'SERIE REMOLQUE 2',
oh.ord_hdrnumber as 'ORDEN DE TRABAJO',
oh.ord_billto as 'CLIENTE',
(select ckc_comment from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)) as 'DIRECCION DONDE FUE EL SINIESTRO' ,
     COORDENADAS =  
CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as varchar)  + ',' +
cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as varchar) ,
URLGoogleMaps =  
'https://maps.google.com/?q=' +
CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as varchar)  + ',' +
cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as varchar)
from legheader lg
inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
INNER JOIN manpowerprofile B ON B.mpp_id = oh.ord_driver1
INNER JOIN TRAILERPROFILE D ON  D.trl_number= tp.trc_trailer1
INNER JOIN TRAILERPROFILE E ON  E.trl_number= tp.trc_trailer2
INNER JOIN city F ON F.cty_code = tp.trc_prior_city
where oh.ord_hdrnumber=@ORDEN
AND (SELECT COUNT(*) FROM AccidentesregistroCems WHERE  @ORDEN = AccidentesregistroCems.[ORDEN DE TRABAJO])<1


SELECT * FROM  AccidentesregistroCems WHERE  @ORDEN = AccidentesregistroCems.[ORDEN DE TRABAJO]

END



GO
