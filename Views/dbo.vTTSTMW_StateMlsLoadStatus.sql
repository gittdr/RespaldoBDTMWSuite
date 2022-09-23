SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE View [dbo].[vTTSTMW_StateMlsLoadStatus]


As
Select LoadStatus = (select b.stp_loadstatus from stops b WITH (NOLOCK) where b.stp_number = stops.stp_number),
	   ArrivalDate = (select b.stp_arrivaldate from stops b WITH (NOLOCK) where b.stp_number = stops.stp_number),
	   MoveNumber = (select b.mov_number from stops b WITH (NOLOCK) where b.stp_number = stops.stp_number),
	   LegNumber = (select b.lgh_number from stops b WITH (NOLOCK) where b.stp_number = stops.stp_number),
	   stops.stp_number
	
	   
From stops WITH (NOLOCK) Left Join MR_FakeJoin On stops.stp_number = MR_FakeJoin.field1

GO
GRANT SELECT ON  [dbo].[vTTSTMW_StateMlsLoadStatus] TO [public]
GO
