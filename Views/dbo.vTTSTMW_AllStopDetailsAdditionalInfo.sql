SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE View [dbo].[vTTSTMW_AllStopDetailsAdditionalInfo]
 
As
 
Select top 100 percent
 
       evt_hubmiles_trailer1 as [Trailer1 Hub Reading],
       Case When [Sequence in Movement] = (select min(b.[Sequence in Movement]) from vTTSTMW_AllStopDetails b where b.[Move Number] = vTTSTMW_AllStopDetails.[Move Number] and b.[Trailer1 ID] =
vTTSTMW_AllStopDetails.[Trailer1 ID]) Then
   0
 Else
  Case When evt_hubmiles_trailer1 Is NULL Then 
   0
  Else 
   evt_hubmiles_trailer1 - (Select max(b.evt_hubmiles_trailer1) from event b
(NOLOCK) where b.evt_startdate < event.evt_startdate and event.evt_mov_number = b.evt_mov_number and b.evt_trailer1 =
event.evt_trailer1)
  End
 End as [Trailer1 Hub Miles],
 vTTSTMW_AllStopDetails.*
 
 
 
 
From   vTTSTMW_AllStopDetails Left Join event (NOLOCK) On
vTTSTMW_AllStopDetails.[Stop Number] = event.stp_number and event.evt_sequence = 1 Order By [Move Number],[Sequence in Movement]







GO
GRANT SELECT ON  [dbo].[vTTSTMW_AllStopDetailsAdditionalInfo] TO [public]
GO
