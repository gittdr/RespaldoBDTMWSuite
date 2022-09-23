SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_findnextactivity_start] @asgnid varchar (13), @asgntype varchar (6), @asgndate datetime, @mov integer
AS
SET NOCOUNT ON
SELECT lh.mov_number, lh.lgh_number, aa.asgn_date, aa.asgn_enddate, 
		 aa.asgn_status, lgh_primary_trailer, lgh_primary_pup, cmp_id_start, 
		 lgh_startcty_nmstct, stp_number_start, lgh_startcity, lh.ord_hdrnumber,
		 (select event.evt_chassis from event where event.evt_number = aa.last_evt_number) evt_chassis,
		 (select event.evt_chassis2 from event where event.evt_number = aa.last_evt_number) evt_chassis2,
		 (select event.evt_dolly from event where event.evt_number = aa.last_evt_number) evt_dolly,
		 (select event.evt_dolly2 from event where event.evt_number = aa.last_evt_number) evt_dolly2,
		 (select event.evt_trailer3 from event where event.evt_number = aa.last_evt_number) evt_trailer3,
		 (select event.evt_trailer4 from event where event.evt_number = aa.last_evt_number) evt_trailer4
  FROM legheader lh, assetassignment aa
 WHERE lh.lgh_number = aa.lgh_number 
 	AND aa.asgn_id = @asgnid 
	AND aa.asgn_type = LEFT(@asgntype, 3) 
	AND aa.asgn_date = @asgndate
	AND aa.mov_number <> @mov
GO
GRANT EXECUTE ON  [dbo].[d_findnextactivity_start] TO [public]
GO
