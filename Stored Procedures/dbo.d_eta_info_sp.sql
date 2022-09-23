SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*	SP d_eta_info_sp
	
	Returns ETA Agent info for a given LegHeader.

	Parameters:	@vl_lgh_number	The LegHeader for which to retrieve ETA Agent info.

	Returns:	result set		containing 1 row of ETA Agent info.

	Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	--------------------------------------------
	08/29/2003	Vern Jewett		18417	(none)	Original
*/

CREATE PROC [dbo].[d_eta_info_sp]
		@vl_lgh_number	int
as


create table #lgh
		(lgh_etacomment		text		null
		,lgh_etacalcdate	datetime	null
		,lgh_etaalert1		varchar(10)		null)


insert	#lgh
		(lgh_etacomment
		,lgh_etacalcdate
		,lgh_etaalert1)
  select lgh_etacomment
		,lgh_etacalcdate
		,isnull(lgh_etaalert1, 'N')
  from	legheader
  where	lgh_number = @vl_lgh_number

select	lgh_etacomment
		,lgh_etacalcdate
		,lgh_etaalert1
  from	#lgh


drop table #lgh
GO
GRANT EXECUTE ON  [dbo].[d_eta_info_sp] TO [public]
GO
