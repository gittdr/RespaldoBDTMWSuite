SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[view_liverReportUbicacion]
as
select *,
DescripcionGPS = Replace(replace(replace(trc_gps_desc,'\u00e9','e'),'\u00e1','a'), substring(trc_gps_desc,0,12), ''),
google = 'https://maps.google.com/?q=' + cast(lat as varchar) +',-'+ cast(long as varchar)
from [liverReportUbicacion]
GO
