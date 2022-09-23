SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_assetsync_pw] @asgnid varchar (13), @asgntype varchar (6), @asgndate datetime
AS
SET NOCOUNT ON
DECLARE @lgh_number integer, 
        @mov_number integer, 
        @lgh_endcity integer, 
        @ord_hdrnumber integer, 
        @asgn_date datetime,
        @asgn_enddate datetime,
        @lgh_outstatus varchar (6),
        @lgh_primary_trailer varchar (13), 
        @lgh_primary_pup varchar (13), 
        @cmp_id_end varchar (13),
        @lgh_endcty_nmstct varchar (25),
        @stpevent varchar (6),
        @lgh_nexttrailer1 varchar (13), 
        @lgh_nexttrailer2 varchar (13), 
        @end_trl1 varchar (13),
        @end_trl2 varchar (13), 
        @quit integer

SELECT @quit = 0
SELECT @mov_number = lh.mov_number, 
       @lgh_number = lh.lgh_number, 
       @asgn_date = aa.asgn_date, 
       @asgn_enddate = aa.asgn_enddate, 
       @lgh_outstatus = lgh_outstatus, 
       @lgh_primary_trailer = lgh_primary_trailer, 
       @lgh_primary_pup = lgh_primary_pup, 
       @cmp_id_end = cmp_id_end, 
       @lgh_endcty_nmstct = lgh_endcty_nmstct, 
       @stpevent = stp_event, 
       @lgh_endcity = lgh_endcity, 
       @ord_hdrnumber = lh.ord_hdrnumber, 
       @lgh_nexttrailer1 = lgh_nexttrailer1, 
       @lgh_nexttrailer2 = lgh_nexttrailer2
   FROM legheader lh, stops, assetassignment aa
  WHERE stp_number_end = stp_number 
    AND lh.lgh_number = aa.lgh_number 
    AND aa.asgn_id = @asgnid 
    AND aa.asgn_type = @asgntype 
    AND aa.asgn_date = (SELECT Max(aa2.asgn_date) 
                          FROM assetassignment aa2, legheader lg2 
                          WHERE aa2.asgn_id = @asgnid 
                            AND aa2.asgn_type = @asgntype 
                            AND aa2.asgn_status IN ('CMP', 'STD', 'PLN', 'DSP') 
                            AND (lg2.lgh_outstatus IN ('CMP', 'STD') 
                                OR (lg2.lgh_outstatus = 'DSP' 
                                    AND aa2.asgn_date <= @asgndate)) 
                            AND lg2.lgh_number = aa2.lgh_number)
IF @@ROWCOUNT = 0 SELECT @quit = 1
SELECT @end_trl1 = evt_trailer1, @end_trl2 = evt_trailer2 
  FROM event, stops s1
 WHERE s1.lgh_number = @lgh_number 
   AND s1.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) 
                                FROM stops s2
                               WHERE s2.lgh_number = @lgh_number) 
   AND event.evt_sequence = 1 
   AND s1.stp_number = event.stp_number

if @quit = 1 
	SELECT top 0 @mov_number, @lgh_number, @asgn_date, @asgn_enddate, @lgh_outstatus, 
		        @lgh_primary_trailer, @lgh_primary_pup, @cmp_id_end, @lgh_endcty_nmstct, 
		        @stpevent, @lgh_endcity, @ord_hdrnumber, @lgh_nexttrailer1, @lgh_nexttrailer2, 
		        @end_trl1, @end_trl2
else
	SELECT top 1 @mov_number, @lgh_number, @asgn_date, @asgn_enddate, @lgh_outstatus, 
		        @lgh_primary_trailer, @lgh_primary_pup, @cmp_id_end, @lgh_endcty_nmstct, 
		        @stpevent, @lgh_endcity, @ord_hdrnumber, @lgh_nexttrailer1, @lgh_nexttrailer2, 
		        @end_trl1, @end_trl2

GO
GRANT EXECUTE ON  [dbo].[d_assetsync_pw] TO [public]
GO
