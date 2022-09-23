SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[KimlomRecoridos]
as
select MONTH(cast(asgn_date as date)) as Mes, DATEPART(ISO_WEEK, cast(asgn_date as date)) as NumSemana,asgn_id as Tractor,
sevent.evt_driver1 as Operador, (SELECT ISNULL(SUM(stp_lgh_mileage), 0) FROM stops WHERE stops.lgh_number = lgh.lgh_number) miles,
(SELECT TOP 1 lf.name FROM labelfile lf WHERE  lf.abbr = lgh.mpp_fleet) Flota, lgh.mpp_type3 as Proyecto,asgn_date
FROM  legheader lgh  LEFT OUTER JOIN  orderheader  ON  lgh.ord_hdrnumber  = orderheader.ord_hdrnumber   
                     LEFT OUTER JOIN  legheader_active l  ON  lgh.lgh_number  = l.lgh_number ,
	 assetassignment,
	 event sevent,
	 stops sstops,
	 event eevent
 
WHERE	assetassignment.lgh_number  = lgh.lgh_number
		AND	assetassignment.evt_number  = sevent.evt_number
		AND	sevent.stp_number  = sstops.stp_number
		AND	assetassignment.last_evt_number  = eevent.evt_number
GO
