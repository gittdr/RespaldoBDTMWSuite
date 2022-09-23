SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view  [dbo].[vista_emptymatrix] as
(
select case when stp_mfh_sequence = 1 then (select stp_lgh_mileage from stops s  with (nolock) where s.lgh_number = stops.lgh_number and s.stp_mfh_sequence = 2 ) else stp_lgh_mileage end as kilometros,
(select name from labelfile with (nolock) where labeldefinition = 'RevType3' and abbr = (select ord_revtype3 from orderheader with (nolock)where orderheader.ord_hdrnumber = (select ord_hdrnumber  from legheader with (nolock) where lgh_number = stops.lgh_number))) as Proyecto,
(select name from labelfile with (nolock) where labeldefinition = 'RevType4' and abbr = (select ord_revtype4 from orderheader with (nolock) where orderheader.ord_hdrnumber = (select ord_hdrnumber  from legheader with (nolock) where lgh_number = stops.lgh_number))) as Division,
(select ord_hdrnumber  from legheader with (nolock) where lgh_number = stops.lgh_number) as orden,
case when  stp_event in ('BBT','BMT') then cmp_id else (select cmp_id from stops s with (nolock) where s.lgh_number = stops.lgh_number and s.stp_mfh_sequence = (stops.stp_mfh_sequence - 1)) end as origen,
case when  stp_event in ('BBT','BMT') then (select cmp_id from stops s with (nolock) where s.lgh_number = stops.lgh_number and s.stp_mfh_sequence = (stops.stp_mfh_sequence + 1)) else cmp_id  end as destino,
--((select stp_lgh_mileage as kilometros)  * 2.8) as litros,
--((select stp_lgh_mileage as kilometros)  * 2.8)  *   (SELECT  afp_price FROM  averagefuelprice WHERE (afp_description = 'DIESEL' and afp_date = (select max(afp_date) from averagefuelprice where afp_description = 'DIESEL') )) as costocomb,
month(stp_schdtearliest) as mes,
stp_event as Evento
 from stops with (nolock)
where year(stp_schdtearliest) = 2013
and stp_lgh_mileage <= 100
and stp_event in ('IEMT','EMT', 'BMT','EBT')
)

GO
