SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_findpreviousactivity] @asgnid varchar (13), @asgntype varchar (6), @asgndate datetime
AS
SET NOCOUNT ON
SELECT lh.mov_number, lh.lgh_number, aa.asgn_date, aa.asgn_enddate, 
		 aa.asgn_status, lgh_primary_trailer, lgh_primary_pup, cmp_id_end, 
		 lgh_endcty_nmstct, stp_number_end, lgh_endcity, lh.ord_hdrnumber,
		 (select event.stp_number from event where evt_number = aa.last_evt_number) last_stop
  FROM legheader lh, assetassignment aa 
 WHERE lh.lgh_number = aa.lgh_number 
 	AND aa.asgn_id = @asgnid
	AND aa.asgn_type = LEFT(@asgntype, 3) 
	AND aa.asgn_date = @asgndate
GO
GRANT EXECUTE ON  [dbo].[d_findpreviousactivity] TO [public]
GO
